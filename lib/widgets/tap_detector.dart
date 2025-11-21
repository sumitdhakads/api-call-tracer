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

    // Debug print for every tap
    debugPrint('🔵 ApiTracker: Tap detected! Count: $_tapCount/10');

    // Cancel existing timer
    _resetTimer?.cancel();

    // If 10 taps reached, show bottom sheet
    if (_tapCount >= 10) {
      debugPrint('✅ ApiTracker: 10 taps reached! Opening API logs...');
      _showApiLogs();
      _resetTapCount();
    } else {
      debugPrint('⏱️ ApiTracker: Timer reset. Need ${10 - _tapCount} more taps within 12 seconds');
      // Start/reset timer for 12 seconds
      _resetTimer = Timer(const Duration(seconds: 12), () {
        debugPrint('⏰ ApiTracker: Timer expired. Resetting tap count.');
        _resetTapCount();
      });
    }
  }

  void _resetTapCount() {
    setState(() {
      _tapCount = 0;
    });
    _resetTimer?.cancel();
    debugPrint('🔄 ApiTracker: Tap count reset to 0');
  }

  void _showApiLogs() {
    final apiCalls = _trackerService.apiCalls;
    debugPrint('📊 ApiTracker: Preparing to show API logs. Total API calls: ${apiCalls.length}');
    
    // Priority 1: Use navigator key context (should have Navigator since it's passed to MaterialApp)
    BuildContext? targetContext = widget.navigatorKey?.currentContext;
    if (targetContext != null) {
      debugPrint('✅ ApiTracker: Using navigator key context');
      // Verify it has Navigator
      try {
        Navigator.of(targetContext, rootNavigator: true);
        debugPrint('✅ ApiTracker: Navigator key context has Navigator');
      } catch (e) {
        debugPrint('⚠️ ApiTracker: Navigator key context does not have Navigator, trying alternatives...');
        targetContext = null;
      }
    }
    
    // Priority 2: Try to find Navigator from any available context
    if (targetContext == null) {
      // Try MaterialApp context
      final materialContext = MaterialAppContext.context;
      if (materialContext != null) {
        try {
          final navigator = Navigator.maybeOf(materialContext, rootNavigator: true);
          if (navigator != null) {
            targetContext = navigator.context;
            debugPrint('✅ ApiTracker: Found Navigator from MaterialApp context');
          }
        } catch (e) {
          // Continue trying
        }
      }
      
      // Try current context
      if (targetContext == null) {
        try {
          final navigator = Navigator.maybeOf(context, rootNavigator: true);
          if (navigator != null) {
            targetContext = navigator.context;
            debugPrint('✅ ApiTracker: Found Navigator from current context');
          }
        } catch (e) {
          // Continue trying
        }
      }
      
      // Try stored context
      if (targetContext == null && _materialAppContext != null) {
        try {
          final navigator = Navigator.maybeOf(_materialAppContext!, rootNavigator: true);
          if (navigator != null) {
            targetContext = navigator.context;
            debugPrint('✅ ApiTracker: Found Navigator from stored context');
          }
        } catch (e) {
          // All attempts failed
        }
      }
    }
    
    // If we still don't have a valid context, we can't show the bottom sheet
    if (targetContext == null) {
      debugPrint('❌ ApiTracker: Could not find a context with Navigator to show bottom sheet');
      debugPrint('   Navigator key available: ${widget.navigatorKey != null}');
      debugPrint('   Navigator key context: ${widget.navigatorKey?.currentContext != null}');
      debugPrint('   MaterialApp context: ${MaterialAppContext.context != null}');
      debugPrint('   Stored context: ${_materialAppContext != null}');
      return;
    }
    
    // Verify the context has MaterialLocalizations
    try {
      MaterialLocalizations.of(targetContext);
      debugPrint('✅ ApiTracker: Context has MaterialLocalizations');
    } catch (e) {
      debugPrint('❌ ApiTracker: Context does not have MaterialLocalizations: $e');
      return;
    }
    
    // Show bottom sheet with the valid context
    debugPrint('🚀 ApiTracker: Showing bottom sheet with ${apiCalls.length} API calls');
    try {
      showModalBottomSheet(
        context: targetContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (context) {
          debugPrint('✅ ApiTracker: Bottom sheet builder called successfully');
          return ApiLogsBottomSheet(apiCalls: apiCalls);
        },
      );
      debugPrint('✅ ApiTracker: Bottom sheet shown successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ ApiTracker: Error showing bottom sheet: $e');
      debugPrint('Stack trace: $stackTrace');
    }
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

