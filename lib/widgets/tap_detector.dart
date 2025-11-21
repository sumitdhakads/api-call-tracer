import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_tracker_service.dart';
import 'api_logs_bottom_sheet.dart';

class TapDetector extends StatefulWidget {
  final Widget child;

  const TapDetector({
    super.key,
    required this.child,
  });

  @override
  State<TapDetector> createState() => _TapDetectorState();
}

class _TapDetectorState extends State<TapDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;
  final ApiTrackerService _trackerService = ApiTrackerService();

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      child: widget.child,
    );
  }
}

