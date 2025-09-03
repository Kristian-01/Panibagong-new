<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\Hash;
use App\Models\User;

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

try {
    // Check if user already exists
    $existingUser = User::where('email', 'test@example.com')->first();
    
    if ($existingUser) {
        echo "Test user already exists with email: test@example.com\n";
        echo "Password: password123\n";
        exit;
    }

    // Create test user
    $user = User::create([
        'name' => 'Test User',
        'email' => 'test@example.com',
        'mobile' => '1234567890',
        'address' => '123 Test Street, Test City',
        'password' => Hash::make('password123'),
    ]);

    echo "Test user created successfully!\n";
    echo "Email: test@example.com\n";
    echo "Password: password123\n";
    echo "User ID: " . $user->id . "\n";

} catch (Exception $e) {
    echo "Error creating test user: " . $e->getMessage() . "\n";
}





