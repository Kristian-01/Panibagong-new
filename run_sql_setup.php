<?php
echo "🔧 Setting up Nine27 Pharmacy Database Tables...\n\n";

try {
    // Database connection
    $host = '127.0.0.1';
    $port = '3306';
    $database = 'nine27_pharmacy';
    $username = 'nine27_user';
    $password = 'nine27_password';

    // Try to connect with the specified user
    try {
        $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database", $username, $password);
        echo "✅ Connected with user: $username\n";
    } catch (PDOException $e) {
        // Try with root if the user doesn't work
        echo "⚠️  Trying with root user...\n";
        $pdo = new PDO("mysql:host=$host;port=$port", 'root', '');
        
        // Create database and user if they don't exist
        $pdo->exec("CREATE DATABASE IF NOT EXISTS $database");
        $pdo->exec("CREATE USER IF NOT EXISTS '$username'@'localhost' IDENTIFIED BY '$password'");
        $pdo->exec("GRANT ALL PRIVILEGES ON $database.* TO '$username'@'localhost'");
        $pdo->exec("FLUSH PRIVILEGES");
        
        // Now connect to the database
        $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database", $username, $password);
        echo "✅ Created database and user, connected successfully\n";
    }

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Read and execute the SQL file
    $sql = file_get_contents('create_tables.sql');
    
    // Split SQL into individual statements
    $statements = array_filter(array_map('trim', explode(';', $sql)));
    
    foreach ($statements as $statement) {
        if (!empty($statement) && !preg_match('/^--/', $statement)) {
            try {
                $pdo->exec($statement);
            } catch (PDOException $e) {
                // Skip comments and empty statements
                if (strpos($statement, 'SELECT') !== 0) {
                    echo "⚠️  Warning: " . $e->getMessage() . "\n";
                }
            }
        }
    }

    // Verify the setup
    $result = $pdo->query("SELECT COUNT(*) as count FROM products");
    $count = $result->fetch(PDO::FETCH_ASSOC)['count'];
    
    echo "\n✅ Database setup complete!\n";
    echo "📦 Products inserted: $count\n";
    
    // Show breakdown by category
    $result = $pdo->query("SELECT category, COUNT(*) as count FROM products GROUP BY category");
    echo "\n📊 Products by category:\n";
    while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
        echo "   {$row['category']}: {$row['count']} items\n";
    }
    
    echo "\n🎯 Next steps:\n";
    echo "1. Start Laravel server: cd nine27-pharmacy-backend && php artisan serve --host=0.0.0.0 --port=8000\n";
    echo "2. Test API: http://localhost:8000/api/products\n";
    echo "3. Rebuild Flutter app: flutter clean && flutter pub get && flutter run\n";

} catch (PDOException $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n\n";
    
    echo "💡 Troubleshooting:\n";
    echo "1. Make sure MySQL server is running\n";
    echo "2. Check if database 'nine27_pharmacy' exists\n";
    echo "3. Verify user credentials in .env file\n";
    echo "4. Try running: mysql -u root -p\n";
    echo "   Then: CREATE DATABASE nine27_pharmacy;\n";
    echo "   Then: CREATE USER 'nine27_user'@'localhost' IDENTIFIED BY 'nine27_password';\n";
    echo "   Then: GRANT ALL PRIVILEGES ON nine27_pharmacy.* TO 'nine27_user'@'localhost';\n";
}
?>