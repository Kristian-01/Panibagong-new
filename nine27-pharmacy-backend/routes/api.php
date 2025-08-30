<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'service' => 'Nine27 Pharmacy API'
    ]);
});

// Test route
Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

// Public authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Public product routes (no authentication required)
Route::prefix('products')->group(function () {
    Route::get('/', [ProductController::class, 'index']);
    Route::get('/featured', [ProductController::class, 'featured']);
    Route::get('/category/{category}', [ProductController::class, 'byCategory']);
    Route::get('/suggestions', [ProductController::class, 'suggestions']);
    Route::get('/{id}', [ProductController::class, 'show']);
});

// Public categories route
Route::get('/categories', [ProductController::class, 'categories']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    // User routes
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile/update', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Order Management routes
    Route::prefix('orders')->group(function () {
        // Get user orders with filtering and pagination
        Route::get('/', [OrderController::class, 'index']);

        // Create new order
        Route::post('/', [OrderController::class, 'store']);

        // Get specific order details
        Route::get('/{order}', [OrderController::class, 'show']);

        // Cancel order
        Route::post('/{order}/cancel', [OrderController::class, 'cancel']);

        // Reorder from existing order
        Route::post('/{order}/reorder', [OrderController::class, 'reorder']);

        // Track order by order number
        Route::get('/track/{orderNumber}', [OrderController::class, 'track']);
    });

    // Staff Order Management routes (for staff/admin users)
    Route::prefix('staff/orders')->group(function () {
        // Get all orders for staff management
        Route::get('/', [OrderController::class, 'staffIndex']);
        
        // Start processing order (pending → processing)
        Route::post('/{order}/start-processing', [OrderController::class, 'startProcessing']);
        
        // Mark order as shipped (processing → shipped)
        Route::post('/{order}/mark-shipped', [OrderController::class, 'markShipped']);
        
        // Mark order as delivered (shipped → delivered)
        Route::post('/{order}/mark-delivered', [OrderController::class, 'markDelivered']);
        
        // Get order statistics for staff dashboard
        Route::get('/statistics', [OrderController::class, 'getStatistics']);
    });
});

// Catch-all route for unauthenticated requests to protected endpoints
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Endpoint not found or requires authentication',
        'error' => 'Route not found'
    ], 404);
});