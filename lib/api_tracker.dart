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

/// Global context storage for MaterialApp context
class MaterialAppContext {
  static BuildContext? _context;
  static void setContext(BuildContext? context) {
    _context = context;
  }
  static BuildContext? get context => _context;
}

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
    MaterialAppContext.setContext(null);
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

  Widget _wrapMaterialApp(Widget app) {
    // If it's MaterialApp (not MaterialApp.router), modify its builder
    if (app is MaterialApp && app.routerConfig == null) {
      return MaterialApp(
        key: app.key,
        navigatorKey: _navigatorKey,
        title: app.title,
        debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
        theme: app.theme,
        darkTheme: app.darkTheme,
        themeMode: app.themeMode,
        home: app.home,
        routes: app.routes ?? const {},
        initialRoute: app.initialRoute,
        onGenerateRoute: app.onGenerateRoute,
        onGenerateInitialRoutes: app.onGenerateInitialRoutes,
        onUnknownRoute: app.onUnknownRoute,
        builder: (context, child) {
          // Store the context from inside MaterialApp
          MaterialAppContext.setContext(context);
          // Ensure child is never null
          final nonNullChild = child ?? const SizedBox.shrink();
          // Call original builder if exists, ensuring we always return Widget
          if (app.builder != null) {
            return app.builder!(context, child);
          }
          return nonNullChild;
        },
        locale: app.locale,
        localizationsDelegates: app.localizationsDelegates,
        supportedLocales: app.supportedLocales,
        localeResolutionCallback: app.localeResolutionCallback,
        localeListResolutionCallback: app.localeListResolutionCallback,
        scrollBehavior: app.scrollBehavior,
      );
    }
    // For MaterialApp.router, wrap with a Builder inside the router
    else if (app is MaterialApp && app.routerConfig != null) {
      return MaterialApp.router(
        key: app.key,
        title: app.title,
        debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
        theme: app.theme,
        darkTheme: app.darkTheme,
        themeMode: app.themeMode,
        routerConfig: app.routerConfig,
        builder: (context, child) {
          // Store the context from inside MaterialApp.router
          MaterialAppContext.setContext(context);
          // Ensure child is never null
          final nonNullChild = child ?? const SizedBox.shrink();
          // Call original builder if exists, ensuring we always return Widget
          if (app.builder != null) {
            return app.builder!(context, child);
          }
          return nonNullChild;
        },
        locale: app.locale,
        localizationsDelegates: app.localizationsDelegates,
        supportedLocales: app.supportedLocales,
        localeResolutionCallback: app.localeResolutionCallback,
        localeListResolutionCallback: app.localeListResolutionCallback,
        scrollBehavior: app.scrollBehavior,
      );
    }
    return app;
  }

  @override
  Widget build(BuildContext context) {
    return TapDetector(
      navigatorKey: _navigatorKey,
      child: _wrapMaterialApp(widget.materialApp),
    );
  }
}

/// Extension to get ApiTrackerService instance
extension ApiTrackerExtension on BuildContext {
  ApiTrackerService get apiTracker => ApiTrackerService();
}
