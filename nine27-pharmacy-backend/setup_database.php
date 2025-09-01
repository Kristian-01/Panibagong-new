<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\Hash;
use App\Models\User;

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Setting up Nine27 Pharmacy Database...\n";
echo "=====================================\n\n";

try {
    // Run migrations
    echo "1. Running database migrations...\n";
    $output = shell_exec('php artisan migrate --force 2>&1');
    echo $output . "\n";
    
    // Check if migrations were successful
    if (strpos($output, 'Migrated') !== false || strpos($output, 'Nothing to migrate') !== false) {
        echo "✓ Migrations completed successfully\n\n";
    } else {
        echo "✗ Migration failed\n";
        echo "Output: " . $output . "\n";
        exit(1);
    }
    
    // Create test user
    echo "2. Creating test user...\n";
    $existingUser = User::where('email', 'test@example.com')->first();
    
    if ($existingUser) {
        echo "✓ Test user already exists\n";
        echo "Email: test@example.com\n";
        echo "Password: password123\n\n";
    } else {
        $user = User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'mobile' => '1234567890',
            'address' => '123 Test Street, Test City',
            'password' => Hash::make('password123'),
        ]);
        
        echo "✓ Test user created successfully\n";
        echo "Email: test@example.com\n";
        echo "Password: password123\n";
        echo "User ID: " . $user->id . "\n\n";
    }
    
    // Test database connection
    echo "3. Testing database connection...\n";
    $userCount = User::count();
    echo "✓ Database connection successful. Total users: $userCount\n\n";
    
    echo "Database setup completed successfully!\n";
    echo "You can now test the API endpoints.\n";
    
} catch (Exception $e) {
    echo "✗ Error during setup: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}




