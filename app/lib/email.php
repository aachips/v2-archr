<?php
declare(strict_types=1);

/**
 * Email Notification Library for ARCHR
 * PHPMailer-compatible email system for confirmations and alerts
 */

class ARCHREmailer {
    private string $fromEmail;
    private string $fromName;
    private array $config;
    
    public function __construct() {
        $this->fromEmail = getenv('SMTP_FROM_EMAIL') ?: 'noreply@archr.org';
        $this->fromName = getenv('SMTP_FROM_NAME') ?: 'ARCHR Platform';
        
        $this->config = [
            'smtp_host' => getenv('SMTP_HOST') ?: 'localhost',
            'smtp_port' => (int)(getenv('SMTP_PORT') ?: 587),
            'smtp_user' => getenv('SMTP_USER') ?: '',
            'smtp_pass' => getenv('SMTP_PASS') ?: '',
            'smtp_secure' => getenv('SMTP_SECURE') ?: 'tls', // tls or ssl
        ];
    }
    
    /**
     * Send confirmation email to requestor
     */
    public function sendRequestorConfirmation(array $submissionData, array $credentials): bool {
        $to = $submissionData['contact_email'] ?? '';
        if (!$to || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
            error_log('[ARCHREmailer] Invalid email for requestor confirmation: ' . $to);
            return false;
        }
        
        $name = ($submissionData['applicant_first_name'] ?? '') . ' ' . ($submissionData['applicant_last_name'] ?? '');
        $caseNumber = $submissionData['case_number'] ?? 'N/A';
        
        $subject = 'ARCHR Application Received - ' . $caseNumber;
        
        $body = $this->buildRequestorConfirmationEmail($name, $caseNumber, $credentials, $submissionData);
        
        return $this->send($to, $name, $subject, $body);
    }
    
    /**
     * Send alert to admin/office staff
     */
    public function sendAdminAlert(array $submissionData): bool {
        $adminEmails = $this->getAdminEmails();
        if (empty($adminEmails)) {
            error_log('[ARCHREmailer] No admin emails configured');
            return false;
        }

        $caseNumber = $submissionData['case_number'] ?? 'N/A';
        $applicantName = ($submissionData['applicant_first_name'] ?? '') . ' ' . ($submissionData['applicant_last_name'] ?? '');

        $subject = '[ARCHR] New Application Received - ' . $caseNumber;
        $body = $this->buildAdminAlertEmail($applicantName, $caseNumber, $submissionData);

        $success = true;
        foreach ($adminEmails as $email => $name) {
            if (!$this->send($email, $name, $subject, $body)) {
                $success = false;
            }
        }

        return $success;
    }

    /**
     * Send support ticket notification to all Super Admins.
     *
     * @param int    $ticketId
     * @param string $category
     * @param string $subject
     * @param string $description
     * @param string $submitterName
     * @param string $submitterEmail
     * @param string $priority
     * @return bool
     */
    public function sendSupportTicketAlert(int $ticketId, string $category, string $subject, string $description, string $submitterName, string $submitterEmail, string $priority): bool {
        $superAdmins = $this->getSuperAdminEmails();
        if (empty($superAdmins)) {
            error_log('[ARCHREmailer] No super-admin emails found');
            return false;
        }

        $catLabels = [
            'bug' => '🐛 Bug Report',
            'feature_request' => '💡 Feature Request',
            'access_issue' => '🔑 Access Issue',
            'data_error' => '📊 Data Error',
            'general' => '❓ General Support',
        ];
        $catLabel = $catLabels[$category] ?? $category;

        $appUrl = getenv('APP_URL') ?: 'http://localhost/archr/repo/app';
        $ticketUrl = $appUrl . '/super-admin.php#helpdesk-tickets';

        $priTag = strtoupper($priority) !== 'NORMAL' ? "[{$priority}] " : '';

        $body = <<<EMAIL
NEW SUPPORT TICKET #{$ticketId}

{$priTag}{$catLabel}

Subject: {$subject}
From: {$submitterName} <{$submitterEmail}>
Priority: {$priority}

Description:
{$description}

--
View and manage tickets: {$ticketUrl}
This is an automated notification from the ARCHR support chat.
EMAIL;

        $mailSubject = "[ARCHR Support] {$priTag}{$subject} (#{$ticketId})";
        $success = true;
        foreach ($superAdmins as $email => $name) {
            if (!$this->send($email, $name, $mailSubject, $body)) {
                $success = false;
            }
        }

        return $success;
    }
    
