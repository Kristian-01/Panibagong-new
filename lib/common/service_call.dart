import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../common/globs.dart';
import '../common/locator.dart';
import 'package:http/http.dart' as http;

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};


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
        }).catchError( (e) {
           if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

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
        }).catchError( (e) {
           if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }

  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }


}
