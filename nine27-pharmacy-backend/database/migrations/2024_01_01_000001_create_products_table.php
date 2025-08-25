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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->decimal('price', 10, 2);
            $table->string('image')->nullable();
            $table->string('category');
            $table->string('brand')->nullable();
            $table->string('sku')->nullable()->unique();
            $table->integer('stock_quantity')->default(0);
            $table->boolean('is_available')->default(true);
            $table->boolean('requires_prescription')->default(false);
            $table->string('dosage')->nullable();
            $table->string('active_ingredient')->nullable();
            $table->string('manufacturer')->nullable();
            $table->date('expiry_date')->nullable();
            $table->decimal('rating', 3, 1)->nullable();
            $table->integer('review_count')->default(0);
            $table->json('tags')->nullable();
            $table->timestamps();

            // Indexes for better performance
            $table->index('category');
            $table->index('is_available');
            $table->index('requires_prescription');
            $table->index(['category', 'is_available']);
            $table->index(['rating', 'review_count']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};