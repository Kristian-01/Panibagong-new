import 'package:flutter/material.dart';
import '../common/globs.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // In-app notification queue
  static List<Map<String, dynamic>> _notifications = [];
  static Function(Map<String, dynamic>)? _onNotificationReceived;

  // Initialize notification service
  static Future<void> initialize() async {
    // In a real implementation, you would initialize Firebase Messaging here
    print('📱 Notification Service initialized');
  }

  // Set notification callback
  static void setNotificationCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationReceived = callback;
  }

  // Show in-app notification
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    String type = 'info',
    Duration duration = const Duration(seconds: 4),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case 'success':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case 'warning':
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case 'order':
        backgroundColor = Colors.blue;
        icon = Icons.shopping_bag;
        break;
      default:
        backgroundColor = Colors.grey[800]!;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Simulate order status notifications
  static void simulateOrderNotifications(BuildContext context, String orderNumber) {
    // Simulate processing notification after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      showInAppNotification(
        context,
        title: 'Order Update',
        message: 'Your order $orderNumber is now being processed!',
        type: 'order',
      );
    });

    // Simulate shipped notification after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      showInAppNotification(
        context,
        title: 'Order Shipped',
        message: 'Your order $orderNumber has been shipped and is on the way!',
        type: 'success',
      );
    });
  }

  // Order status change notifications
  static void notifyOrderStatusChange({
    required BuildContext context,
    required String orderNumber,
    required String oldStatus,
    required String newStatus,
  }) {
    String title;
    String message;
    String type;

    switch (newStatus.toLowerCase()) {
      case 'processing':
        title = 'Order Processing';
        message = 'Your order $orderNumber is now being prepared.';
        type = 'order';
        break;
      case 'shipped':
        title = 'Order Shipped';
        message = 'Your order $orderNumber is on the way! Expected delivery in 2-3 days.';
        type = 'success';
        break;
      case 'delivered':
        title = 'Order Delivered';
        message = 'Your order $orderNumber has been delivered successfully!';
        type = 'success';
        break;
      case 'cancelled':
        title = 'Order Cancelled';
        message = 'Your order $orderNumber has been cancelled.';
        type = 'warning';
        break;
      default:
        title = 'Order Update';
        message = 'Your order $orderNumber status has been updated to $newStatus.';
        type = 'info';
    }

    showInAppNotification(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  // New order confirmation
  static void notifyOrderCreated(BuildContext context, String orderNumber) {
    showInAppNotification(
      context,
      title: 'Order Placed Successfully',
      message: 'Your order $orderNumber has been placed. We\'ll notify you when it\'s ready!',
      type: 'success',
      duration: const Duration(seconds: 5),
    );
  }

  // Reorder notification
  static void notifyReorderSuccess(BuildContext context, String orderNumber) {
    showInAppNotification(
      context,
      title: 'Reorder Successful',
      message: 'Your new order $orderNumber has been placed successfully!',
      type: 'success',
    );
  }

  // Order cancellation notification
  static void notifyOrderCancelled(BuildContext context, String orderNumber) {
    showInAppNotification(
      context,
      title: 'Order Cancelled',
      message: 'Your order $orderNumber has been cancelled successfully.',
      type: 'warning',
    );
  }

  // Prescription ready notification
  static void notifyPrescriptionReady(BuildContext context, String prescriptionId) {
    showInAppNotification(
      context,
      title: 'Prescription Ready',
      message: 'Your prescription $prescriptionId is ready for pickup!',
      type: 'success',
    );
  }

  // Low stock notification (for admin)
  static void notifyLowStock(BuildContext context, String productName) {
    showInAppNotification(
      context,
      title: 'Low Stock Alert',
      message: '$productName is running low in stock.',
      type: 'warning',
    );
  }

  // Promotional notifications
  static void notifyPromotion(BuildContext context, String title, String message) {
    showInAppNotification(
      context,
      title: title,
      message: message,
      type: 'info',
      duration: const Duration(seconds: 6),
    );
  }

  // Get notification history (for notification center)
  static List<Map<String, dynamic>> getNotificationHistory() {
    return List.from(_notifications);
  }

  // Add notification to history
  static void _addToHistory(Map<String, dynamic> notification) {
    notification['timestamp'] = DateTime.now();
    notification['read'] = false;
    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }
  }

  // Mark notification as read
  static void markAsRead(int index) {
    if (index < _notifications.length) {
      _notifications[index]['read'] = true;
    }
  }

  // Get unread notification count
  static int getUnreadCount() {
    return _notifications.where((n) => n['read'] == false).length;
  }

  // Clear all notifications
  static void clearAll() {
    _notifications.clear();
  }

  // Request notification permissions (placeholder for Firebase)
  static Future<bool> requestPermissions() async {
    // In a real implementation, you would request Firebase permissions here
    return true;
  }

  // Get FCM token (placeholder for Firebase)
  static Future<String?> getFCMToken() async {
    // In a real implementation, you would get the FCM token here
    return 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Notification widget for displaying in notification center
class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] ?? false;
    final timestamp = notification['timestamp'] as DateTime?;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey[300] : Colors.blue,
        child: Icon(
          _getIconForType(notification['type'] ?? 'info'),
          color: isRead ? Colors.grey[600] : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        notification['title'] ?? 'Notification',
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification['message'] ?? ''),
          if (timestamp != null)
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      onTap: onTap,
      tileColor: isRead ? null : Colors.blue.withOpacity(0.05),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'order':
        return Icons.shopping_bag;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
