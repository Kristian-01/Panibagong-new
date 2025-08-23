<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Facades\Hash;

class OrderSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create test user if not exists
        $user = User::firstOrCreate(
            ['email' => 'test@nine27pharmacy.com'],
            [
                'name' => 'Test User',
                'mobile' => '09123456789',
                'address' => '123 Test Street, Test City, Philippines',
                'password' => Hash::make('password123'),
            ]
        );

        // Sample medicines data
        $medicines = [
            [
                'name' => 'Biogesic 500mg',
                'price' => 50.00,
                'category' => 'medicines',
                'description' => 'Paracetamol 500mg tablet for fever and pain relief',
                'image' => 'https://example.com/biogesic.jpg',
            ],
            [
                'name' => 'Amoxicillin 500mg',
                'price' => 25.00,
                'category' => 'prescription drugs',
                'description' => 'Antibiotic capsule',
                'image' => 'https://example.com/amoxicillin.jpg',
            ],
            [
                'name' => 'Vitamin C 500mg',
                'price' => 15.00,
                'category' => 'vitamins',
                'description' => 'Immune system support',
                'image' => 'https://example.com/vitamin-c.jpg',
            ],
            [
                'name' => 'Betadine Solution',
                'price' => 85.00,
                'category' => 'first aid',
                'description' => 'Antiseptic solution 60ml',
                'image' => 'https://example.com/betadine.jpg',
            ],
            [
                'name' => 'Centrum Multivitamins',
                'price' => 450.00,
                'category' => 'vitamins',
                'description' => 'Complete multivitamin supplement',
                'image' => 'https://example.com/centrum.jpg',
            ],
        ];

        // Create sample orders
        $orderStatuses = ['delivered', 'processing', 'delivered', 'cancelled', 'delivered', 'pending'];
        $orderTypes = ['prescription', 'regular', 'prescription', 'regular', 'regular', 'prescription'];

        for ($i = 0; $i < 6; $i++) {
            $status = $orderStatuses[$i];
            $orderType = $orderTypes[$i];
            
            // Random selection of medicines for this order
            $orderMedicines = collect($medicines)->random(rand(1, 3));
            $totalAmount = 0;
            $itemsCount = 0;
            
            // Calculate total and items count
            foreach ($orderMedicines as $medicine) {
                $quantity = rand(1, 3);
                $totalAmount += $medicine['price'] * $quantity;
                $itemsCount += $quantity;
            }

            // Create order
            $order = Order::create([
                'user_id' => $user->id,
                'order_number' => 'ORD-2024-' . str_pad($i + 1, 3, '0', STR_PAD_LEFT),
                'status' => $status,
                'total_amount' => $totalAmount,
                'items_count' => $itemsCount,
                'order_type' => $orderType,
                'category' => $orderMedicines->first()['category'],
                'delivery_address' => '123 Test Street, Test City, Philippines',
                'payment_method' => $i % 2 == 0 ? 'Cash on Delivery' : 'Credit Card',
                'notes' => $i == 0 ? 'Please call before delivery' : null,
                'created_at' => now()->subDays(rand(1, 30)),
                'shipped_at' => in_array($status, ['shipped', 'delivered']) ? now()->subDays(rand(1, 5)) : null,
                'delivered_at' => $status === 'delivered' ? now()->subDays(rand(0, 3)) : null,
                'cancelled_at' => $status === 'cancelled' ? now()->subDays(rand(1, 10)) : null,
                'cancellation_reason' => $status === 'cancelled' ? 'User requested cancellation' : null,
            ]);

            // Create order items
            foreach ($orderMedicines as $medicine) {
                $quantity = rand(1, 3);
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_name' => $medicine['name'],
                    'product_price' => $medicine['price'],
                    'quantity' => $quantity,
                    'product_image' => $medicine['image'],
                    'product_description' => $medicine['description'],
                    'product_category' => $medicine['category'],
                    'product_sku' => 'SKU-' . strtoupper(str_replace(' ', '-', $medicine['name'])),
                    'unit_price' => $medicine['price'],
                    'discount_amount' => 0,
                ]);
            }
        }

        $this->command->info('Created ' . Order::count() . ' sample orders for testing.');
    }
}
