<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    /**
     * Get user orders with filtering and pagination
     */
    public function index(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'nullable|in:pending,processing,shipped,delivered,cancelled',
            'order_type' => 'nullable|in:regular,prescription',
            'category' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = auth()->user();
        $page = $request->get('page', 1);
        $limit = $request->get('limit', 20);

        $query = Order::forUser($user->id)
                     ->with('items')
                     ->recent();

        // Apply filters
        if ($request->filled('status')) {
            $query->byStatus($request->status);
        }

        if ($request->filled('order_type')) {
            $query->byOrderType($request->order_type);
        }

        if ($request->filled('category')) {
            $query->byCategory($request->category);
        }

        // Get total count before pagination
        $total = $query->count();

        // Apply pagination
        $orders = $query->skip(($page - 1) * $limit)
                       ->take($limit)
                       ->get();

        $totalPages = ceil($total / $limit);

        return response()->json([
            'success' => true,
            'orders' => $orders,
            'total' => $total,
            'current_page' => $page,
            'total_pages' => $totalPages,
            'per_page' => $limit,
        ]);
    }

    /**
     * Get specific order details
     */
    public function show(Order $order): JsonResponse
    {
        // Check if order belongs to authenticated user
        if ($order->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        $order->load('items');

        return response()->json([
            'success' => true,
            'order' => $order,
        ]);
    }

    /**
     * Create new order
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'items' => 'required|array|min:1',
            'items.*.product_name' => 'required|string|max:255',
            'items.*.product_price' => 'required|numeric|min:0',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.product_image' => 'nullable|string|max:500',
            'items.*.product_description' => 'nullable|string',
            'items.*.product_category' => 'nullable|string|max:100',
            'total_amount' => 'required|numeric|min:0',
            'delivery_address' => 'required|string',
            'payment_method' => 'required|string|max:100',
            'order_type' => 'nullable|in:regular,prescription',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            $user = auth()->user();
            $items = $request->items;

            // Calculate items count and determine category
            $itemsCount = array_sum(array_column($items, 'quantity'));
            $categories = array_unique(array_filter(array_column($items, 'product_category')));
            $mainCategory = !empty($categories) ? $categories[0] : 'medicines';

            // Create order
            $order = Order::create([
                'user_id' => $user->id,
                'order_number' => Order::generateOrderNumber(),
                'status' => 'pending',
                'total_amount' => $request->total_amount,
                'items_count' => $itemsCount,
                'order_type' => $request->get('order_type', 'regular'),
                'category' => $mainCategory,
                'delivery_address' => $request->delivery_address,
                'payment_method' => $request->payment_method,
                'notes' => $request->notes,
            ]);

            // Create order items
            foreach ($items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_name' => $item['product_name'],
                    'product_price' => $item['product_price'],
                    'quantity' => $item['quantity'],
                    'product_image' => $item['product_image'] ?? null,
                    'product_description' => $item['product_description'] ?? null,
                    'product_category' => $item['product_category'] ?? null,
                ]);
            }

            DB::commit();

            $order->load('items');

            return response()->json([
                'success' => true,
                'message' => 'Order created successfully',
                'order' => $order,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create order: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Cancel order
     */
    public function cancel(Request $request, Order $order): JsonResponse
    {
        // Check if order belongs to authenticated user
        if ($order->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        if (!$order->cancel($request->reason)) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot cancel this order. Order status: ' . $order->status,
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order cancelled successfully',
        ]);
    }

    /**
     * Reorder - create new order from existing order
     */
    public function reorder(Order $order): JsonResponse
    {
        // Check if order belongs to authenticated user
        if ($order->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        if (!$order->can_reorder) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reorder this order. Only delivered orders can be reordered.',
            ], 400);
        }

        try {
            DB::beginTransaction();

            $newOrder = $order->createReorder();

            DB::commit();

            $newOrder->load('items');

            return response()->json([
                'success' => true,
                'message' => 'Order placed successfully',
                'order' => $newOrder,
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to reorder: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Track order by order number
     */
    public function track(string $orderNumber): JsonResponse
    {
        $order = Order::where('order_number', $orderNumber)
                     ->forUser(auth()->id())
                     ->with('items')
                     ->first();

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        // Generate tracking info based on status
        $trackingInfo = $this->generateTrackingInfo($order);

        return response()->json([
            'success' => true,
            'order' => $order,
            'tracking_info' => $trackingInfo,
        ]);
    }

    /**
     * Generate tracking information
     */
    private function generateTrackingInfo(Order $order): array
    {
        $steps = [
            [
                'title' => 'Order Placed',
                'description' => 'Your order has been placed successfully',
                'completed' => true,
                'date' => $order->created_at->format('M d, Y H:i'),
            ],
            [
                'title' => 'Processing',
                'description' => 'We are preparing your order',
                'completed' => in_array($order->status, ['processing', 'shipped', 'delivered']),
                'date' => $order->status === 'processing' ? now()->format('M d, Y H:i') : null,
            ],
            [
                'title' => 'Shipped',
                'description' => 'Your order is on the way',
                'completed' => in_array($order->status, ['shipped', 'delivered']),
                'date' => $order->shipped_at?->format('M d, Y H:i'),
            ],
            [
                'title' => 'Delivered',
                'description' => 'Order delivered successfully',
                'completed' => $order->status === 'delivered',
                'date' => $order->delivered_at?->format('M d, Y H:i'),
            ],
        ];

        if ($order->status === 'cancelled') {
            $steps = [
                [
                    'title' => 'Order Placed',
                    'description' => 'Your order was placed',
                    'completed' => true,
                    'date' => $order->created_at->format('M d, Y H:i'),
                ],
                [
                    'title' => 'Cancelled',
                    'description' => 'Order was cancelled: ' . ($order->cancellation_reason ?? 'No reason provided'),
                    'completed' => true,
                    'date' => $order->cancelled_at?->format('M d, Y H:i'),
                ],
            ];
        }

        return [
            'current_status' => $order->status,
            'steps' => $steps,
            'estimated_delivery' => $order->status === 'shipped' ? 
                now()->addDays(2)->format('M d, Y') : null,
        ];
    }

    // ========================================
    // STAFF ORDER MANAGEMENT METHODS
    // ========================================

    /**
     * Get all orders for staff management (with pagination and filtering)
     */
    public function staffIndex(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'nullable|in:pending,processing,shipped,delivered,cancelled',
            'order_type' => 'nullable|in:regular,prescription',
            'category' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
            'search' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $page = $request->get('page', 1);
        $limit = $request->get('limit', 20);

        $query = Order::with(['user', 'items'])->recent();

        // Apply filters
        if ($request->filled('status')) {
            $query->byStatus($request->status);
        }

        if ($request->filled('order_type')) {
            $query->byOrderType($request->order_type);
        }

        if ($request->filled('category')) {
            $query->byCategory($request->category);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('order_number', 'LIKE', "%{$search}%")
                  ->orWhereHas('user', function($userQuery) use ($search) {
                      $userQuery->where('name', 'LIKE', "%{$search}%")
                               ->orWhere('email', 'LIKE', "%{$search}%");
                  });
            });
        }

        // Get total count before pagination
        $total = $query->count();

        // Apply pagination
        $orders = $query->skip(($page - 1) * $limit)
                       ->take($limit)
                       ->get();

        $totalPages = ceil($total / $limit);

        return response()->json([
            'success' => true,
            'orders' => $orders,
            'total' => $total,
            'current_page' => $page,
            'total_pages' => $totalPages,
            'per_page' => $limit,
        ]);
    }

    /**
     * Start processing order (pending → processing)
     */
    public function startProcessing(Order $order): JsonResponse
    {
        try {
            // Check if order can be processed
            if ($order->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Order cannot be processed. Current status: ' . $order->status,
                ], 400);
            }

            // Update status to processing
            $order->markAsProcessing();
            
            // Log the status change (you can add activity logging here)
            
            return response()->json([
                'success' => true,
                'message' => 'Order is now being processed',
                'order' => $order->fresh(['user', 'items']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update order status: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark order as shipped (processing → shipped)
     */
    public function markShipped(Order $order): JsonResponse
    {
        try {
            // Check if order can be shipped
            if ($order->status !== 'processing') {
                return response()->json([
                    'success' => false,
                    'message' => 'Order cannot be shipped. Current status: ' . $order->status,
                ], 400);
            }

            // Update status to shipped
            $order->markAsShipped();
            
            return response()->json([
                'success' => true,
                'message' => 'Order has been shipped and is on its way',
                'order' => $order->fresh(['user', 'items']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update order status: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark order as delivered (shipped → delivered)
     */
    public function markDelivered(Order $order): JsonResponse
    {
        try {
            // Check if order can be marked as delivered
            if ($order->status !== 'shipped') {
                return response()->json([
                    'success' => false,
                    'message' => 'Order cannot be marked as delivered. Current status: ' . $order->status,
                ], 400);
            }

            // Update status to delivered
            $order->markAsDelivered();
            
            return response()->json([
                'success' => true,
                'message' => 'Order has been delivered successfully',
                'order' => $order->fresh(['user', 'items']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update order status: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get order statistics for staff dashboard
     */
    public function getStatistics(): JsonResponse
    {
        try {
            $stats = [
                'total_orders' => Order::count(),
                'pending_orders' => Order::where('status', 'pending')->count(),
                'processing_orders' => Order::where('status', 'processing')->count(),
                'shipped_orders' => Order::where('status', 'shipped')->count(),
                'delivered_orders' => Order::where('status', 'delivered')->count(),
                'cancelled_orders' => Order::where('status', 'cancelled')->count(),
                'today_orders' => Order::whereDate('created_at', today())->count(),
                'revenue_today' => Order::whereDate('created_at', today())
                                    ->where('status', '!=', 'cancelled')
                                    ->sum('total_amount'),
            ];

            return response()->json([
                'success' => true,
                'statistics' => $stats,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch statistics: ' . $e->getMessage(),
            ], 500);
        }
    }
}
