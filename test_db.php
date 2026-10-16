<?php
try {
    $dbh = new PDO(
        "pgsql:host=127.0.0.1;port=5432;dbname=archr", 
        "postgres", 
        getenv("PGPASSWORD")
    );
    $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Database connection successful!";
} catch (PDOException $e) {
    echo "Database connection failed: " . $e->getMessage();
}