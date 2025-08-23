// Quick test to check database connection
import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Testing Nine27 Pharmacy Database Connection...\n');
  
  // Test different possible backend URLs
  List<String> testUrls = [
    'http://localhost:8000/api/health',
    'http://127.0.0.1:8000/api/health', 
    'http://10.0.2.2:8000/api/health',
    'http://localhost:3001/api/health',
  ];
  
  for (String url in testUrls) {
    await testConnection(url);
  }
  
  print('\n📋 Summary:');
  print('❌ No backend server is currently running');
  print('💡 You need to set up the Laravel backend first');
  print('\n🚀 Next Steps:');
  print('1. Set up Laravel backend using LARAVEL_SETUP_GUIDE.md');
  print('2. Run: php artisan serve');
  print('3. Test connection again');
}

Future<void> testConnection(String url) async {
  try {
    print('Testing: $url');
    
    HttpClient client = HttpClient();
    client.connectionTimeout = Duration(seconds: 3);
    
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    
    if (response.statusCode == 200) {
      String responseBody = await response.transform(utf8.decoder).join();
      print('✅ Connected! Response: $responseBody\n');
    } else {
      print('❌ Server responded with status: ${response.statusCode}\n');
    }
    
    client.close();
  } catch (e) {
    print('❌ Connection failed: ${e.toString()}\n');
  }
}
