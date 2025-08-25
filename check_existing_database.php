<?php
// Check existing database structure and data

echo "🔍 Checking Existing Nine27 Pharmacy Database...\n\n";

try {
    // Database connection details from .env
    $host = '127.0.0.1';
    $port = '3306';
    $database = 'nine27_pharmacy';
    $username = 'nine27_user';
    $password = 'nine27_password';

    // Try to connect
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connected to MySQL database: $database\n\n";
    
    // Check if tables exist
    $tables = ['users', 'products', 'orders', 'order_items'];
    
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            echo "✅ Table '$table' exists\n";
            
            // Get row count
            $countStmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
            $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "   📊 Records: $count\n";
            
            // Show structure for products table
            if ($table === 'products') {
                echo "   📋 Structure:\n";
                $structStmt = $pdo->query("DESCRIBE $table");
                while ($row = $structStmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "      - {$row['Field']} ({$row['Type']})\n";
                }
                
                // Show sample data
                if ($count > 0) {
                    echo "   📦 Sample products:\n";
                    $sampleStmt = $pdo->query("SELECT id, name, price, category FROM $table LIMIT 5");
                    while ($row = $sampleStmt->fetch(PDO::FETCH_ASSOC)) {
                        echo "      - {$row['name']} (₱{$row['price']}) - {$row['category']}\n";
                    }
                }
            }
            echo "\n";
        } else {
            echo "❌ Table '$table' does not exist\n\n";
        }
    }
    
    // Check if products table has the right structure
    $stmt = $pdo->query("SHOW TABLES LIKE 'products'");
    if ($stmt->rowCount() > 0) {
        echo "🔧 Checking products table structure...\n";
        
        $requiredColumns = [
            'id', 'name', 'description', 'price', 'image', 'category', 
            'brand', 'sku', 'stock_quantity', 'is_available', 'requires_prescription',
            'dosage', 'active_ingredient', 'manufacturer', 'rating', 'review_count'
        ];
        
        $existingColumns = [];
        $structStmt = $pdo->query("DESCRIBE products");
        while ($row = $structStmt->fetch(PDO::FETCH_ASSOC)) {
            $existingColumns[] = $row['Field'];
        }
        
        $missingColumns = array_diff($requiredColumns, $existingColumns);
        
        if (empty($missingColumns)) {
            echo "✅ Products table has all required columns\n";
        } else {
            echo "⚠️  Missing columns in products table:\n";
            foreach ($missingColumns as $column) {
                echo "   - $column\n";
            }
            echo "\n💡 You may need to run migrations or alter the table\n";
        }
    }
    
    echo "\n🎯 Summary:\n";
    echo "Database: $database\n";
    echo "Connection: ✅ Working\n";
    echo "Tables: " . implode(', ', $tables) . "\n";
    
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n\n";
    
    echo "💡 Possible solutions:\n";
    echo "1. Make sure MySQL server is running\n";
    echo "2. Check database credentials in .env file\n";
    echo "3. Create database: CREATE DATABASE nine27_pharmacy;\n";
    echo "4. Create user: CREATE USER 'nine27_user'@'localhost' IDENTIFIED BY 'nine27_password';\n";
    echo "5. Grant permissions: GRANT ALL PRIVILEGES ON nine27_pharmacy.* TO 'nine27_user'@'localhost';\n";
}
?>