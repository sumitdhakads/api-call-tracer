// API Tracker Package
// A Flutter package to track and monitor all API calls in your app.

export 'models/api_call.dart';
export 'services/api_tracker_service.dart';
export 'widgets/api_logs_bottom_sheet.dart';
export 'widgets/tap_detector.dart';

// Main widget
import 'package:flutter/material.dart';
import 'services/api_tracker_service.dart';
import 'widgets/tap_detector.dart';

/// Main widget that wraps MaterialApp to enable API tracking
class ApiTracker extends StatefulWidget {
  final MaterialApp materialApp;

  const ApiTracker({
    super.key,
    required this.materialApp,
  });

  @override
  State<ApiTracker> createState() => _ApiTrackerState();
}

class _ApiTrackerState extends State<ApiTracker>
    with WidgetsBindingObserver {
  final ApiTrackerService _trackerService = ApiTrackerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clear API logs when app is closed
    _trackerService.clearApiCalls();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Clear logs when app is closed/terminated
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      _trackerService.clearApiCalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapDetector(
      child: widget.materialApp,
    );
  }
}

/// Extension to get ApiTrackerService instance
extension ApiTrackerExtension on BuildContext {
  ApiTrackerService get apiTracker => ApiTrackerService();
}
