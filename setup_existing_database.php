<?php
// Setup existing database with proper structure and data

echo "🔧 Setting up Nine27 Pharmacy Database...\n\n";

try {
    // Database connection details
    $host = '127.0.0.1';
    $port = '3306';
    $database = 'nine27_pharmacy';
    $username = 'nine27_user';
    $password = 'nine27_password';

    // Connect to MySQL server first (without database)
    try {
        $pdo = new PDO("mysql:host=$host;port=$port", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "✅ Connected to MySQL server\n";
    } catch (PDOException $e) {
        // Try with root if user doesn't exist
        echo "⚠️  Trying with root user...\n";
        $pdo = new PDO("mysql:host=$host;port=$port", 'root', '');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Create database and user
        $pdo->exec("CREATE DATABASE IF NOT EXISTS $database");
        $pdo->exec("CREATE USER IF NOT EXISTS '$username'@'localhost' IDENTIFIED BY '$password'");
        $pdo->exec("GRANT ALL PRIVILEGES ON $database.* TO '$username'@'localhost'");
        $pdo->exec("FLUSH PRIVILEGES");
        echo "✅ Created database and user\n";
    }

    // Connect to the specific database
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Connected to database: $database\n\n";

    // Create users table
    echo "📋 Creating users table...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS users (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            email_verified_at TIMESTAMP NULL,
            password VARCHAR(255) NOT NULL,
            mobile VARCHAR(20),
            address TEXT,
            remember_token VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ");
    echo "✅ Users table ready\n";

    // Create products table
    echo "📋 Creating products table...\n";
    $pdo->exec("
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
            INDEX idx_available (is_available),
            INDEX idx_prescription (requires_prescription),
            INDEX idx_category_available (category, is_available),
            INDEX idx_rating (rating, review_count)
        )
    ");
    echo "✅ Products table ready\n";

    // Create orders table
    echo "📋 Creating orders table...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS orders (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            user_id BIGINT UNSIGNED NOT NULL,
            order_number VARCHAR(50) UNIQUE NOT NULL,
            status VARCHAR(50) NOT NULL DEFAULT 'pending',
            total_amount DECIMAL(10,2) NOT NULL,
            items_count INT NOT NULL,
            order_type VARCHAR(50) DEFAULT 'regular',
            category VARCHAR(100),
            delivery_address TEXT NOT NULL,
            payment_method VARCHAR(50) NOT NULL,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_user_id (user_id),
            INDEX idx_status (status),
            INDEX idx_order_number (order_number)
        )
    ");
    echo "✅ Orders table ready\n";

    // Create order_items table
    echo "📋 Creating order_items table...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS order_items (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            order_id BIGINT UNSIGNED NOT NULL,
            product_name VARCHAR(255) NOT NULL,
            product_price DECIMAL(10,2) NOT NULL,
            quantity INT NOT NULL,
            product_image VARCHAR(255),
            product_description TEXT,
            product_category VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            
            FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
            INDEX idx_order_id (order_id)
        )
    ");
    echo "✅ Order items table ready\n";

    // Clear existing products and insert sample data
    echo "\n📦 Inserting sample medicine data...\n";
    $pdo->exec("DELETE FROM products");

    $products = [
        // Medicines
        [
            'name' => 'Biogesic 500mg',
            'description' => 'Paracetamol 500mg tablet for fever and pain relief',
            'price' => 50.00,
            'image' => 'assets/img/biogesic.jpg',
            'category' => 'medicines',
            'brand' => 'Unilab',
            'sku' => 'BIO-500-20',
            'stock_quantity' => 150,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '500mg',
            'active_ingredient' => 'Paracetamol',
            'manufacturer' => 'Unilab',
            'rating' => 4.5,
            'review_count' => 128,
            'tags' => '["pain relief", "fever", "headache"]'
        ],
        [
            'name' => 'Advil 200mg',
            'description' => 'Ibuprofen tablets for pain relief and inflammation',
            'price' => 75.00,
            'image' => 'assets/img/advil.jpg',
            'category' => 'medicines',
            'brand' => 'Pfizer',
            'sku' => 'ADV-200-20',
            'stock_quantity' => 120,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '200mg',
            'active_ingredient' => 'Ibuprofen',
            'manufacturer' => 'Pfizer',
            'rating' => 4.4,
            'review_count' => 95,
            'tags' => '["pain relief", "inflammation", "fever"]'
        ],
        [
            'name' => 'Tylenol 500mg',
            'description' => 'Acetaminophen tablets for fever and pain relief',
            'price' => 65.00,
            'image' => 'assets/img/tylenol.jpg',
            'category' => 'medicines',
            'brand' => 'Johnson & Johnson',
            'sku' => 'TYL-500-24',
            'stock_quantity' => 80,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '500mg',
            'active_ingredient' => 'Acetaminophen',
            'manufacturer' => 'Johnson & Johnson',
            'rating' => 4.6,
            'review_count' => 142,
            'tags' => '["pain relief", "fever", "safe"]'
        ],
        [
            'name' => 'Aspirin 325mg',
            'description' => 'Low-dose aspirin for heart health and pain relief',
            'price' => 35.00,
            'image' => 'assets/img/aspirin.jpg',
            'category' => 'medicines',
            'brand' => 'Bayer',
            'sku' => 'ASP-325-100',
            'stock_quantity' => 200,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '325mg',
            'active_ingredient' => 'Acetylsalicylic Acid',
            'manufacturer' => 'Bayer',
            'rating' => 4.3,
            'review_count' => 78,
            'tags' => '["heart health", "pain relief", "blood thinner"]'
        ],
        [
            'name' => 'Mefenamic Acid 500mg',
            'description' => 'Anti-inflammatory medicine for pain and fever',
            'price' => 45.00,
            'image' => 'assets/img/mefenamic.jpg',
            'category' => 'medicines',
            'brand' => 'Generics',
            'sku' => 'MEF-500-10',
            'stock_quantity' => 90,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '500mg',
            'active_ingredient' => 'Mefenamic Acid',
            'manufacturer' => 'Generics Pharmacy',
            'rating' => 4.2,
            'review_count' => 67,
            'tags' => '["pain relief", "inflammation", "menstrual pain"]'
        ],

        // Vitamins
        [
            'name' => 'Vitamin C 500mg',
            'description' => 'High-potency Vitamin C supplement for immune system support',
            'price' => 15.00,
            'image' => 'assets/img/vitamin-c.jpg',
            'category' => 'vitamins',
            'brand' => 'Centrum',
            'sku' => 'VIT-C-500-30',
            'stock_quantity' => 200,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '500mg',
            'active_ingredient' => 'Ascorbic Acid',
            'manufacturer' => 'Pfizer',
            'rating' => 4.3,
            'review_count' => 89,
            'tags' => '["vitamin", "immunity", "antioxidant"]'
        ],
        [
            'name' => 'Multivitamins Complete',
            'description' => 'Complete daily multivitamin with minerals',
            'price' => 450.00,
            'image' => 'assets/img/multivitamins.jpg',
            'category' => 'vitamins',
            'brand' => 'Centrum',
            'sku' => 'MUL-COM-30',
            'stock_quantity' => 60,
            'is_available' => 1,
            'requires_prescription' => 0,
            'manufacturer' => 'Pfizer',
            'rating' => 4.5,
            'review_count' => 203,
            'tags' => '["multivitamin", "daily nutrition", "minerals"]'
        ],
        [
            'name' => 'Vitamin D3 1000IU',
            'description' => 'High-potency Vitamin D3 for bone health',
            'price' => 320.00,
            'image' => 'assets/img/vitamin-d3.jpg',
            'category' => 'vitamins',
            'brand' => 'Nature Made',
            'sku' => 'VIT-D3-1000-60',
            'stock_quantity' => 90,
            'is_available' => 1,
            'requires_prescription' => 0,
            'dosage' => '1000IU',
            'active_ingredient' => 'Cholecalciferol',
            'manufacturer' => 'Nature Made',
            'rating' => 4.7,
            'review_count' => 156,
            'tags' => '["vitamin d", "bone health", "immunity"]'
        ],
        [
            'name' => 'Omega-3 Fish Oil',
            'description' => 'Premium fish oil capsules for heart and brain health',
            'price' => 680.00,
            'image' => 'assets/img/omega3.jpg',
            'category' => 'vitamins',
            'brand' => 'Nordic Naturals',
            'sku' => 'OME-3-120',
            'stock_quantity' => 45,
            'is_available' => 1,
            'requires_prescription' => 0,
            'manufacturer' => 'Nordic Naturals',
            'rating' => 4.8,
            'review_count' => 234,
            'tags' => '["omega 3", "heart health", "brain health"]'
        ],
        [
            'name' => 'Calcium + Vitamin D',
            'description' => 'Calcium supplement with Vitamin D for bone strength',
            'price' => 280.00,
            'image' => 'assets/img/calcium.jpg',
            'category' => 'vitamins',
            'brand' => 'Caltrate',
            'sku' => 'CAL-VD-60',
            'stock_quantity' => 75,
            'is_available' => 1,
            'requires_prescription' => 0,
            'manufacturer' => 'Pfizer',
            'rating' => 4.4,
            'review_count' => 112,
            'tags' => '["calcium", "bone health", "vitamin d"]'
        ],

        // First Aid
        [
            'name' => 'Betadine Solution 60ml',
            'description' => 'Antiseptic solution for wound cleaning and disinfection',
            'price' => 85.00,
            'image' => 'assets/img/betadine.jpg',
            'category' => 'first_aid',
            'brand' => 'Betadine',
            'sku' => 'BET-SOL-60',
            'stock_quantity' => 75,
            'is_available' => 1,
            'requires_prescription' => 0,
            'active_ingredient' => 'Povidone Iodine',
            'manufacturer' => 'Mundipharma',
            'rating' => 4.7,
            'review_count' => 156,
            'tags' => '["antiseptic", "wound care", "disinfectant"]'
        ],
        [
            'name' => 'Alcohol 70% 500ml',
            'description' => 'Isopropyl alcohol for disinfection and cleaning',
            'price' => 45.00,
            'image' => 'assets/img/alcohol.jpg',
            'category' => 'first_aid',
            'brand' => 'Green Cross',
            'sku' => 'ALC-70-500',
            'stock_quantity' => 150,
            'is_available' => 1,
            'requires_prescription' => 0,
            'active_ingredient' => 'Isopropyl Alcohol',
            'manufacturer' => 'Green Cross',
            'rating' => 4.2,
            'review_count' => 67,
            'tags' => '["disinfectant", "cleaning", "antiseptic"]'
        ],
        [
            'name' => 'Band-Aid Adhesive Bandages',
            'description' => 'Sterile adhesive bandages for wound protection',
            'price' => 125.00,
            'image' => 'assets/img/bandaid.jpg',
            'category' => 'first_aid',
            'brand' => 'Band-Aid',
            'sku' => 'BND-AID-50',
            'stock_quantity' => 200,
            'is_available' => 1,
            'requires_prescription' => 0,
            'manufacturer' => 'Johnson & Johnson',
            'rating' => 4.6,
            'review_count' => 189,
            'tags' => '["bandages", "wound care", "first aid"]'
        ],
        [
            'name' => 'Hydrogen Peroxide 3%',
            'description' => 'Antiseptic solution for wound cleaning',
            'price' => 35.00,
            'image' => 'assets/img/hydrogen-peroxide.jpg',
            'category' => 'first_aid',
            'brand' => 'Generic',
            'sku' => 'HYD-PER-250',
            'stock_quantity' => 100,
            'is_available' => 1,
            'requires_prescription' => 0,
            'active_ingredient' => 'Hydrogen Peroxide',
            'manufacturer' => 'Generic Pharma',
            'rating' => 4.1,
            'review_count' => 45,
            'tags' => '["antiseptic", "wound cleaning", "disinfectant"]'
        ],

        // Prescription Drugs
        [
            'name' => 'Amoxicillin 500mg',
            'description' => 'Antibiotic capsule for bacterial infections',
            'price' => 25.00,
            'image' => 'assets/img/amoxicillin.jpg',
            'category' => 'prescription_drugs',
            'brand' => 'Generics',
            'sku' => 'AMX-500-21',
            'stock_quantity' => 100,
            'is_available' => 1,
            'requires_prescription' => 1,
            'dosage' => '500mg',
            'active_ingredient' => 'Amoxicillin',
            'manufacturer' => 'Generics Pharmacy',
            'rating' => 4.2,
            'review_count' => 67,
            'tags' => '["antibiotic", "infection", "prescription"]'
        ],
        [
            'name' => 'Losartan 50mg',
            'description' => 'ACE inhibitor for high blood pressure',
            'price' => 180.00,
            'image' => 'assets/img/losartan.jpg',
            'category' => 'prescription_drugs',
            'brand' => 'Generics',
            'sku' => 'LOS-50-30',
            'stock_quantity' => 60,
            'is_available' => 1,
            'requires_prescription' => 1,
            'dosage' => '50mg',
            'active_ingredient' => 'Losartan Potassium',
            'manufacturer' => 'Generics Pharmacy',
            'rating' => 4.4,
            'review_count' => 89,
            'tags' => '["blood pressure", "hypertension", "prescription"]'
        ],
        [
            'name' => 'Metformin 500mg',
            'description' => 'Diabetes medication for blood sugar control',
            'price' => 95.00,
            'image' => 'assets/img/metformin.jpg',
            'category' => 'prescription_drugs',
            'brand' => 'Generics',
            'sku' => 'MET-500-30',
            'stock_quantity' => 80,
            'is_available' => 1,
            'requires_prescription' => 1,
            'dosage' => '500mg',
            'active_ingredient' => 'Metformin HCl',
            'manufacturer' => 'Generics Pharmacy',
            'rating' => 4.3,
            'review_count' => 112,
            'tags' => '["diabetes", "blood sugar", "prescription"]'
        ]
    ];

    // Prepare insert statement
    $stmt = $pdo->prepare("
        INSERT INTO products (
            name, description, price, image, category, brand, sku, 
            stock_quantity, is_available, requires_prescription, dosage, 
            active_ingredient, manufacturer, rating, review_count, tags
        ) VALUES (
            :name, :description, :price, :image, :category, :brand, :sku,
            :stock_quantity, :is_available, :requires_prescription, :dosage,
            :active_ingredient, :manufacturer, :rating, :review_count, :tags
        )
    ");

    foreach ($products as $product) {
        $stmt->execute($product);
    }

    $count = count($products);
    echo "✅ Inserted $count products\n\n";

    // Show summary
    $stmt = $pdo->query("SELECT category, COUNT(*) as count FROM products GROUP BY category");
    echo "📊 Products by category:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "   {$row['category']}: {$row['count']} items\n";
    }

    echo "\n🎉 Database setup complete!\n";
    echo "✅ Database: $database\n";
    echo "✅ Tables: users, products, orders, order_items\n";
    echo "✅ Sample data: $count products\n";
    echo "\n🚀 You can now start your Laravel server and test the API!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>