# API Tracker - Usage Guide

## Installation

Add this package to your `pubspec.yaml` from GitHub:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  api_tracker:
    git:
      url: https://github.com/YOUR_USERNAME/api_tracker.git
      # Optional: specify a branch, tag, or commit
      # ref: main
```

Then run:
```bash
flutter pub get
```

## Quick Start

### Step 1: Wrap your MaterialApp

In your `main.dart`, wrap your `MaterialApp` with `ApiTracker`:

```dart
import 'package:flutter/material.dart';
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

### Step 2: Use ApiTrackingClient for HTTP requests

Replace your regular `http.Client()` with `ApiTrackingClient`:

```dart
import 'package:http/http.dart' as http;
import 'package:api_tracker/api_tracker.dart';

class ApiService {
  late final http.Client _client;
  final ApiTrackerService _trackerService = ApiTrackerService();

  ApiService() {
    // Create tracking client
    _client = ApiTrackingClient(http.Client(), _trackerService);
  }

  Future<void> fetchData() async {
    // This request will be automatically tracked!
    final response = await _client.get(
      Uri.parse('https://api.example.com/data'),
    );
    // ... handle response
  }

  void dispose() {
    _client.close();
  }
}
```

### Step 3: View API Logs

**Tap anywhere in your app 10 times within 12 seconds** to open the API logs bottom sheet!

The bottom sheet will show:
- ✅ URL
- ✅ Request method (GET, POST, etc.)
- ✅ Request headers
- ✅ Request body
- ✅ Response status code
- ✅ Response body
- ✅ Request duration

## Example: Complete Integration

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiTrackerService _trackerService = ApiTrackerService();
  late final http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    // Initialize tracking client
    _httpClient = ApiTrackingClient(http.Client(), _trackerService);
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> loadData() async {
    // All requests made with _httpClient are automatically tracked
    final response = await _httpClient.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
    );
    
    if (response.statusCode == 200) {
      print('Data loaded: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: loadData,
          child: Text('Load Data'),
        ),
      ),
    );
  }
}
```

## Features

- 🔍 **Automatic Tracking**: All HTTP requests are automatically intercepted
- 📱 **Easy Access**: Tap 10 times anywhere to view logs
- 🎨 **Beautiful UI**: Clean bottom sheet with expandable API call details
- ⏱️ **Performance Metrics**: See request duration for each API call
- 🧹 **Auto Cleanup**: Logs are cleared when app closes
- 🔒 **Non-Intrusive**: Doesn't interfere with normal app interactions

## Notes

- Make sure to use `ApiTrackingClient` instead of regular `http.Client()` for requests you want to track
- The tap detection works anywhere in the app (10 taps within 12 seconds)
- API logs are automatically cleared when the app is closed or paused
- The package requires `http: ^1.2.0` as a dependency

