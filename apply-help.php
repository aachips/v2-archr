<?php
/**
 * apply-help.php — standalone intake form entry point
 *
 * Serves the Vue-powered intake form at a clean URL:
 *   v2-archr.test/apply-help.php
 *
 * This is public-facing (no auth required) and is the target for
 * QR codes, flyers, and referral links.
 */
$built = __DIR__ . '/vue-view/dist-intake/intake.html';
if (file_exists($built)) {
    header('Content-Type: text/html; charset=UTF-8');
    readfile($built);
    exit;
}

// Fallback if build doesn't exist yet
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ARCHR — Apply for Home Repair Assistance</title>
</head>
<body>
    <p style="text-align:center;padding:2rem;">Intake form is being set up. Please try again shortly.</p>
</body>
</html>
