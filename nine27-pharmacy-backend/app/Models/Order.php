<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'order_number',
        'status',
        'total_amount',
        'items_count',
        'order_type',
        'category',
        'delivery_address',
        'payment_method',
        'notes',
        'shipped_at',
        'delivered_at',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'shipped_at' => 'datetime',
        'delivered_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = [
        'formatted_total',
        'formatted_date',
        'item_count_text',
        'can_cancel',
        'can_reorder',
        'is_delivered',
        'is_pending',
        'is_processing',
        'is_cancelled',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    // Accessors
    public function getFormattedTotalAttribute(): string
    {
        return '₱' . number_format($this->total_amount, 2);
    }

    public function getFormattedDateAttribute(): string
    {
        $months = [
            1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr',
            5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug',
            9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
        ];
        
        return $months[$this->created_at->month] . ' ' . 
               $this->created_at->day . ', ' . 
               $this->created_at->year;
    }

    public function getItemCountTextAttribute(): string
    {
        return $this->items_count == 1 ? '1 item' : $this->items_count . ' items';
    }

    public function getCanCancelAttribute(): bool
    {
        return in_array($this->status, ['pending', 'processing']);
    }

    public function getCanReorderAttribute(): bool
    {
        return $this->status === 'delivered';
    }

    public function getIsDeliveredAttribute(): bool
    {
        return $this->status === 'delivered';
    }

    public function getIsPendingAttribute(): bool
    {
        return $this->status === 'pending';
    }

    public function getIsProcessingAttribute(): bool
    {
        return $this->status === 'processing';
    }

    public function getIsCancelledAttribute(): bool
    {
        return $this->status === 'cancelled';
    }

    // Scopes
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByOrderType($query, $orderType)
    {
        return $query->where('order_type', $orderType);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }

    // Methods
    public static function generateOrderNumber(): string
    {
        $prefix = 'ORD-' . date('Y') . '-';
        $lastOrder = static::where('order_number', 'like', $prefix . '%')
                          ->orderBy('order_number', 'desc')
                          ->first();

        if ($lastOrder) {
            $lastNumber = (int) str_replace($prefix, '', $lastOrder->order_number);
            $newNumber = $lastNumber + 1;
        } else {
            $newNumber = 1;
        }

        return $prefix . str_pad($newNumber, 3, '0', STR_PAD_LEFT);
    }

    public function cancel(string $reason = null): bool
    {
        if (!$this->can_cancel) {
            return false;
        }

        $this->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
            'cancellation_reason' => $reason,
        ]);

        return true;
    }

    public function markAsProcessing(): bool
    {
        if ($this->status !== 'pending') {
            return false;
        }

        $this->update(['status' => 'processing']);
        return true;
    }

    public function markAsShipped(): bool
    {
        if ($this->status !== 'processing') {
            return false;
        }

        $this->update([
            'status' => 'shipped',
            'shipped_at' => now(),
        ]);

        return true;
    }

    public function markAsDelivered(): bool
    {
        if ($this->status !== 'shipped') {
            return false;
        }

        $this->update([
            'status' => 'delivered',
            'delivered_at' => now(),
        ]);

        return true;
    }

    public function createReorder(): self
    {
        $newOrder = static::create([
            'user_id' => $this->user_id,
            'order_number' => static::generateOrderNumber(),
            'status' => 'pending',
            'total_amount' => $this->total_amount,
            'items_count' => $this->items_count,
            'order_type' => $this->order_type,
            'category' => $this->category,
            'delivery_address' => $this->delivery_address,
            'payment_method' => $this->payment_method,
            'notes' => 'Reorder from ' . $this->order_number,
        ]);

        // Copy order items
        foreach ($this->items as $item) {
            $newOrder->items()->create([
                'product_name' => $item->product_name,
                'product_price' => $item->product_price,
                'quantity' => $item->quantity,
                'product_image' => $item->product_image,
                'product_description' => $item->product_description,
                'product_category' => $item->product_category,
                'product_sku' => $item->product_sku,
                'unit_price' => $item->unit_price,
                'discount_amount' => $item->discount_amount,
            ]);
        }

        return $newOrder;
    }
}
