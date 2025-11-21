import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_tracker_service.dart';
import 'api_logs_bottom_sheet.dart';

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
    
    // Get context from MaterialApp tree - use stored context or navigator
    BuildContext? targetContext = _materialAppContext;
    
    // If we don't have stored context, try to get it from navigator
    if (targetContext == null) {
      // Try navigator key first
      if (widget.navigatorKey?.currentContext != null) {
        targetContext = widget.navigatorKey!.currentContext;
      } else {
        // Try to find root navigator
        try {
          final navigator = Navigator.maybeOf(context, rootNavigator: true);
          targetContext = navigator?.context;
        } catch (e) {
          // If that fails, we'll use the stored context from Builder
        }
      }
    }
    
    // Use stored context from Builder (which is inside MaterialApp tree)
    targetContext ??= _materialAppContext ?? context;
    
    // Show bottom sheet with useRootNavigator to ensure MaterialLocalizations
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