    /**
     * Build requestor confirmation email body
     */
    private function buildRequestorConfirmationEmail(string $name, string $caseNumber, array $credentials, array $data): string {
        $username = $credentials['username'] ?? '';
        $password = $credentials['password'] ?? '';
        $dashboardUrl = getenv('APP_URL') ?: 'https://archr.org';
        $dashboardUrl .= '/requestor-portal.php';
        
        return <<<EMAIL
Dear $name,

Thank you for submitting your home repair application to the Asheville Regional Coalition for Home Repair (ARCHR).

APPLICATION DETAILS:
Case Number: $caseNumber
Submitted: {$data['submitted_at']}

NEXT STEPS:
Your application has been received and will be reviewed by our team. A member of an ARCHR Partner Organization's staff will reach out via your preferred contact method with next steps.

REQUESTOR PORTAL ACCESS:
You can track your application progress through our online portal:

Dashboard URL: $dashboardUrl
Username: $username
Password: $password

Please save these credentials in a secure location. You can log in at any time to:
- View your application status
- Upload required documents
- Communicate with your case worker
- Track repair progress

If you have any questions, please contact us through the portal or call our main office.

Thank you,
ARCHR Team
Asheville Regional Coalition for Home Repair
EMAIL;
    }
    
    /**
     * Build admin alert email body
     */
    private function buildAdminAlertEmail(string $applicantName, string $caseNumber, array $data): string {
        $address = $data['home_address'] ?? 'N/A';
        $city = $data['home_city'] ?? '';
        $zip = $data['home_zip'] ?? '';
        $urgentCount = $data['urgent_condition_count'] ?? 0;
        
        $urgentTag = $urgentCount > 0 ? "[URGENT: $urgentCount conditions] " : "";
        
        return <<<EMAIL
{$urgentTag}New Application Received

Case Number: $caseNumber
Applicant: $applicantName
Address: $address, $city $zip
Submitted: {$data['submitted_at']}

Urgent Conditions: $urgentCount

Please review this application in the admin queue:
{$_SERVER['HTTP_HOST']}/admin.php?view=queue

This is an automated notification. To disable these alerts, update your user profile settings.
EMAIL;
    }
    
    /**
     * Get admin emails from database or config
     */
    private function getAdminEmails(): array {
        // TODO: Query from database based on user preferences
        // For now, use environment variable
        $emails = getenv('ADMIN_ALERT_EMAILS');
        if (!$emails) {
            return [];
        }

        $result = [];
        foreach (explode(',', $emails) as $email) {
            $email = trim($email);
            if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $result[$email] = 'Admin';
            }
        }

