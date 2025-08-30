<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

Route::get('/', function () {
    return view('welcome');
});

// Authentication routes
Route::get('/login', function () {
    return response()->json(['message' => 'Please use the API endpoints for authentication']);
})->name('login');

Route::get('/register', function () {
    return response()->json(['message' => 'Please use the API endpoints for authentication']);
})->name('register');

// API routes for Nine27 Pharmacy
Route::prefix('api')->group(function () {
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'timestamp' => now(),
            'service' => 'Nine27 Pharmacy API'
        ]);
    });
    
    Route::get('/test', function () {
        return response()->json(['message' => 'API is working!']);
    });
});