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
  BuildContext? _navigatorContext;

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
    
    BuildContext? targetContext;
    
    // Priority 1: Use stored Navigator context (most reliable)
    if (_navigatorContext != null) {
      debugPrint('🔍 ApiTracker: Checking stored Navigator context...');
      try {
        Navigator.of(_navigatorContext!, rootNavigator: true);
        targetContext = _navigatorContext;
        debugPrint('✅ ApiTracker: Using stored Navigator context');
      } catch (e) {
        debugPrint('⚠️ ApiTracker: Stored Navigator context is invalid: $e');
        _navigatorContext = null; // Clear invalid context
      }
    }
    
    // Priority 2: Use stored MaterialApp context (should have Navigator if captured correctly)
    if (targetContext == null) {
      final materialContext = MaterialAppContext.context;
      if (materialContext != null) {
        debugPrint('🔍 ApiTracker: Checking MaterialApp context for Navigator...');
        try {
          // Try to get Navigator from MaterialApp context
          final navigator = Navigator.maybeOf(materialContext, rootNavigator: true);
          if (navigator != null) {
            targetContext = navigator.context;
            _navigatorContext = navigator.context; // Store it for next time
            debugPrint('✅ ApiTracker: Found Navigator from MaterialApp context');
          } else {
            // If Navigator.maybeOf returns null, try Navigator.of to get the context directly
            try {
              Navigator.of(materialContext, rootNavigator: true);
              targetContext = materialContext;
              _navigatorContext = materialContext; // Store it for next time
              debugPrint('✅ ApiTracker: MaterialApp context itself has Navigator');
            } catch (e) {
              debugPrint('⚠️ ApiTracker: MaterialApp context does not have Navigator: $e');
            }
          }
        } catch (e) {
          debugPrint('⚠️ ApiTracker: Error checking MaterialApp context: $e');
        }
      }
    }
    
    // Priority 3: Try navigator key context (for regular MaterialApp)
    if (targetContext == null) {
      targetContext = widget.navigatorKey?.currentContext;
      if (targetContext != null) {
        debugPrint('✅ ApiTracker: Using navigator key context');
        // Verify it has Navigator
        try {
          Navigator.of(targetContext, rootNavigator: true);
          _navigatorContext = targetContext; // Store it for next time
          debugPrint('✅ ApiTracker: Navigator key context has Navigator');
        } catch (e) {
          debugPrint('⚠️ ApiTracker: Navigator key context does not have Navigator: $e');
          targetContext = null;
        }
      }
    }
    
    // Priority 4: Try current context
    if (targetContext == null) {
      debugPrint('🔍 ApiTracker: Checking current context for Navigator...');
      try {
        final navigator = Navigator.maybeOf(context, rootNavigator: true);
        if (navigator != null) {
          targetContext = navigator.context;
          _navigatorContext = navigator.context; // Store it for next time
          debugPrint('✅ ApiTracker: Found Navigator from current context');
        }
      } catch (e) {
        debugPrint('⚠️ ApiTracker: Error checking current context: $e');
      }
    }
    
    // Priority 5: Try stored context from Builder
    if (targetContext == null && _materialAppContext != null) {
      debugPrint('🔍 ApiTracker: Checking stored Builder context for Navigator...');
      try {
        final navigator = Navigator.maybeOf(_materialAppContext!, rootNavigator: true);
        if (navigator != null) {
          targetContext = navigator.context;
          _navigatorContext = navigator.context; // Store it for next time
          debugPrint('✅ ApiTracker: Found Navigator from stored Builder context');
        }
      } catch (e) {
        debugPrint('⚠️ ApiTracker: Error checking stored Builder context: $e');
      }
    }
    
    // If we still don't have a valid context, we can't show the bottom sheet
    if (targetContext == null) {
      debugPrint('❌ ApiTracker: Could not find a context with Navigator to show bottom sheet');
      debugPrint('   Navigator key available: ${widget.navigatorKey != null}');
      debugPrint('   Navigator key context: ${widget.navigatorKey?.currentContext != null}');
      debugPrint('   MaterialApp context: ${MaterialAppContext.context != null}');
      debugPrint('   Stored context: ${_materialAppContext != null}');
      // Try one more time with a delayed callback to see if Navigator is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔄 ApiTracker: Retrying after frame callback...');
        Future.delayed(const Duration(milliseconds: 100), () {
          _showApiLogs();
        });
      });
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
    
    // Verify the context has Navigator (final check)
    try {
      Navigator.of(targetContext, rootNavigator: true);
      debugPrint('✅ ApiTracker: Context has Navigator (verified)');
    } catch (e) {
      debugPrint('❌ ApiTracker: Context does not have Navigator (final check failed): $e');
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
          // This ensures we have a context with MaterialLocalizations and Navigator
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Try to verify this context has both MaterialLocalizations and Navigator
              try {
                MaterialLocalizations.of(builderContext);
                // Try to find Navigator
                final navigator = Navigator.maybeOf(builderContext, rootNavigator: true);
                if (navigator != null) {
                  _navigatorContext = navigator.context;
                  debugPrint('✅ ApiTracker: Stored Navigator context from Builder');
                }
                if (_materialAppContext == null) {
                  _materialAppContext = builderContext;
                }
              } catch (e) {
                // Context doesn't have required dependencies yet
                if (_materialAppContext == null) {
                  _materialAppContext = builderContext;
                  debugPrint('⚠️ ApiTracker: Stored Builder context (Navigator may not be ready yet)');
                }
              }
            }
          });
          return widget.child;
        },
      ),
    );
  }
}

