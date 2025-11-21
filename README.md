# API Tracker

A Flutter package to track and monitor all API calls in your app. Tap 10 times anywhere in your app to view API logs in a beautiful bottom sheet.

## Features

- 🔍 **Automatic API Tracking**: Intercepts all HTTP requests automatically
- 📱 **Easy Access**: Tap 10 times within 12 seconds to view logs
- 🎨 **Beautiful UI**: Clean bottom sheet with expandable API call details
- ⏱️ **Performance Metrics**: See request duration for each API call
- 🧹 **Auto Cleanup**: Logs are cleared when app closes
- 🔒 **Non-Intrusive**: Doesn't interfere with normal app interactions

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  api_tracker:
    git:
      url: https://github.com/YOUR_USERNAME/api_tracker.git
  http: ^1.2.0
```

## Quick Start

### 1. Wrap your MaterialApp

```dart
import 'package:api_tracker/api_tracker.dart';

void main() {
  runApp(
    ApiTracker(
      materialApp: MaterialApp(
        title: 'My App',
        home: MyHomePage(),
      ),
    ),
  );
}
```

### 2. Use ApiTrackingClient

```dart
import 'package:http/http.dart' as http;
import 'package:api_tracker/api_tracker.dart';

final _trackerService = ApiTrackerService();
final _httpClient = ApiTrackingClient(http.Client(), _trackerService);

// All requests are automatically tracked!
final response = await _httpClient.get(Uri.parse('https://api.example.com'));
```

### 3. View Logs

**Tap anywhere 10 times within 12 seconds** to open the API logs bottom sheet!

## What's Tracked

- ✅ URL
- ✅ Request method (GET, POST, PUT, DELETE, etc.)
- ✅ Request headers
- ✅ Request body
- ✅ Response status code
- ✅ Response body
- ✅ Request duration
- ✅ Timestamp

## Example

See `lib/main.dart` for a complete working example.

## License

MIT
