<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

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