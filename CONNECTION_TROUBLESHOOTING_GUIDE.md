# Connection Timeout Troubleshooting Guide

If you're still getting connection timeout errors, follow these steps **in order**:

## Step 1: Check What URL Your App Is Using

1. Open `lib/view/login/login_view.dart`
2. Add this debug code in the `btnLogin()` method, right before `serviceCallLogin()`:

```dart
// DEBUG: Print the URL being used
print('🔍 DEBUG - Login URL: ${SVKey.svLogin}');
print('🔍 DEBUG - Base URL: ${SVKey.baseUrl}');
print('🔍 DEBUG - Main URL: ${SVKey.mainUrl}');
```

3. Run the app and try to login
4. Check the console output - it should show `http://10.0.2.2:8000/api/login`
5. **If it still shows `192.168.1.6`**, the app didn't rebuild properly - go to Step 2

## Step 2: Force Complete Rebuild

```bash
# Stop the app completely
# Uninstall the app from your emulator/device manually
# Then run:
flutter clean
flutter pub get
flutter run
```

## Step 3: Start Laravel Server Correctly

Open a **new terminal/command prompt** and run:

```bash
cd c:\Users\kristian\tolongges\nine27-pharmacy-backend
php artisan serve --host=0.0.0.0 --port=8000
```

You should see: `Laravel development server started: http://0.0.0.0:8000`

## Step 4: Test Server Accessibility

### For Android Emulator:
Open the emulator browser and go to: `http://10.0.2.2:8000/api/health`

### For Physical Device:
Open the device browser and go to: `http://192.168.1.6:8000/api/health`

**If the browser can't load it, your app won't either.**

## Step 5: Choose Correct URL Based on Your Environment

Edit `lib/common/globs.dart` and set the correct URL:

### Android Emulator (AVD):
```dart
static const mainUrl = "http://10.0.2.2:8000";
```

### iOS Simulator:
```dart
static const mainUrl = "http://127.0.0.1:8000";
```

### Physical Device (Android/iOS):
```dart
static const mainUrl = "http://192.168.1.6:8000"; // Your PC's IP
```

## Step 6: Fix Network Issues (If Physical Device)

### Check Your PC's IP:
```bash
ipconfig
```
Look for "IPv4 Address" under your Wi-Fi adapter.

### Allow Firewall Access:
1. Open Windows Defender Firewall
2. Click "Advanced settings"
3. Click "Inbound Rules" → "New Rule"
4. Select "Port" → "TCP" → "8000"
5. Select "Allow the connection"

### Ensure Same Network:
- PC and device must be on the same Wi-Fi network
- Some corporate/public Wi-Fi blocks device-to-device communication

## Step 7: Alternative Solutions

### Option A: Use ADB Reverse (Physical Android Device)
```bash
adb reverse tcp:8000 tcp:8000
```
Then use: `static const mainUrl = "http://127.0.0.1:8000";`

### Option B: Use ngrok (Universal Solution)
1. Install ngrok: https://ngrok.com/download
2. Run: `ngrok http 8000`
3. Copy the HTTPS URL (e.g., `https://abc123.ngrok-free.app`)
4. Use: `static const mainUrl = "https://abc123.ngrok-free.app";`

## Step 8: Verify Backend Routes

Test these URLs in your browser/Postman:
- `http://localhost:8000/api/health` (should return JSON)
- `http://localhost:8000/api/test` (should return "API is working!")

## Step 9: Check Laravel Logs

If server is running but not responding:
```bash
cd nine27-pharmacy-backend
tail -f storage/logs/laravel.log
```

## Quick Checklist

- [ ] Laravel server running with `--host=0.0.0.0 --port=8000`
- [ ] Correct URL in `SVKey.mainUrl` for your environment
- [ ] App completely rebuilt (`flutter clean && flutter run`)
- [ ] Browser can access the API health endpoint
- [ ] Firewall allows port 8000 (for physical devices)
- [ ] PC and device on same network (for physical devices)

## Still Not Working?

1. **Try the ngrok solution** (Step 7, Option B) - it works universally
2. **Use the local database** - the app has a built-in SQLite database for testing
3. **Check the console output** - look for the actual URL being called

## Emergency Fallback: Use Local Database

If you can't get the server working, the app has a local SQLite database:

1. Open `lib/view/login/login_view.dart`
2. Replace the `serviceCallLogin()` call with:

```dart
// Use local database instead of API
DatabaseHelper().loginUser(
  email: txtEmail.text.trim(),
  password: txtPassword.text,
).then((result) {
  if (result['success']) {
    // Login successful
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnBoardingView()),
      (route) => false,
    );
  } else {
    mdShowAlert(Globs.appName, result['message'], () {});
  }
});
```

This will let you test the app without needing the Laravel server.