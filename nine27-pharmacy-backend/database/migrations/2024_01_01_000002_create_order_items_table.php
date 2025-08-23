<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->string('product_name');
            $table->decimal('product_price', 8, 2);
            $table->integer('quantity');
            $table->string('product_image', 500)->nullable();
            $table->text('product_description')->nullable();
            $table->string('product_category', 100)->nullable();
            $table->string('product_sku', 100)->nullable();
            $table->decimal('unit_price', 8, 2)->nullable(); // Original unit price before discounts
            $table->decimal('discount_amount', 8, 2)->default(0);
            $table->timestamps();

            // Indexes
            $table->index('order_id');
            $table->index('product_name');
            $table->index('product_category');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
