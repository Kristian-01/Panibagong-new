import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Backend Connection...\n');
  
  // Test different URLs
  List<String> testUrls = [
    'http://10.0.2.2:8000/api/health',      // Android Emulator
    'http://127.0.0.1:8000/api/health',     // iOS Simulator / Local
    'http://localhost:8000/api/health',     // Local
    'http://192.168.1.6:8000/api/health',   // Network IP
  ];
  
  for (String url in testUrls) {
    print('Testing: $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      
      print('✅ Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Response: ${data['status']} - ${data['service']}');
        print('🎉 SUCCESS! Use this URL in your Flutter app: ${url.replaceAll('/api/health', '')}');
        break;
      } else {
        print('❌ Error: ${response.body}');
      }
    } catch (e) {
      print('❌ Failed: $e');
    }
    print('');
  }
  
  print('\n📋 Next Steps:');
  print('1. Make sure Laravel server is running: cd nine27-pharmacy-backend && php artisan serve --host=0.0.0.0 --port=8000');
  print('2. Update SVKey.mainUrl in lib/common/globs.dart with the working URL');
  print('3. Run: flutter clean && flutter pub get && flutter run');
}