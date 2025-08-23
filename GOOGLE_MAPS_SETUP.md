# 🗺️ Google Maps Setup Instructions

## Your App Information (IMPORTANT!)
- **Package Name:** `com.example.nine27_pharmacy_app`
- **SHA-1 Fingerprint:** `F7:70:9D:88:DF:BF:20:23:CD:EC:FE:AE:BB:F1:8E:36:23:75:4B:B1`

## Setting up Google Maps for Change Address Feature

The Change Address view requires a Google Maps API key to function properly. Follow these steps to set it up:

### 1. Get Google Maps API Key

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Sign in** with your Google account
3. **Create a new project**:
   - Click "Select a project" at the top
   - Click "New Project"
   - Name it: "Nine27-Pharmacy-App"
   - Click "Create"

4. **Enable Maps SDK for Android**:
   - Go to "APIs & Services" > "Library"
   - Search for "Maps SDK for Android"
   - Click on it and press "Enable"

5. **Create API Key**:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key

6. **Restrict the API Key** (IMPORTANT for security):
   - Click on your newly created API key
   - Under "Application restrictions", select "Android apps"
   - Click "Add an item"
   - Package name: `com.example.nine27_pharmacy_app`
   - SHA-1 certificate fingerprint: `F7:70:9D:88:DF:BF:20:23:CD:EC:FE:AE:BB:F1:8E:36:23:75:4B:B1`
   - Click "Save"

### 2. Update Your App

1. **Open the file**: `android/app/src/main/AndroidManifest.xml`
2. **Find this line**:
   ```xml
   android:value="PASTE_YOUR_GOOGLE_MAPS_API_KEY_HERE"
   ```
3. **Replace** `PASTE_YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key
4. **Save the file**

Example:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" />
```

### 3. Configure iOS (if needed)

Add your API key to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Test Your App

1. **Run the app**: `flutter run`
2. **Tap the location section** on the home screen (the blue highlighted area)
3. **You should see real Google Maps** with interactive features:
   - Search for locations
   - Tap anywhere on the map to select
   - Choose from popular Metro Manila locations
   - Confirm your selection

### 5. Troubleshooting

**Map not loading?**
- Check your API key is correct
- Ensure Maps SDK for Android is enabled
- Check your internet connection
- Verify the API key restrictions

**Billing issues?**
- Google Maps requires a billing account for production use
- Development usage has a free tier

### 6. Security Note

⚠️ **Important**: Never commit your actual API key to version control. Consider using:
- Environment variables
- Build configurations
- Secure key management services

For development, you can temporarily use the key directly, but remove it before committing to Git.
