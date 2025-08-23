<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'product_name',
        'product_price',
        'quantity',
        'product_image',
        'product_description',
        'product_category',
        'product_sku',
        'unit_price',
        'discount_amount',
    ];

    protected $casts = [
        'product_price' => 'decimal:2',
        'unit_price' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'quantity' => 'integer',
    ];

    protected $appends = [
        'total_price',
        'formatted_price',
        'formatted_total',
    ];

    // Relationships
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    // Accessors
    public function getTotalPriceAttribute(): float
    {
        return $this->product_price * $this->quantity;
    }

    public function getFormattedPriceAttribute(): string
    {
        return '₱' . number_format($this->product_price, 2);
    }

    public function getFormattedTotalAttribute(): string
    {
        return '₱' . number_format($this->total_price, 2);
    }

    // Methods
    public function calculateSubtotal(): float
    {
        return ($this->unit_price ?? $this->product_price) * $this->quantity;
    }

    public function calculateDiscount(): float
    {
        return $this->discount_amount * $this->quantity;
    }

    public function calculateTotal(): float
    {
        return $this->calculateSubtotal() - $this->calculateDiscount();
    }
}
