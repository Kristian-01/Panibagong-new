<?php
// Run this from your Laravel backend directory: php setup_mysql_data.php

require_once 'vendor/autoload.php';

// Load Laravel environment
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "🔧 Setting up Nine27 Pharmacy MySQL Database...\n\n";

try {
    // Test database connection
    DB::connection()->getPdo();
    echo "✅ Connected to MySQL database: " . env('DB_DATABASE') . "\n\n";
    
    // Clear existing products
    DB::table('products')->truncate();
    echo "🗑️ Cleared existing products\n";
    
    // Insert comprehensive medicine data
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
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
            'created_at' => now(),
            'updated_at' => now(),
        ],
    ];
    
    // Insert products
    foreach ($products as $product) {
        DB::table('products')->insert($product);
    }
    
    $count = DB::table('products')->count();
    echo "✅ Successfully added " . count($products) . " medicines to MySQL database!\n";
    echo "📦 Total products in database: $count\n\n";
    
    // Show breakdown by category
    $medicines = DB::table('products')->where('category', 'medicines')->count();
    $vitamins = DB::table('products')->where('category', 'vitamins')->count();
    $firstAid = DB::table('products')->where('category', 'first_aid')->count();
    $prescription = DB::table('products')->where('category', 'prescription_drugs')->count();
    
    echo "📊 Products by category:\n";
    echo "💊 Medicines: $medicines\n";
    echo "🧴 Vitamins: $vitamins\n";
    echo "🩹 First Aid: $firstAid\n";
    echo "📋 Prescription: $prescription\n\n";
    
    echo "🎯 Your MySQL database is now ready!\n";
    echo "🔄 Start your Laravel server and switch your Flutter app to use API calls.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "💡 Make sure your MySQL server is running and database exists.\n";
}
?>