import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_tracker_service.dart';
import 'api_logs_bottom_sheet.dart';
import '../api_tracker.dart' show MaterialAppContext;

class TapDetector extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const TapDetector({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<TapDetector> createState() => _TapDetectorState();
}

class _TapDetectorState extends State<TapDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;
  final ApiTrackerService _trackerService = ApiTrackerService();
  BuildContext? _materialAppContext;

  void _handleTap() {
    setState(() {
      _tapCount++;
    });

    // Cancel existing timer
    _resetTimer?.cancel();

    // If 10 taps reached, show bottom sheet
    if (_tapCount >= 10) {
      _showApiLogs();
      _resetTapCount();
    } else {
      // Start/reset timer for 12 seconds
      _resetTimer = Timer(const Duration(seconds: 12), () {
        _resetTapCount();
      });
    }
  }

  void _resetTapCount() {
    setState(() {
      _tapCount = 0;
    });
    _resetTimer?.cancel();
  }

  void _showApiLogs() {
    final apiCalls = _trackerService.apiCalls;
    
    // Get context from MaterialApp - use the stored context from MaterialApp's builder
    BuildContext? targetContext = MaterialAppContext.context;
    
    // Fallback: try navigator key
    targetContext ??= widget.navigatorKey?.currentContext;
    
    // Fallback: try stored context from Builder
    targetContext ??= _materialAppContext;
    
    // Last resort: try to find root navigator
    targetContext ??= () {
      try {
        final navigator = Navigator.maybeOf(context, rootNavigator: true);
        return navigator?.context;
      } catch (e) {
        return null;
      }
    }();
    
    // If we still don't have a valid context, we can't show the bottom sheet
    if (targetContext == null) {
      debugPrint('ApiTracker: Could not find MaterialApp context to show bottom sheet');
      return;
    }
    
    // Verify the context has MaterialLocalizations
    try {
      MaterialLocalizations.of(targetContext);
    } catch (e) {
      debugPrint('ApiTracker: Context does not have MaterialLocalizations');
      return;
    }
    
    // Show bottom sheet with the valid context
    showModalBottomSheet(
      context: targetContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => ApiLogsBottomSheet(apiCalls: apiCalls),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleTap(),
      behavior: HitTestBehavior.translucent,
      child: Builder(
        builder: (builderContext) {
          // Store the context from inside MaterialApp tree after first frame
          // This ensures we have a context with MaterialLocalizations
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _materialAppContext == null) {
              // Verify this context has MaterialLocalizations before storing
              try {
                MaterialLocalizations.of(builderContext);
                _materialAppContext = builderContext;
              } catch (e) {
                // Context doesn't have MaterialLocalizations yet, will try again later
              }
            }
          });
          return widget.child;
        },
      ),
    );
  }
}

