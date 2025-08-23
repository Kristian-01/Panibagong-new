<?php
/**
 * Nine27 Pharmacy Database Connection Test
 * Run this after setting up MySQL to verify connection
 */

echo "🔍 Testing Nine27 Pharmacy Database Connection\n";
echo "==============================================\n\n";

// Database configuration
$host = '127.0.0.1';
$port = '3306';
$database = 'nine27_pharmacy';
$username = 'nine27_user';
$password = 'nine27_password';

try {
    echo "📡 Connecting to MySQL server...\n";
    
    // Create PDO connection
    $dsn = "mysql:host=$host;port=$port;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connected to MySQL server!\n\n";
    
    // Check if database exists
    echo "🗄️ Checking database '$database'...\n";
    $stmt = $pdo->query("SHOW DATABASES LIKE '$database'");
    $dbExists = $stmt->fetch();
    
    if ($dbExists) {
        echo "✅ Database '$database' exists!\n\n";
        
        // Connect to specific database
        $pdo->exec("USE $database");
        
        // Check tables
        echo "📋 Checking tables...\n";
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        $expectedTables = ['users', 'orders', 'order_items', 'migrations'];
        $foundTables = [];
        
        foreach ($expectedTables as $table) {
            if (in_array($table, $tables)) {
                echo "✅ Table '$table' exists\n";
                $foundTables[] = $table;
            } else {
                echo "❌ Table '$table' missing\n";
            }
        }
        
        if (count($foundTables) === count($expectedTables)) {
            echo "\n🎉 All required tables found!\n\n";
            
            // Test data
            echo "📊 Checking sample data...\n";
            
            // Check users
            $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
            $userCount = $stmt->fetch()['count'];
            echo "👥 Users: $userCount\n";
            
            // Check orders
            $stmt = $pdo->query("SELECT COUNT(*) as count FROM orders");
            $orderCount = $stmt->fetch()['count'];
            echo "📋 Orders: $orderCount\n";
            
            // Check order items
            $stmt = $pdo->query("SELECT COUNT(*) as count FROM order_items");
            $itemCount = $stmt->fetch()['count'];
            echo "🛒 Order Items: $itemCount\n";
            
            if ($userCount > 0 && $orderCount > 0) {
                echo "\n✅ Sample data found! Database is ready.\n";
                
                // Show sample user
                $stmt = $pdo->query("SELECT name, email FROM users LIMIT 1");
                $user = $stmt->fetch();
                if ($user) {
                    echo "👤 Sample user: {$user['name']} ({$user['email']})\n";
                }
                
                // Show sample order
                $stmt = $pdo->query("SELECT order_number, status, total_amount FROM orders LIMIT 1");
                $order = $stmt->fetch();
                if ($order) {
                    echo "📦 Sample order: {$order['order_number']} - {$order['status']} - ₱{$order['total_amount']}\n";
                }
                
            } else {
                echo "\n⚠️ No sample data found. Run: php artisan db:seed --class=OrderSeeder\n";
            }
            
        } else {
            echo "\n❌ Some tables are missing. Run: php artisan migrate\n";
        }
        
    } else {
        echo "❌ Database '$database' does not exist!\n";
        echo "💡 Create it with: CREATE DATABASE $database;\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Database connection failed!\n";
    echo "Error: " . $e->getMessage() . "\n\n";
    
    echo "💡 Troubleshooting:\n";
    echo "1. Check if MySQL is running\n";
    echo "2. Verify database credentials in .env file\n";
    echo "3. Ensure database and user exist:\n";
    echo "   CREATE DATABASE $database;\n";
    echo "   CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';\n";
    echo "   GRANT ALL PRIVILEGES ON $database.* TO '$username'@'localhost';\n";
    echo "   FLUSH PRIVILEGES;\n";
}

echo "\n🎯 Next Steps:\n";
echo "1. If database is ready: php artisan serve\n";
echo "2. Test API: curl http://localhost:8000/api/health\n";
echo "3. Run Flutter app: flutter run\n";
echo "\n";
?>
