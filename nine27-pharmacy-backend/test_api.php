<?php

echo "Testing Nine27 Pharmacy API\n";
echo "==========================\n\n";

// Test health endpoint
echo "1. Testing health endpoint...\n";
$healthResponse = file_get_contents('http://127.0.0.1:8000/api/health');
echo "Health Response: " . $healthResponse . "\n\n";

// Test login endpoint
echo "2. Testing login endpoint...\n";
$loginData = [
    'email' => 'test@example.com',
    'password' => 'password123'
];

$loginContext = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode($loginData)
    ]
]);

$loginResponse = file_get_contents('http://127.0.0.1:8000/api/login', false, $loginContext);
echo "Login Response: " . $loginResponse . "\n\n";

// Parse login response to get token
$loginResult = json_decode($loginResponse, true);
if (isset($loginResult['token'])) {
    $token = $loginResult['token'];
    echo "3. Testing protected endpoint with token...\n";
    
    // Test orders endpoint with token
    $ordersContext = stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => "Authorization: Bearer $token\r\nContent-Type: application/json"
        ]
    ]);
    
    $ordersResponse = file_get_contents('http://127.0.0.1:8000/api/orders', false, $ordersContext);
    echo "Orders Response: " . $ordersResponse . "\n\n";
} else {
    echo "3. Login failed, cannot test protected endpoint\n";
}

echo "API testing completed!\n";
