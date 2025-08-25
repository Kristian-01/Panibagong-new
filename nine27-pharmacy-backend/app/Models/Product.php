<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'image',
        'category',
        'brand',
        'sku',
        'stock_quantity',
        'is_available',
        'requires_prescription',
        'dosage',
        'active_ingredient',
        'manufacturer',
        'expiry_date',
        'rating',
        'review_count',
        'tags',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'is_available' => 'boolean',
        'requires_prescription' => 'boolean',
        'rating' => 'decimal:1',
        'review_count' => 'integer',
        'stock_quantity' => 'integer',
        'expiry_date' => 'date',
        'tags' => 'array',
    ];

    // Accessors
    public function getFormattedPriceAttribute()
    {
        return '₱' . number_format($this->price, 2);
    }

    public function getInStockAttribute()
    {
        return $this->stock_quantity > 0 && $this->is_available;
    }

    public function getLowStockAttribute()
    {
        return $this->stock_quantity <= 10 && $this->stock_quantity > 0;
    }

    public function getOutOfStockAttribute()
    {
        return $this->stock_quantity <= 0;
    }

    public function getStockStatusAttribute()
    {
        if ($this->out_of_stock) return 'Out of Stock';
        if ($this->low_stock) return 'Low Stock';
        return 'In Stock';
    }

    public function getFormattedRatingAttribute()
    {
        if (!$this->rating) return 'No rating';
        return number_format($this->rating, 1) . ' ⭐';
    }

    public function getCategoryDisplayNameAttribute()
    {
        $displayNames = [
            'medicines' => 'Medicines',
            'vitamins' => 'Vitamins & Supplements',
            'first_aid' => 'First Aid',
            'health_products' => 'Health Products',
            'prescription_drugs' => 'Prescription Drugs',
            'baby_care' => 'Baby Care',
            'personal_care' => 'Personal Care',
        ];

        return $displayNames[$this->category] ?? ucfirst(str_replace('_', ' ', $this->category));
    }

    public function getIsExpiringSoonAttribute()
    {
        if (!$this->expiry_date) return false;
        $daysUntilExpiry = now()->diffInDays($this->expiry_date, false);
        return $daysUntilExpiry <= 30 && $daysUntilExpiry > 0;
    }

    public function getIsExpiredAttribute()
    {
        if (!$this->expiry_date) return false;
        return $this->expiry_date->isPast();
    }

    // Scopes
    public function scopeAvailable($query)
    {
        return $query->where('is_available', true)->where('stock_quantity', '>', 0);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeFeatured($query)
    {
        return $query->where('rating', '>=', 4.0)->orderBy('rating', 'desc');
    }

    public function scopeSearch($query, $term)
    {
        return $query->where(function($q) use ($term) {
            $q->where('name', 'LIKE', "%{$term}%")
              ->orWhere('description', 'LIKE', "%{$term}%")
              ->orWhere('brand', 'LIKE', "%{$term}%")
              ->orWhere('active_ingredient', 'LIKE', "%{$term}%");
        });
    }
}