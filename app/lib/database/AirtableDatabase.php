<?php
declare(strict_types=1);

require_once __DIR__ . '/DatabaseInterface.php';

class AirtableDatabase implements DatabaseInterface {
    private string $apiKey;
    private array $bases;
    private array $tableMappings;
    
    public function __construct(array $config) {
        // Prefer the Personal Access Token; fall back to the legacy API key.
        $this->apiKey = !empty($config['personal_access_token'])
            ? $config['personal_access_token']
            : ($config['api_key'] ?? '');
        $this->bases = $config['bases'];
        $this->tableMappings = $config['table_mappings'] ?? [];
    }
    
    private function getTableInfo(string $table): array {
        if (!isset($this->tableMappings[$table])) {
            throw new RuntimeException("Table mapping not found for: {$table}");
        }
        $mapping = $this->tableMappings[$table];
        $baseId = $this->bases[$mapping['base']] ?? null;
        if (!$baseId) {
            throw new RuntimeException("Base not found: {$mapping['base']}");
        }
        return ['base_id' => $baseId, 'table_id' => $mapping['table_id']];
    }
    
    private function request(string $method, string $url, ?array $data = null): array {
        $ch = curl_init();
        $headers = ['Authorization: Bearer ' . $this->apiKey, 'Content-Type: application/json'];
        curl_setopt_array($ch, [CURLOPT_URL => $url, CURLOPT_RETURNTRANSFER => true, CURLOPT_HTTPHEADER => $headers, CURLOPT_CUSTOMREQUEST => $method]);
        if ($data !== null && in_array($method, ['POST', 'PATCH', 'PUT'])) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($httpCode >= 400) {
            throw new RuntimeException("Airtable API error (HTTP {$httpCode}): {$response}");
        }
        return json_decode($response, true) ?? [];
    }
    
    public function select(string $table, array $filters = [], array $fields = [], int $limit = 100, int $offset = 0): array {
        $info = $this->getTableInfo($table);
        $url = "https://api.airtable.com/v0/{$info['base_id']}/{$info['table_id']}";
        $params = ['maxRecords' => $limit, 'offset' => $offset];
        if (!empty($fields)) { $params['fields'] = $fields; }
        if (!empty($filters)) {
            $formulas = [];
            foreach ($filters as $key => $value) {
                if ($value === null) { $formulas[] = "{$key}=BLANK()"; }
                elseif (is_string($value)) { $formulas[] = "{$key}='" . addslashes($value) . "'"; }
                else { $formulas[] = "{$key}={$value}"; }
            }
            $params['filterByFormula'] = 'AND(' . implode(',', $formulas) . ')';
        }
        $url .= '?' . http_build_query($params);
        $response = $this->request('GET', $url);
        $records = [];
        foreach ($response['records'] ?? [] as $record) {
            $records[] = array_merge(['id' => $record['id']], $record['fields'] ?? []);
        }
        return $records;
    }
    
    public function find(string $table, $id): ?array {
        $info = $this->getTableInfo($table);
        $url = "https://api.airtable.com/v0/{$info['base_id']}/{$info['table_id']}/{$id}";
        try {
            $response = $this->request('GET', $url);
            return array_merge(['id' => $response['id']], $response['fields'] ?? []);
        } catch (RuntimeException $e) {
            if (strpos($e->getMessage(), 'HTTP 404') !== false) { return null; }
            throw $e;
        }
    }
    
    public function insert(string $table, array $data) {
        $info = $this->getTableInfo($table);
        $url = "https://api.airtable.com/v0/{$info['base_id']}/{$info['table_id']}";
        $response = $this->request('POST', $url, ['fields' => $data]);
        return $response['id'] ?? null;
    }
    
    public function update(string $table, $id, array $data): bool {
        $info = $this->getTableInfo($table);
        $url = "https://api.airtable.com/v0/{$info['base_id']}/{$info['table_id']}/{$id}";
        $this->request('PATCH', $url, ['fields' => $data]);
        return true;
    }
    
    public function delete(string $table, $id): bool {
        $info = $this->getTableInfo($table);
        $url = "https://api.airtable.com/v0/{$info['base_id']}/{$info['table_id']}/{$id}";
        $this->request('DELETE', $url);
        return true;
    }
    
    public function count(string $table, array $filters = []): int {
        $records = $this->select($table, $filters, ['id'], 100000);
        return count($records);
    }
    
    public function raw(string $query, array $params = []) {
        throw new RuntimeException("Raw queries are not supported in Airtable adapter");
    }
    
    public function beginTransaction(): void {}
    public function commit(): void {}
    public function rollback(): void {}
    
    public function getConnection() {
        return ['api_key' => $this->apiKey, 'bases' => $this->bases, 'table_mappings' => $this->tableMappings];
    }
}
