<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'mobile' => '09123456789',
            'address' => '123 Main St, Sample City',
        ]);

        // Seed medicines and vitamins
        $this->call([
            MedicineListSeeder::class,
        ]);
    }
}
