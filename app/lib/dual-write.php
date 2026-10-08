<?php
declare(strict_types=1);

/**
 * Dual Database Write System
 * Writes intake submissions to both PostgreSQL and Airtable
 * Implements rollback on failure for data consistency
 */

require_once __DIR__ . '/../config/database.php';

class DualDatabaseWriter {
    private ?PDO $pdo = null;
    private ?object $airtable = null;
    private bool $postgresSuccess = false;
    private bool $airtableSuccess = false;
    private array $rollbackData = [];
    
    public function __construct() {
        $config = get_database_config();
        
        // Always initialize PostgreSQL for primary storage
        if (isset($config['postgresql'])) {
            $pg = $config['postgresql'];
            $dsn = "pgsql:host={$pg['host']};port={$pg['port']};dbname={$pg['database']}";
            $this->pdo = new PDO($dsn, $pg['user'], $pg['password'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        }
        
        // Initialize Airtable if configured (check for api_key or PAT)
        if (isset($config['airtable'])) {
            $hasApiKey = !empty($config['airtable']['api_key']);
            $hasPAT = !empty($config['airtable']['personal_access_token']);
            if ($hasApiKey || $hasPAT) {
                $this->airtable = new AirtableWriter($config['airtable']);
            }
        }
    }

    /**
     * Expose the PostgreSQL connection for PSQL-specific transactional
     * writers (intake-save, duplicate checks, account creation). These
     * always run on PostgreSQL regardless of which driver the app READS
     * from, so callers should use this instead of archr_pdo().
     */
    public function getPdo(): ?PDO {
        return $this->pdo;
    }
    
    /**
     * Write submission to both databases with rollback on failure
     * 
     * @param array $submissionData Intake submission data
     * @param callable $pgWriter PostgreSQL writer function
     * @return array Result with submission_id and success flags
     * @throws Exception on complete failure
     */
    public function dualWrite(array $submissionData, callable $pgWriter): array {
        $result = [
            'postgres_success' => false,
            'airtable_success' => false,
            'submission_id' => null,
            'errors' => [],
        ];
        
        // Step 1: Write to PostgreSQL (primary)
        try {
            $pgResult = $pgWriter($this->pdo, $submissionData);
            // Preserve all PostgreSQL result keys (submission_id, anchor_id, case_number, etc.)
            $result = array_merge($result, $pgResult);
            $result['postgres_success'] = true;
            $this->postgresSuccess = true;
            $this->rollbackData['postgres'] = $pgResult;

            error_log('[DualWrite] PostgreSQL write successful: ' . $result['submission_id']);
        } catch (Throwable $e) {
            $result['errors'][] = 'PostgreSQL: ' . $e->getMessage();
            error_log('[DualWrite] PostgreSQL write failed: ' . $e->getMessage());
            throw new Exception('Primary database write failed: ' . $e->getMessage());
        }

        // Step 2: Write to Airtable (secondary, non-blocking)
        if ($this->airtable) {
            try {
                $airtableId = $this->airtable->writeSubmission($submissionData, $result['submission_id']);
                $result['airtable_success'] = true;
                $result['airtable_id'] = $airtableId;
                $this->airtableSuccess = true;
                $this->rollbackData['airtable'] = ['id' => $airtableId];
                
                error_log('[DualWrite] Airtable write successful: ' . $airtableId);
            } catch (Throwable $e) {
                // Airtable failure is non-fatal, log but continue
                $result['errors'][] = 'Airtable: ' . $e->getMessage();
                error_log('[DualWrite] Airtable write failed (non-fatal): ' . $e->getMessage());
                
                // Queue for retry
                $this->queueAirtableRetry($submissionData, $result['submission_id']);
            }
        } else {
            error_log('[DualWrite] Airtable not configured, skipping secondary write');
        }
        
        return $result;
    }
    
    /**
     * Rollback both databases on critical failure
     */
    public function rollback(): void {
        if ($this->postgresSuccess && $this->pdo) {
            try {
                $submissionId = $this->rollbackData['postgres']['submission_id'] ?? null;
                if ($submissionId) {
                    $this->pdo->prepare("DELETE FROM intake_submissions WHERE id = ?")
                              ->execute([$submissionId]);
                    error_log('[DualWrite] PostgreSQL rollback successful: ' . $submissionId);
                }
            } catch (Throwable $e) {
                error_log('[DualWrite] PostgreSQL rollback failed: ' . $e->getMessage());
            }
        }
        
        if ($this->airtableSuccess && $this->airtable) {
            try {
                $airtableId = $this->rollbackData['airtable']['id'] ?? null;
                if ($airtableId) {
                    $this->airtable->deleteRecord($airtableId);
                    error_log('[DualWrite] Airtable rollback successful: ' . $airtableId);
                }
            } catch (Throwable $e) {
                error_log('[DualWrite] Airtable rollback failed: ' . $e->getMessage());
            }
        }
    }
    
    /**
     * Queue Airtable write for retry
     */
    private function queueAirtableRetry(array $data, int $submissionId): void {
        $queueFile = __DIR__ . '/../logs/airtable-retry-queue.jsonl';
        $queueDir = dirname($queueFile);
        
        if (!is_dir($queueDir)) {
            @mkdir($queueDir, 0750, true);
        }
        
        $entry = json_encode([
            'submission_id' => $submissionId,
            'data' => $data,
            'queued_at' => date(DATE_ATOM),
            'attempts' => 0,
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n";
        
        @file_put_contents($queueFile, $entry, FILE_APPEND | LOCK_EX);
    }
}

/**
 * Airtable Writer
 *
 * Writes intake submissions to the Airtable dummy base. The table and field
 * names are the snake_case PostgreSQL identifiers created by build-airtable.js.
 */
class AirtableWriter {
    private string $apiKey;
    private array $bases;
    private string $baseId;
    private string $tableName;

    public function __construct(array $config) {
        // Prefer the Personal Access Token; fall back to the legacy API key.
        $this->apiKey = !empty($config['personal_access_token'])
            ? $config['personal_access_token']
            : ($config['api_key'] ?? '');
        $this->bases = $config['bases'];
        // The intake mirror lives in the 'intake_submissions' base by default.
        $this->baseId = $config['bases']['intake_submissions']
            ?? $config['bases']['repair_requests']
            ?? '';
        $this->tableName = $config['intake_table'] ?? 'intake_submissions';
    }

    /**
     * Write submission to Airtable
     */
    public function writeSubmission(array $data, int $pgSubmissionId): string {
        if (!$this->apiKey) {
            throw new Exception('Airtable Personal Access Token not configured');
        }
        if (!$this->baseId) {
            throw new Exception('Airtable base ID not configured for intake_submissions');
        }

        $url = "https://api.airtable.com/v0/{$this->baseId}/" . rawurlencode($this->tableName);

        $fields = $this->mapToAirtableFields($data, $pgSubmissionId);
        if (!$fields) {
            throw new Exception('No Airtable fields could be mapped from the submission');
        }

        $payload = json_encode(['fields' => $fields]);

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $this->apiKey,
                'Content-Type: application/json',
            ],
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200 && $httpCode !== 201) {
            throw new Exception("Airtable API error (HTTP $httpCode): $response");
        }

        $result = json_decode($response, true);
        return $result['id'] ?? '';
    }

    /**
     * Delete Airtable record
     */
    public function deleteRecord(string $recordId): void {
        if (!$this->baseId || !$this->apiKey) {
            return;
        }

        $url = "https://api.airtable.com/v0/{$this->baseId}/" . rawurlencode($this->tableName) . "/{$recordId}";

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => 'DELETE',
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $this->apiKey,
            ],
        ]);

