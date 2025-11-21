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
          // Wrap with Builder to get context after Navigator is built
          Widget result = Builder(
            builder: (navContext) {
              // After Navigator is built, store the context that has Navigator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  // Verify this context has Navigator
                  Navigator.of(navContext, rootNavigator: true);
                  MaterialAppContext.setContext(navContext);
                } catch (e) {
                  // Navigator not available yet, keep the original context
                }
              });
              return child ?? const SizedBox.shrink();
            },
          );
          // Call original builder if exists
          if (app.builder != null) {
            result = app.builder!(context, result);
          }
          return result;
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
          // Wrap with Builder to capture Navigator context after Router builds it
          Widget result = Builder(
            builder: (navContext) {
              // After Navigator is built by Router, store the context that has Navigator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  // Verify this context has Navigator (from Router)
                  Navigator.of(navContext, rootNavigator: true);
                  MaterialAppContext.setContext(navContext);
                  debugPrint('✅ ApiTracker: Navigator context captured from MaterialApp.router');
                } catch (e) {
                  // Navigator not available yet, keep trying
                  debugPrint('⚠️ ApiTracker: Navigator not ready yet in MaterialApp.router: $e');
                }
              });
              return child ?? const SizedBox.shrink();
            },
          );
          // Call original builder if exists
          if (app.builder != null) {
            result = app.builder!(context, result);
          }
          return result;
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
