# Integration Example for Real Project

## Step-by-Step Integration

### 1. Add Dependency to Your Project

In your real project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  api_tracker:
    git:
      url: https://github.com/YOUR_USERNAME/api_tracker.git
      ref: main  # or specific branch/tag
```

Run: `flutter pub get`

### 2. Update Your main.dart

**Before:**
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
    );
  }
}
```

**After:**
```dart
import 'package:api_tracker/api_tracker.dart';

void main() {
  runApp(
    ApiTracker(
      materialApp: MaterialApp(
        title: 'My App',
        home: HomePage(),
      ),
    ),
  );
}
```

### 3. Replace HTTP Client in Your Services

**Before:**
```dart
class ApiService {
  final http.Client _client = http.Client();
  
  Future<Response> getData() async {
    return await _client.get(Uri.parse('https://api.example.com/data'));
  }
}
```

**After:**
```dart
import 'package:api_tracker/api_tracker.dart';

class ApiService {
  final ApiTrackerService _trackerService = ApiTrackerService();
  late final http.Client _client;
  
  ApiService() {
    _client = ApiTrackingClient(http.Client(), _trackerService);
  }
  
  Future<Response> getData() async {
    // This will be automatically tracked!
    return await _client.get(Uri.parse('https://api.example.com/data'));
  }
  
  void dispose() {
    _client.close();
  }
}
```

### 4. Test It!

1. Make some API calls in your app
2. Tap anywhere in your app **10 times within 12 seconds**
3. The API logs bottom sheet will appear! 🎉

## Common Patterns

### Using with Dio (if you use Dio instead of http)

You'll need to create a similar interceptor for Dio:

```dart
import 'package:dio/dio.dart';
import 'package:api_tracker/api_tracker.dart';

class DioApiTracker extends Interceptor {
  final ApiTrackerService _trackerService = ApiTrackerService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Track request
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Track response
    super.onResponse(response, handler);
  }
}

// Usage:
final dio = Dio();
dio.interceptors.add(DioApiTracker());
```

### Using with Provider/GetIt

```dart
// In your service locator
final apiTrackerService = ApiTrackerService();
final httpClient = ApiTrackingClient(http.Client(), apiTrackerService);

// Register it
GetIt.instance.registerSingleton<http.Client>(httpClient);
```

## Troubleshooting

**Q: API calls not showing up?**
- Make sure you're using `ApiTrackingClient` instead of regular `http.Client()`
- Check that you've wrapped your app with `ApiTracker`

**Q: Tap detection not working?**
- Make sure you tap 10 times within 12 seconds
- Try tapping on different parts of the screen
- The tap detection works anywhere in the app

**Q: Want to customize the tap count or timeout?**
- Edit `lib/widgets/tap_detector.dart` and change the values:
  - `_tapCount >= 10` → change 10 to your desired count
  - `Duration(seconds: 12)` → change 12 to your desired timeout

