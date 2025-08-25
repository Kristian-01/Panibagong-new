<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    /**
     * Get all products with optional filtering
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Product::query();

            // Filter by category
            if ($request->has('category') && $request->category) {
                $query->where('category', $request->category);
            }

            // Search functionality
            if ($request->has('search') && $request->search) {
                $searchTerm = $request->search;
                $query->where(function($q) use ($searchTerm) {
                    $q->where('name', 'LIKE', "%{$searchTerm}%")
                      ->orWhere('description', 'LIKE', "%{$searchTerm}%")
                      ->orWhere('brand', 'LIKE', "%{$searchTerm}%")
                      ->orWhere('active_ingredient', 'LIKE', "%{$searchTerm}%");
                });
            }

            // Filter by availability
            if ($request->has('available_only') && $request->available_only) {
                $query->where('is_available', 1)->where('stock_quantity', '>', 0);
            }

            // Sorting
            $sortBy = $request->get('sort_by', 'name');
            switch ($sortBy) {
                case 'price_asc':
                    $query->orderBy('price', 'asc');
                    break;
                case 'price_desc':
                    $query->orderBy('price', 'desc');
                    break;
                case 'rating_desc':
                    $query->orderBy('rating', 'desc');
                    break;
                case 'name_desc':
                    $query->orderBy('name', 'desc');
                    break;
                default:
                    $query->orderBy('name', 'asc');
            }

            // Pagination
            $limit = $request->get('limit', 20);
            $page = $request->get('page', 1);
            
            $products = $query->paginate($limit, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'products' => $products->items(),
                'total' => $products->total(),
                'current_page' => $products->currentPage(),
                'total_pages' => $products->lastPage(),
                'per_page' => $products->perPage(),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch products: ' . $e->getMessage(),
                'products' => [],
            ], 500);
        }
    }

    /**
     * Get featured products
     */
    public function featured(Request $request): JsonResponse
    {
        try {
            $limit = $request->get('limit', 10);
            
            $products = Product::where('is_available', 1)
                ->where('stock_quantity', '>', 0)
                ->orderBy('rating', 'desc')
                ->orderBy('review_count', 'desc')
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'products' => $products,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch featured products: ' . $e->getMessage(),
                'products' => [],
            ], 500);
        }
    }

    /**
     * Get products by category
     */
    public function byCategory(Request $request, $category): JsonResponse
    {
        try {
            $limit = $request->get('limit', 20);
            $page = $request->get('page', 1);
            
            $products = Product::where('category', $category)
                ->where('is_available', 1)
                ->where('stock_quantity', '>', 0)
                ->orderBy('rating', 'desc')
                ->paginate($limit, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'products' => $products->items(),
                'total' => $products->total(),
                'current_page' => $products->currentPage(),
                'total_pages' => $products->lastPage(),
                'category' => $category,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch products: ' . $e->getMessage(),
                'products' => [],
            ], 500);
        }
    }

    /**
     * Get product details by ID
     */
    public function show($id): JsonResponse
    {
        try {
            $product = Product::find($id);

            if (!$product) {
                return response()->json([
                    'success' => false,
                    'message' => 'Product not found',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'product' => $product,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch product: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get product categories with counts
     */
    public function categories(): JsonResponse
    {
        try {
            $categories = Product::selectRaw('category, COUNT(*) as product_count')
                ->where('is_available', 1)
                ->groupBy('category')
                ->get()
                ->map(function ($item) {
                    return [
                        'name' => $item->category,
                        'display_name' => $this->getCategoryDisplayName($item->category),
                        'product_count' => $item->product_count,
                        'is_active' => true,
                    ];
                });

            return response()->json([
                'success' => true,
                'categories' => $categories,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch categories: ' . $e->getMessage(),
                'categories' => [],
            ], 500);
        }
    }

    /**
     * Get search suggestions
     */
    public function suggestions(Request $request): JsonResponse
    {
        try {
            $query = $request->get('query', '');
            
            if (strlen($query) < 2) {
                return response()->json([
                    'success' => true,
                    'suggestions' => [],
                ]);
            }

            $suggestions = Product::where('name', 'LIKE', "%{$query}%")
                ->orWhere('brand', 'LIKE', "%{$query}%")
                ->orWhere('active_ingredient', 'LIKE', "%{$query}%")
                ->limit(10)
                ->pluck('name')
                ->unique()
                ->values();

            return response()->json([
                'success' => true,
                'suggestions' => $suggestions,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch suggestions: ' . $e->getMessage(),
                'suggestions' => [],
            ], 500);
        }
    }

    /**
     * Get category display name
     */
    private function getCategoryDisplayName($category): string
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

        return $displayNames[$category] ?? ucfirst(str_replace('_', ' ', $category));
    }
}