        return $result;
    }

    /**
     * Get all active Super Admin user emails from the database.
     * Returns [email => full_name].
     */
    private function getSuperAdminEmails(): array {
        try {
            require_once __DIR__ . '/db.php';
            $pdo = archr_pdo();
            $stmt = $pdo->query("
                SELECT DISTINCT u.email, u.full_name
                  FROM system_users u
                  JOIN user_role_assignments ura ON ura.user_id = u.id AND ura.is_active = true
                  JOIN roles r ON r.id = ura.role_id
                 WHERE r.role_code = 'SUPER_ADMIN'
                   AND u.is_active = true
                   AND u.email IS NOT NULL AND u.email != ''
            ");
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $emails = [];
            foreach ($results as $row) {
                $emails[$row['email']] = $row['full_name'] ?: $row['email'];
            }
            return $emails;
        } catch (Throwable $e) {
            error_log('[ARCHREmailer] Failed to query super-admin emails: ' . $e->getMessage());
            return [];
        }
    }

    /**
     * Send email using PHP mail() function or SMTP
     * Compatible with PHPMailer configuration
     */
    private function send(string $to, string $toName, string $subject, string $body): bool {
        $headers = [
            'From: ' . $this->fromName . ' <' . $this->fromEmail . '>',
            'Reply-To: ' . $this->fromEmail,
            'X-Mailer: PHP/' . phpversion(),
            'MIME-Version: 1.0',
            'Content-Type: text/plain; charset=UTF-8'
        ];

        try {
            // Log email instead of sending in development (fallback)
            if (getenv('APP_ENV') === 'development' || (!$this->config['smtp_host'] && !$this->usesMailpit())) {
                $this->logEmail($to, $toName, $subject, $body);
                return true;
            }

            // If Mailpit is available, send via raw SMTP
            if ($this->usesMailpit()) {
                return $this->sendViaSMTP('127.0.0.1', 1025, $to, $toName, $subject, $body, $headers);
            }

            // Use PHP mail() function as last resort
            $success = mail(
                $toName . ' <' . $to . '>',
                $subject,
                $body,
                implode("\r\n", $headers)
            );

            if ($success) {
                error_log("[ARCHREmailer] Email sent to $to: $subject");
            } else {
                error_log("[ARCHREmailer] Failed to send email to $to: $subject");
            }

            return $success;
        } catch (Throwable $e) {
            error_log('[ARCHREmailer] Email error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Check if Mailpit SMTP is available on localhost:1025.
     */
    private function usesMailpit(): bool {
        try {
            $fp = @fsockopen('127.0.0.1', 1025, $errno, $errstr, 1);
            if ($fp) {
                fclose($fp);
                return true;
            }
        } catch (Throwable $_) {}
        return false;
    }

    /**
     * Send email via raw SMTP socket (no PHPMailer needed).
     * Works with Mailpit's unauthenticated local SMTP.
     */
    private function sendViaSMTP(string $host, int $port, string $to, string $toName, string $subject, string $body, array $headers): bool {
        $fp = @fsockopen($host, $port, $errno, $errstr, 3);
        if (!$fp) {
            error_log("[ARCHREmailer] SMTP connect failed: $errstr ($errno)");
            $this->logEmail($to, $toName, $subject, $body);
            return true; // Log as fallback
        }

        stream_set_timeout($fp, 5);

        $read = function() use ($fp) {
            $response = fgets($fp, 1024);
            if ($response !== false) {
                error_log("[ARCHREmailer] SMTP < " . trim($response));
            }
            return $response;
        };

        $write = function(string $cmd) use ($fp) {
            fwrite($fp, $cmd . "\r\n");
            error_log("[ARCHREmailer] SMTP > " . trim($cmd));
        };

        // Read greeting
        $read();

        // EHLO
        $write('EHLO localhost');
        $read();

        // MAIL FROM
        $write('MAIL FROM: <' . $this->fromEmail . '>');
        $read();

        // RCPT TO
        $write('RCPT TO: <' . $to . '>');
        $read();

        // DATA
        $write('DATA');
        $read();

        // Headers + body
        $data = implode("\r\n", $headers) . "\r\n";
        $data .= 'To: ' . $toName . ' <' . $to . ">\r\n";
        $data .= 'Subject: ' . $subject . "\r\n";
        $data .= "\r\n" . $body . "\r\n.\r\n";
        $write(rtrim($data));
        $read();

        // QUIT
        $write('QUIT');
        fclose($fp);

        error_log("[ARCHREmailer] Email sent via SMTP to $to: $subject");
        return true;
    }

    /**
     * Log email for development/testing
     */
    private function logEmail(string $to, string $toName, string $subject, string $body): void {
        $logDir = __DIR__ . '/../logs';
        if (!is_dir($logDir)) {
            @mkdir($logDir, 0750, true);
        }

        // Human-readable text log
        $logFile = $logDir . '/emails.log';
        $entry = sprintf(
            "[%s] TO: %s <%s> | SUBJECT: %s\n%s\n%s\n\n",
            date('Y-m-d H:i:s'),
            $toName,
            $to,
            $subject,
            str_repeat('-', 80),
            $body
        );
        @file_put_contents($logFile, $entry, FILE_APPEND | LOCK_EX);

        // JSON log for easy viewing
        $jsonLogFile = $logDir . '/emails.json';

        // Read existing emails
        $emails = [];
        if (file_exists($jsonLogFile)) {
            $existing = @file_get_contents($jsonLogFile);
            if ($existing) {
                $emails = json_decode($existing, true) ?: [];
            }
        }

        // Add new email
        $emails[] = [
            'timestamp' => date('Y-m-d H:i:s'),
            'to' => $to,
            'to_name' => $toName,
            'subject' => $subject,
            'body' => $body,
            'type' => $this->getEmailType($subject),
        ];

        // Keep only last 100 emails
        if (count($emails) > 100) {
            $emails = array_slice($emails, -100);
        }

        // Write back
        @file_put_contents(
            $jsonLogFile,
            json_encode($emails, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT),
            LOCK_EX
        );

        error_log("[ARCHREmailer] Email logged (dev mode): $to - $subject");
    }

    /**
     * Determine email type from subject
     */
    private function getEmailType(string $subject): string {
        if (stripos($subject, 'New Application') !== false || stripos($subject, '[ARCHR]') !== false) {
            return 'admin_alert';
        }
        if (stripos($subject, 'Application Received') !== false || stripos($subject, 'Confirmation') !== false) {
            return 'requestor_confirmation';
        }
        if (stripos($subject, '[ARCHR Support]') !== false || stripos($subject, 'Support Ticket') !== false) {
            return 'support_ticket_alert';
        }
        return 'other';
    }
}
