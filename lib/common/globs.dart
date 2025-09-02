import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Global cart item list
List<Map<String, dynamic>> cartItems = [];

/// Cart counter (ValueNotifier so UI updates automatically)
ValueNotifier<int> cartCount = ValueNotifier<int>(0);

/// Add item to cart (with quantity management)
void addToCart(Map<String, dynamic> item) {
  // Check if item already exists in cart
  int existingIndex = cartItems.indexWhere((cartItem) =>
    cartItem["name"] == item["name"] && cartItem["price"] == item["price"]);

  if (existingIndex != -1) {
    // Item exists, increase quantity
    cartItems[existingIndex]["quantity"] = (cartItems[existingIndex]["quantity"] ?? 1) + 1;
  } else {
    // New item, add with quantity 1
    Map<String, dynamic> newItem = Map<String, dynamic>.from(item);
    newItem["quantity"] = 1;
    cartItems.add(newItem);
  }

  // Update total count (sum of all quantities)
  cartCount.value = cartItems.fold(0, (sum, item) => sum + (item["quantity"] as int? ?? 1));
}

/// Remove one quantity of item from cart
void removeFromCart(int index) {
  if (index >= 0 && index < cartItems.length) {
    int currentQty = cartItems[index]["quantity"] ?? 1;
    if (currentQty > 1) {
      // Decrease quantity
      cartItems[index]["quantity"] = currentQty - 1;
    } else {
      // Remove item completely
      cartItems.removeAt(index);
    }
    // Update total count
    cartCount.value = cartItems.fold(0, (sum, item) => sum + (item["quantity"] as int? ?? 1));
  }
}

/// Remove entire item from cart (all quantities)
void removeItemCompletely(int index) {
  if (index >= 0 && index < cartItems.length) {
    cartItems.removeAt(index);
    cartCount.value = cartItems.fold(0, (sum, item) => sum + (item["quantity"] as int? ?? 1));
  }
}

/// Increase item quantity
void increaseQuantity(int index) {
  if (index >= 0 && index < cartItems.length) {
    cartItems[index]["quantity"] = (cartItems[index]["quantity"] ?? 1) + 1;
    cartCount.value = cartItems.fold(0, (sum, item) => sum + (item["quantity"] as int? ?? 1));
  }
}

/// Decrease item quantity
void decreaseQuantity(int index) {
  if (index >= 0 && index < cartItems.length) {
    int currentQty = cartItems[index]["quantity"] ?? 1;
    if (currentQty > 1) {
      cartItems[index]["quantity"] = currentQty - 1;
      cartCount.value = cartItems.fold(0, (sum, item) => sum + (item["quantity"] as int? ?? 1));
    }
  }
}

/// Clear all cart items
void clearCart() {
  cartItems.clear();
  cartCount.value = 0;
}

/// Get total cart items count
int getCartCount() {
  return cartItems.length;
}

class Globs {
  static const appName = "Food Delivery";

  static const userPayload = "user_payload";
  static const userLogin = "user_login";

  static void showHUD({String status = "loading ....."}) async {
    await Future.delayed(const Duration(milliseconds: 1));
    EasyLoading.show(status: status);
  }

  static void hideHUD() {
    EasyLoading.dismiss();
  }


  static void udSet(dynamic data, String key){
    var jsonStr = json.encode(data);
    prefs?.setString(key, jsonStr);
  }

  static void udStringSet(String data, String key){
    prefs?.setString(key, data);
  }

  static void udBoolSet(bool data, String key) {
    prefs?.setBool(key, data);
  }

  static void udIntSet(int data, String key)  {
    prefs?.setInt(key, data);
  }

  static void udDoubleSet(double data, String key)  {
    prefs?.setDouble(key, data);
  }

  static dynamic udValue(String key) {
    return json.decode(prefs?.get(key) as String? ?? "{}");
  }

  static String udValueString(String key) {
    return prefs?.get(key) as String? ?? "";
  }

  static bool udValueBool(String key) {
    return prefs?.get(key) as bool? ?? false;
  }

  static bool udValueTrueBool(String key) {
    return prefs?.get(key) as bool? ?? true;
  }

  static int udValueInt(String key) {
    return prefs?.get(key) as int? ?? 0;
  }

  static double udValueDouble(String key) {
    return prefs?.get(key) as double? ?? 0.0;
  }

  static void udRemove(String key) {
    prefs?.remove(key);
  }

  static Future<String> timeZone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } on PlatformException {
        return "";
    }
  }
}

class SVKey {
  // Laravel Backend Configuration
  // Use different URLs based on your testing environment:
  // - Android Emulator: "http://10.0.2.2:8000"
  // - iOS Simulator: "http://127.0.0.1:8000"
  // - Desktop/Web: "http://127.0.0.1:8000" (or override)
  // - Physical Device: set via --dart-define=API_URL=http://<YOUR_PC_IP>:8000

  // Optional override via: flutter run --dart-define=API_URL=http://192.168.x.x:8000
  static String get mainUrl {
    const String envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    return _defaultBaseUrl();
  }

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "http://10.0.2.2:8000";
      case TargetPlatform.iOS:
        return "http://127.0.0.1:8000"; // iOS Simulator
      default:
        return "http://127.0.0.1:8000"; // macOS/Linux/Windows
    }
  }

  static String get baseUrl => '$mainUrl/api/';

  // Laravel API Endpoints
  static String get svLogin => '${baseUrl}login';
  static String get svSignUp => '${baseUrl}register';
  static String get svForgotPasswordRequest => '${baseUrl}forgot-password';
  static String get svForgotPasswordVerify => '${baseUrl}verify-otp';
  static String get svForgotPasswordSetNew => '${baseUrl}reset-password';

  // Additional Laravel endpoints
  static String get svProfile => '${baseUrl}profile';
  static String get svUpdateProfile => '${baseUrl}profile/update';
  static String get svLogout => '${baseUrl}logout';

  // Order Management endpoints
  static String get svOrders => '${baseUrl}orders';
  static String get svCreateOrder => '${baseUrl}orders';
  static String get svOrderDetails => '${baseUrl}orders/'; // append order ID
  static String get svCancelOrder => '${baseUrl}orders/'; // append order ID + /cancel
  static String get svReorder => '${baseUrl}orders/'; // append order ID + /reorder
  static String get svTrackOrder => '${baseUrl}orders/track/'; // append order number

  // Product Catalog endpoints
  static String get svProducts => '${baseUrl}products';
  static String get svProductDetails => '${baseUrl}products/'; // append product ID
  static String get svFeaturedProducts => '${baseUrl}products/featured';
  static String get svProductsOnSale => '${baseUrl}products/on-sale';
  static String get svProductSuggestions => '${baseUrl}products/suggestions';
  static String get svCategories => '${baseUrl}categories';
}

class KKey {
  static const payload = "payload";
  static const status = "status";
  static const message = "message";
  static const authToken = "auth_token";
  static const name = "name";
  static const email = "email";
  static const mobile = "mobile";
  static const address = "address";
  static const userId = "user_id";
  static const resetCode = "reset_code";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
}

class MSG {
  static const enterEmail = "Please enter your valid email address.";
  static const enterName = "Please enter your name.";
  static const enterCode = "Please enter valid reset code.";

  static const enterMobile = "Please enter your valid mobile number.";
  static const enterAddress = "Please enter your address.";
  static const enterPassword =
      "Please enter password minimum 6 characters at least.";
  static const enterPasswordNotMatch =
      "Please enter password not match.";
  static const success = "success";
  static const fail = "fail";
}