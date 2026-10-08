<?php
declare(strict_types=1);

require_once __DIR__ . '/DatabaseInterface.php';

/**
 * PostgreSQL Database Adapter
 * 
 * Implements the DatabaseInterface using PDO for PostgreSQL
 */
class PostgreSQLDatabase implements DatabaseInterface {
    private PDO $pdo;
    
    public function __construct(array $config) {
        $dsn = sprintf(
            "pgsql:host=%s;port=%s;dbname=%s",
            $config['host'],
            $config['port'],
            $config['database']
        );
        
        $this->pdo = new PDO(
            $dsn,
            $config['user'],
            $config['password'],
            [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]
        );
    }
    
    public function select(
        string $table,
        array $filters = [],
        array $fields = [],
        int $limit = 100,
        int $offset = 0
    ): array {
        $fieldList = empty($fields) ? '*' : implode(', ', array_map(fn($f) => "\"{$f}\"", $fields));
        $sql = "SELECT {$fieldList} FROM \"{$table}\"";
        
        $whereParts = [];
        $params = [];
        
        foreach ($filters as $key => $value) {
            if ($value === null) {
                $whereParts[] = "\"{$key}\" IS NULL";
            } else {
                $whereParts[] = "\"{$key}\" = ?";
                $params[] = $value;
            }
        }
        
        if (!empty($whereParts)) {
            $sql .= " WHERE " . implode(' AND ', $whereParts);
        }
        
        $sql .= " LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        
        return $stmt->fetchAll();
    }
    
    public function find(string $table, $id): ?array {
        $stmt = $this->pdo->prepare("SELECT * FROM \"{$table}\" WHERE id = ? LIMIT 1");
        $stmt->execute([$id]);
        
        $result = $stmt->fetch();
        return $result ?: null;
    }
    
    public function insert(string $table, array $data) {
        $fields = array_keys($data);
        $placeholders = array_fill(0, count($fields), '?');
        
        $sql = sprintf(
            'INSERT INTO "%s" (%s) VALUES (%s) RETURNING id',
            $table,
            implode(', ', array_map(fn($f) => "\"{$f}\"", $fields)),
            implode(', ', $placeholders)
        );
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(array_values($data));
        
        $result = $stmt->fetch();
        return $result['id'];
    }
    
    public function update(string $table, $id, array $data): bool {
        $setParts = [];
        $params = [];
        
        foreach ($data as $key => $value) {
            $setParts[] = "\"{$key}\" = ?";
            $params[] = $value;
        }
        
        $params[] = $id;
        
        $sql = sprintf(
            'UPDATE "%s" SET %s WHERE id = ?',
            $table,
            implode(', ', $setParts)
        );
        
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute($params);
    }
    
    public function delete(string $table, $id): bool {
        $stmt = $this->pdo->prepare("DELETE FROM \"{$table}\" WHERE id = ?");
        return $stmt->execute([$id]);
    }
    
    public function count(string $table, array $filters = []): int {
        $sql = "SELECT COUNT(*) as count FROM \"{$table}\"";
        
        $whereParts = [];
        $params = [];
        
        foreach ($filters as $key => $value) {
            if ($value === null) {
                $whereParts[] = "\"{$key}\" IS NULL";
            } else {
                $whereParts[] = "\"{$key}\" = ?";
                $params[] = $value;
            }
        }
        
        if (!empty($whereParts)) {
            $sql .= " WHERE " . implode(' AND ', $whereParts);
        }
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        
        $result = $stmt->fetch();
        return (int)$result['count'];
    }
    
    public function raw(string $query, array $params = []) {
        $stmt = $this->pdo->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }
    
    public function beginTransaction(): void {
        $this->pdo->beginTransaction();
    }
    
    public function commit(): void {
        $this->pdo->commit();
    }
    
    public function rollback(): void {
        $this->pdo->rollBack();
    }
    
    public function getConnection() {
        return $this->pdo;
    }
}
