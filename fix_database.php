<?php
echo "🔧 Fixing Nine27 Pharmacy Database - Creating Products Table\n";
echo "========================================================\n\n";

// Try different MySQL connection combinations
$connections = [
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => '', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'root', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'password', 'db' => 'nine27_pharmacy'],
    ['host' => '127.0.0.1', 'user' => 'nine27_user', 'pass' => 'nine27_password', 'db' => 'nine27_pharmacy'],
    ['host' => 'localhost', 'user' => 'root', 'pass' => '', 'db' => 'nine27_pharmacy'],
];

$success = false;

foreach ($connections as $i => $conn) {
    echo "Attempt " . ($i + 1) . ": Trying {$conn['user']}@{$conn['host']}...\n";
    
    try {
        // First connect without database to create it if needed
        $pdo = new PDO("mysql:host={$conn['host']};port=3306", $conn['user'], $conn['pass']);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        echo "✅ Connected to MySQL server\n";
        
        // Create database if it doesn't exist
        $pdo->exec("CREATE DATABASE IF NOT EXISTS {$conn['db']}");
        echo "✅ Database '{$conn['db']}' ready\n";
        
        // Connect to the specific database
        $pdo = new PDO("mysql:host={$conn['host']};port=3306;dbname={$conn['db']}", $conn['user'], $conn['pass']);
        
        // Create products table
        echo "📋 Creating products table...\n";
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
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            
            INDEX idx_category (category),
            INDEX idx_available (is_available)
        )";
        
        $pdo->exec($createTable);
        echo "✅ Products table created successfully\n";
        
        // Insert sample products
        echo "📦 Inserting sample medicine data...\n";
        
        // Clear existing data first
        $pdo->exec("DELETE FROM products");
        
        $products = [
            // Medicines
            ['Biogesic 500mg', 'Paracetamol 500mg tablet for fever and pain relief', 50.00, 'assets/img/biogesic.jpg', 'medicines', 'Unilab', 'BIO-500-20', 150, 1, 0, '500mg', 'Paracetamol', 'Unilab', 4.5, 128],
            ['Advil 200mg', 'Ibuprofen tablets for pain relief and inflammation', 75.00, 'assets/img/advil.jpg', 'medicines', 'Pfizer', 'ADV-200-20', 120, 1, 0, '200mg', 'Ibuprofen', 'Pfizer', 4.4, 95],
            ['Tylenol 500mg', 'Acetaminophen tablets for fever and pain relief', 65.00, 'assets/img/tylenol.jpg', 'medicines', 'Johnson & Johnson', 'TYL-500-24', 80, 1, 0, '500mg', 'Acetaminophen', 'Johnson & Johnson', 4.6, 142],
            ['Aspirin 325mg', 'Low-dose aspirin for heart health and pain relief', 35.00, 'assets/img/aspirin.jpg', 'medicines', 'Bayer', 'ASP-325-100', 200, 1, 0, '325mg', 'Acetylsalicylic Acid', 'Bayer', 4.3, 78],
            ['Mefenamic Acid 500mg', 'Anti-inflammatory medicine for pain and fever', 45.00, 'assets/img/mefenamic.jpg', 'medicines', 'Generics', 'MEF-500-10', 90, 1, 0, '500mg', 'Mefenamic Acid', 'Generics Pharmacy', 4.2, 67],
            
            // Vitamins
            ['Vitamin C 500mg', 'High-potency Vitamin C supplement for immune system support', 15.00, 'assets/img/vitamin-c.jpg', 'vitamins', 'Centrum', 'VIT-C-500-30', 200, 1, 0, '500mg', 'Ascorbic Acid', 'Pfizer', 4.3, 89],
            ['Multivitamins Complete', 'Complete daily multivitamin with minerals', 450.00, 'assets/img/multivitamins.jpg', 'vitamins', 'Centrum', 'MUL-COM-30', 60, 1, 0, null, null, 'Pfizer', 4.5, 203],
            ['Vitamin D3 1000IU', 'High-potency Vitamin D3 for bone health', 320.00, 'assets/img/vitamin-d3.jpg', 'vitamins', 'Nature Made', 'VIT-D3-1000-60', 90, 1, 0, '1000IU', 'Cholecalciferol', 'Nature Made', 4.7, 156],
            ['Omega-3 Fish Oil', 'Premium fish oil capsules for heart and brain health', 680.00, 'assets/img/omega3.jpg', 'vitamins', 'Nordic Naturals', 'OME-3-120', 45, 1, 0, null, null, 'Nordic Naturals', 4.8, 234],
            ['Calcium + Vitamin D', 'Calcium supplement with Vitamin D for bone strength', 280.00, 'assets/img/calcium.jpg', 'vitamins', 'Caltrate', 'CAL-VD-60', 75, 1, 0, null, null, 'Pfizer', 4.4, 112],
            
            // First Aid
            ['Betadine Solution 60ml', 'Antiseptic solution for wound cleaning and disinfection', 85.00, 'assets/img/betadine.jpg', 'first_aid', 'Betadine', 'BET-SOL-60', 75, 1, 0, null, 'Povidone Iodine', 'Mundipharma', 4.7, 156],
            ['Alcohol 70% 500ml', 'Isopropyl alcohol for disinfection and cleaning', 45.00, 'assets/img/alcohol.jpg', 'first_aid', 'Green Cross', 'ALC-70-500', 150, 1, 0, null, 'Isopropyl Alcohol', 'Green Cross', 4.2, 67],
            ['Band-Aid Adhesive Bandages', 'Sterile adhesive bandages for wound protection', 125.00, 'assets/img/bandaid.jpg', 'first_aid', 'Band-Aid', 'BND-AID-50', 200, 1, 0, null, null, 'Johnson & Johnson', 4.6, 189],
            ['Hydrogen Peroxide 3%', 'Antiseptic solution for wound cleaning', 35.00, 'assets/img/hydrogen-peroxide.jpg', 'first_aid', 'Generic', 'HYD-PER-250', 100, 1, 0, null, 'Hydrogen Peroxide', 'Generic Pharma', 4.1, 45],
            
            // Prescription Drugs
            ['Amoxicillin 500mg', 'Antibiotic capsule for bacterial infections', 25.00, 'assets/img/amoxicillin.jpg', 'prescription_drugs', 'Generics', 'AMX-500-21', 100, 1, 1, '500mg', 'Amoxicillin', 'Generics Pharmacy', 4.2, 67],
            ['Losartan 50mg', 'ACE inhibitor for high blood pressure', 180.00, 'assets/img/losartan.jpg', 'prescription_drugs', 'Generics', 'LOS-50-30', 60, 1, 1, '50mg', 'Losartan Potassium', 'Generics Pharmacy', 4.4, 89],
            ['Metformin 500mg', 'Diabetes medication for blood sugar control', 95.00, 'assets/img/metformin.jpg', 'prescription_drugs', 'Generics', 'MET-500-30', 80, 1, 1, '500mg', 'Metformin HCl', 'Generics Pharmacy', 4.3, 112],
        ];
        
        $stmt = $pdo->prepare("
            INSERT INTO products (name, description, price, image, category, brand, sku, stock_quantity, is_available, requires_prescription, dosage, active_ingredient, manufacturer, rating, review_count) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        foreach ($products as $product) {
            $stmt->execute($product);
        }
        
        echo "✅ Inserted " . count($products) . " products\n";
        
        // Verify the data
        $result = $pdo->query("SELECT COUNT(*) as count FROM products");
        $count = $result->fetch(PDO::FETCH_ASSOC)['count'];
        echo "📊 Total products in database: $count\n";
        
        // Show breakdown by category
        $result = $pdo->query("SELECT category, COUNT(*) as count FROM products GROUP BY category");
        echo "\n📋 Products by category:\n";
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            echo "   {$row['category']}: {$row['count']} items\n";
        }
        
        echo "\n🎉 SUCCESS! Database is ready!\n";
        echo "🔧 Make sure your Laravel .env file has:\n";
        echo "DB_HOST={$conn['host']}\n";
        echo "DB_DATABASE={$conn['db']}\n";
        echo "DB_USERNAME={$conn['user']}\n";
        echo "DB_PASSWORD={$conn['pass']}\n\n";
        
        echo "🚀 Next steps:\n";
        echo "1. Start Laravel server: cd nine27-pharmacy-backend && php artisan serve --host=0.0.0.0 --port=8000\n";
        echo "2. Test API: http://localhost:8000/api/products\n";
        echo "3. Restart Flutter app: flutter hot restart\n";
        
        $success = true;
        break;
        
    } catch (PDOException $e) {
        echo "❌ Failed: " . $e->getMessage() . "\n\n";
        continue;
    }
}

if (!$success) {
    echo "❌ Could not connect to MySQL with any credentials\n\n";
    echo "💡 Troubleshooting steps:\n";
    echo "1. Make sure MySQL/XAMPP/WAMP is running\n";
    echo "2. Try opening MySQL command line: mysql -u root -p\n";
    echo "3. Check if you can access phpMyAdmin\n";
    echo "4. Verify MySQL service is started\n";
    echo "5. Try different root passwords: '', 'root', 'password'\n";
}
?>