        curl_exec($ch);
        curl_close($ch);
    }

    /**
     * Map form payload fields to Airtable field names.
     *
     * The Airtable dummy base created by build-airtable.js uses the PostgreSQL
     * column names (snake_case). Boolean fields are converted to true/false.
     */
    private function mapToAirtableFields(array $data, int $pgSubmissionId): array {
        $yes = static fn($v) => $v === 'yes' || $v === true || $v === 'true' || $v === '1';
        $str = static fn($k) => isset($data[$k]) && $data[$k] !== '' ? (string)$data[$k] : null;

        $fields = [
            'language' => $str('language') ?? 'eng',
            'applicant_first_name' => $str('applicantFirstName'),
            'applicant_last_name' => $str('applicantLastName'),
            'contact_email' => $str('contactEmail'),
            'home_phone' => $str('homePhone'),
            'cell_phone' => $str('cellPhone'),
            'home_address' => $str('homeAddress'),
            'home_city' => $str('homeCity'),
            'home_state' => $str('homeState'),
            'home_zip' => $str('homeZip'),
            'submission_status' => $str('submissionStatus') ?? 'pending',
            'is_referral' => $yes($data['isReferral'] ?? false),
            'helene_related' => $yes($data['heleneRelated'] ?? false),
            'submitted_at' => date(DATE_ATOM),
        ];

        // Add any optional core fields that are present in the payload.
        $optional = [
            'applicant_dob', 'referrer_name', 'referrer_organization', 'referrer_email',
            'referrer_notes', 'other_contact_method_description', 'contact_notes',
            'mail_address', 'mail_city', 'mail_state', 'mail_zip', 'home_type',
            'insurance_provider', 'fema_outcome', 'insurance_outcome', 'income_method',
            'income_docs_method', 'zero_income_first_name', 'zero_income_last_name',
            'zero_income_address', 'additional_repair_details',
        ];
        $camelToSnake = static function (string $s): string {
            return strtolower(preg_replace('/([a-z])([A-Z])/', '$1_$2', $s));
        };
        foreach ($data as $key => $value) {
            if ($value === '' || $value === null) {
                continue;
            }
            $snake = $camelToSnake($key);
            if (!isset($fields[$snake]) && in_array($snake, $optional, true)) {
                $fields[$snake] = is_array($value) ? implode(', ', $value) : (string)$value;
            }
        }

        // Drop nulls so Airtable does not try to write empty fields.
        return array_filter($fields, static fn($v) => $v !== null && $v !== '');
    }
}
