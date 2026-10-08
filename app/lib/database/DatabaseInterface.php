<?php
declare(strict_types=1);

/**
 * Database Interface
 * 
 * Common interface for both PostgreSQL and Airtable implementations.
 * This allows the application to switch between databases seamlessly.
 */

interface DatabaseInterface {
    /**
     * Query records from a table
     * 
     * @param string $table Table name
     * @param array<string, mixed> $filters Filters to apply (e.g., ['status' => 'active'])
     * @param array<string> $fields Fields to return (empty = all fields)
     * @param int $limit Maximum number of records to return
     * @param int $offset Offset for pagination
     * @return array<array<string, mixed>> Array of records
     */
    public function select(
        string $table,
        array $filters = [],
        array $fields = [],
        int $limit = 100,
        int $offset = 0
    ): array;
    
    /**
     * Get a single record by ID
     * 
     * @param string $table Table name
     * @param string|int $id Record ID
     * @return array<string, mixed>|null Record data or null if not found
     */
    public function find(string $table, $id): ?array;
    
    /**
     * Insert a new record
     * 
     * @param string $table Table name
     * @param array<string, mixed> $data Record data
     * @return string|int ID of the created record
     */
    public function insert(string $table, array $data);
    
    /**
     * Update an existing record
     * 
     * @param string $table Table name
     * @param string|int $id Record ID
     * @param array<string, mixed> $data Fields to update
     * @return bool Success
     */
    public function update(string $table, $id, array $data): bool;
    
    /**
     * Delete a record
     * 
     * @param string $table Table name
     * @param string|int $id Record ID
     * @return bool Success
     */
    public function delete(string $table, $id): bool;
    
    /**
     * Count records matching filters
     * 
     * @param string $table Table name
     * @param array<string, mixed> $filters Filters to apply
     * @return int Number of matching records
     */
    public function count(string $table, array $filters = []): int;
    
    /**
     * Execute a raw query (database-specific)
     * 
     * For PostgreSQL: SQL query
     * For Airtable: This may have limited support
     * 
     * @param string $query Query string
     * @param array<mixed> $params Query parameters
     * @return mixed Query result
     */
    public function raw(string $query, array $params = []);
    
    /**
     * Begin a transaction (if supported)
     */
    public function beginTransaction(): void;
    
    /**
     * Commit a transaction (if supported)
     */
    public function commit(): void;
    
    /**
     * Rollback a transaction (if supported)
     */
    public function rollback(): void;
    
    /**
     * Get the underlying connection object
     * 
     * For PostgreSQL: Returns PDO instance
     * For Airtable: Returns Airtable client
     * 
     * @return mixed
     */
    public function getConnection();
}
