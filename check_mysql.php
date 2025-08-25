<?php
echo "🔍 Checking MySQL Connection and Database...\n\n";

// Try different connection methods
$connections = [
    ['host' => '127.0.0.1', 'user' => 'nine27_user', 'pass' => 'nine27_password', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => '', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'root', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'password', 'db' => 'nine27_pharmacy'],
];

$connected = false;
$workingConnection = null;

foreach ($connections as $conn) {
    try {
        echo "Trying: {$conn['user']}@{$conn['host']}...\n";
        $pdo = new PDO("mysql:host={$conn['host']};port=3306", $conn['user'], $conn['pass']);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        echo "✅ Connected to MySQL server with {$conn['user']}\n";
        
        // Check if database exists
        $stmt = $pdo->query("SHOW DATABASES LIKE '{$conn['db']}'");
        if ($stmt->rowCount() > 0) {
            echo "✅ Database '{$conn['db']}' exists\n";
        } else {
            echo "❌ Database '{$conn['db']}' does not exist\n";
            echo "Creating database...\n";
            $pdo->exec("CREATE DATABASE {$conn['db']}");
            echo "✅ Database '{$conn['db']}' created\n";
        }
        
        // Connect to the specific database
        $pdo = new PDO("mysql:host={$conn['host']};port=3306;dbname={$conn['db']}", $conn['user'], $conn['pass']);
        
        // Check if products table exists
        $stmt = $pdo->query("SHOW TABLES LIKE 'products'");
        if ($stmt->rowCount() > 0) {
            echo "✅ Products table exists\n";
            $countStmt = $pdo->query("SELECT COUNT(*) as count FROM products");
            $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "📦 Products count: $count\n";
        } else {
            echo "❌ Products table does not exist\n";
        }
        
        $connected = true;
        $workingConnection = $conn;
        break;
        
    } catch (PDOException $e) {
        echo "❌ Failed: " . $e->getMessage() . "\n";
    }
    echo "\n";
}

if ($connected && $workingConnection) {
    echo "🎯 Working connection found!\n";
    echo "Host: {$workingConnection['host']}\n";
    echo "User: {$workingConnection['user']}\n";
    echo "Database: {$workingConnection['db']}\n\n";
    
    // Now create the products table
    try {
        $pdo = new PDO("mysql:host={$workingConnection['host']};port=3306;dbname={$workingConnection['db']}", 
                      $workingConnection['user'], $workingConnection['pass']);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        echo "🔧 Creating products table...\n";
        
        $createTable = "
        CREATE TABLE IF NOT EXISTS products (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            image VARCHAR(255),
            category VARCHAR(100) NOT NULL,
            brand VARCHAR(100),
            sku VARCHAR(100) UNIQUE,
            stock_quantity INT DEFAULT 0,
            is_available BOOLEAN DEFAULT TRUE,
            requires_prescription BOOLEAN DEFAULT FALSE,
            dosage VARCHAR(50),
            active_ingredient VARCHAR(255),
            manufacturer VARCHAR(255),
            expiry_date DATE,
            rating DECIMAL(3,1),
            review_count INT DEFAULT 0,
            tags JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )";
        
        $pdo->exec($createTable);
        echo "✅ Products table created\n";
        
        // Insert sample data
        echo "📦 Inserting sample products...\n";
        
        $products = [
            ['Biogesic 500mg', 'Paracetamol 500mg tablet for fever and pain relief', 50.00, 'assets/img/biogesic.jpg', 'medicines', 'Unilab', 'BIO-500-20', 150, 1, 0, '500mg', 'Paracetamol', 'Unilab', 4.5, 128],
            ['Advil 200mg', 'Ibuprofen tablets for pain relief and inflammation', 75.00, 'assets/img/advil.jpg', 'medicines', 'Pfizer', 'ADV-200-20', 120, 1, 0, '200mg', 'Ibuprofen', 'Pfizer', 4.4, 95],
            ['Vitamin C 500mg', 'High-potency Vitamin C supplement for immune system support', 15.00, 'assets/img/vitamin-c.jpg', 'vitamins', 'Centrum', 'VIT-C-500-30', 200, 1, 0, '500mg', 'Ascorbic Acid', 'Pfizer', 4.3, 89],
            ['Betadine Solution 60ml', 'Antiseptic solution for wound cleaning and disinfection', 85.00, 'assets/img/betadine.jpg', 'first_aid', 'Betadine', 'BET-SOL-60', 75, 1, 0, null, 'Povidone Iodine', 'Mundipharma', 4.7, 156],
            ['Amoxicillin 500mg', 'Antibiotic capsule for bacterial infections', 25.00, 'assets/img/amoxicillin.jpg', 'prescription_drugs', 'Generics', 'AMX-500-21', 100, 1, 1, '500mg', 'Amoxicillin', 'Generics Pharmacy', 4.2, 67]
        ];
        
        $stmt = $pdo->prepare("
            INSERT INTO products (name, description, price, image, category, brand, sku, stock_quantity, is_available, requires_prescription, dosage, active_ingredient, manufacturer, rating, review_count) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        foreach ($products as $product) {
            $stmt->execute($product);
        }
        
        $count = count($products);
        echo "✅ Inserted $count sample products\n";
        
        // Verify
        $countStmt = $pdo->query("SELECT COUNT(*) as count FROM products");
        $totalCount = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "📊 Total products in database: $totalCount\n";
        
        echo "\n🎉 Database setup complete!\n";
        echo "🔧 Update your Laravel .env file with these credentials:\n";
        echo "DB_HOST={$workingConnection['host']}\n";
        echo "DB_DATABASE={$workingConnection['db']}\n";
        echo "DB_USERNAME={$workingConnection['user']}\n";
        echo "DB_PASSWORD={$workingConnection['pass']}\n";
        
    } catch (PDOException $e) {
        echo "❌ Error creating table: " . $e->getMessage() . "\n";
    }
    
} else {
    echo "❌ Could not connect to MySQL server\n";
    echo "💡 Please check:\n";
    echo "1. MySQL server is running\n";
    echo "2. Correct username/password\n";
    echo "3. Try: mysql -u root -p\n";
}
?>