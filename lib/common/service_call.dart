import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import '../common/globs.dart';
import '../common/locator.dart';
import 'package:http/http.dart' as http;

/// Callback for successful HTTP responses with decoded JSON body.
typedef ResSuccess = Future<void> Function(Map<String, dynamic>);

/// Callback for failed HTTP responses or parsing errors.
typedef ResFailure = Future<void> Function(dynamic);

/// Centralized HTTP client for the app.
///
/// Provides GET/POST helpers that:
/// - attach JSON headers and optional Bearer token
/// - serialize query/body
/// - normalize Laravel-style errors (422 validation, message on >=400)
/// - surface results via [ResSuccess]/[ResFailure] callbacks.
class ServiceCall {
  /// App-wide navigator to perform route changes after auth-related calls.
  static final NavigationService navigationService = locator<NavigationService>();

  /// Current authenticated user payload, expected to contain `token` or `access_token`.
  static Map userPayload = {};

  /// Perform an HTTP GET.
  ///
  /// path: Full request URL.
  /// parameters: Query parameters; null values are ignored.
  /// isToken: When true, adds `Authorization: Bearer <token>` from [userPayload].
  /// withSuccess: Receives decoded JSON on success (2xx).
  /// failure: Receives a message or error on non-2xx or exceptions.
  static void get(String path, Map<String, dynamic> parameters,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        // Laravel API expects JSON content type
        var headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

        // Add authorization token if needed
        if (isToken && userPayload.isNotEmpty) {
          String? token = userPayload['token'] ?? userPayload['access_token'];
          if (token != null) {
            headers['Authorization'] = 'Bearer $token';
          }
        }

        // Build query string from parameters
        String queryString = '';
        if (parameters.isNotEmpty) {
          List<String> queryParams = [];
          parameters.forEach((key, value) {
            if (value != null) {
              queryParams.add('$key=${Uri.encodeComponent(value.toString())}');
            }
          });
          if (queryParams.isNotEmpty) {
            queryString = '?${queryParams.join('&')}';
          }
        }

        String fullUrl = path + queryString;

        if (kDebugMode) {
          print('API GET Request: $fullUrl');
          print('Headers: $headers');
        }

        http
            .get(Uri.parse(fullUrl), headers: headers)
            .timeout(const Duration(seconds: 5))
            .then((value) {
          if (kDebugMode) {
            print('API Response Status: ${value.statusCode}');
            print('API Response Body: ${value.body}');
          }

          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            // Handle Laravel validation errors
            if (value.statusCode == 422) {
              String errorMessage = 'Validation failed';
              if (jsonObj['errors'] != null) {
                var errors = jsonObj['errors'] as Map<String, dynamic>;
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
              if (failure != null) failure(errorMessage);
              return;
            }

            // Handle other HTTP errors
            if (value.statusCode >= 400) {
              String errorMessage = jsonObj['message'] ?? 'Request failed';
              if (failure != null) failure(errorMessage);
              return;
            }

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError((e) {
          if (failure != null) {
            if (e is TimeoutException) {
              failure('Request timed out. Please check your connection and ensure the server is running.');
            } else {
              failure('Connection error: ${e.toString()}');
            }
          }
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

  /// Perform an HTTP POST with a JSON body.
  ///
  /// parameter: Request payload that will be JSON-encoded.
  /// path: Full request URL.
  /// isToken: When true, adds `Authorization: Bearer <token>` from [userPayload].
  /// withSuccess: Receives decoded JSON on success (2xx).
  /// failure: Receives a message or error on non-2xx or exceptions.
  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        // Laravel API expects JSON content type
        var headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

        // Add authorization token if needed
        if (isToken && userPayload.isNotEmpty) {
          String? token = userPayload['token'] ?? userPayload['access_token'];
          if (token != null) {
            headers['Authorization'] = 'Bearer $token';
          }
        }

        // Convert parameters to JSON
        String jsonBody = json.encode(parameter);

        if (kDebugMode) {
          print('API Request: $path');
          print('Headers: $headers');
          print('Body: $jsonBody');
        }

        http
            .post(Uri.parse(path), body: jsonBody, headers: headers)
            .timeout(const Duration(seconds: 5))
            .then((value) {
          if (kDebugMode) {
            print('API Response Status: ${value.statusCode}');
            print('API Response Body: ${value.body}');
          }

          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            // Handle Laravel validation errors
            if (value.statusCode == 422) {
              String errorMessage = 'Validation failed';
              if (jsonObj['errors'] != null) {
                var errors = jsonObj['errors'] as Map<String, dynamic>;
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
              if (failure != null) failure(errorMessage);
              return;
            }

            // Handle other HTTP errors
            if (value.statusCode >= 400) {
              String errorMessage = jsonObj['message'] ?? 'Request failed';
              if (failure != null) failure(errorMessage);
              return;
            }

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError((e) {
          if (failure != null) {
            if (e is TimeoutException) {
              failure('Request timed out. Please check your connection and ensure the server is running.');
            } else {
              failure('Connection error: ${e.toString()}');
            }
          }
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

  /// Clear local auth state and redirect to the welcome route.
  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }


}