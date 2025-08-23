<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;

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
});