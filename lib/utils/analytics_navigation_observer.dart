import 'package:flutter/material.dart';
import 'package:tryon_ai/services/analytics_helper.dart';

/// A navigation observer that tracks screen views in Mixpanel
class AnalyticsNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackScreenView(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackScreenView(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _trackScreenView(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  void _trackScreenView(Route<dynamic> route) {
    // Skip tracking for dialogs, popups, and other unwanted routes
    if (!_shouldTrackRoute(route)) {
      return;
    }

    // Extract screen name from route
    String screenName = _getScreenNameFromRoute(route);

    // Track screen view using AnalyticsHelper
    if (screenName.isNotEmpty) {
      AnalyticsHelper.trackScreenView(screenName);
    }
  }

  bool _shouldTrackRoute(Route<dynamic> route) {
    // Don't track modal routes (dialogs, bottom sheets, etc.)
    if (route is ModalRoute && route.settings.name == null) {
      return false;
    }

    // Don't track popup routes
    if (route is PopupRoute) {
      return false;
    }

    // Don't track dialog routes
    if (route is DialogRoute) {
      return false;
    }

    // Don't track routes with specific patterns that indicate dialogs/popups
    final routeName = route.settings.name?.toLowerCase() ?? '';
    final blacklistedPatterns = [
      'dialog',
      'popup',
      'modal',
      'bottomsheet',
      'overlay',
      'snackbar',
      'tooltip',
      'alert',
    ];

    for (final pattern in blacklistedPatterns) {
      if (routeName.contains(pattern)) {
        return false;
      }
    }

    // Don't track routes that are of certain types
    final routeType = route.runtimeType.toString().toLowerCase();
    final blacklistedTypes = [
      'dialogroute',
      'popuproute',
      'modalroute',
      'overlay',
      'rawdialog',
    ];

    for (final type in blacklistedTypes) {
      if (routeType.contains(type)) {
        return false;
      }
    }

    // Only track PageRoute and MaterialPageRoute (actual screen navigations)
    return route is PageRoute;
  }

  String _getScreenNameFromRoute(Route<dynamic> route) {
    // Extract meaningful screen name from route
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      // Clean up the route name (remove leading slash, convert to readable format)
      String name = route.settings.name!;
      if (name.startsWith('/')) {
        name = name.substring(1);
      }
      // Convert camelCase or snake_case to Title Case
      return _formatScreenName(name);
    } else if (route.settings.arguments is Map) {
      final args = route.settings.arguments as Map;
      return args['screen_name']?.toString() ?? '';
    } else {
      // Get the name from the route runtimeType for unnamed routes
      String routeType = route.runtimeType.toString();
      // Remove common suffixes
      routeType = routeType
          .replaceAll('Route', '')
          .replaceAll('Page', '')
          .replaceAll('Screen', '');

      // Only return if it's a meaningful name (not generic)
      if (routeType.isNotEmpty &&
          !routeType.toLowerCase().contains('material') &&
          !routeType.toLowerCase().contains('cupertino') &&
          !routeType.toLowerCase().contains('generic')) {
        return _formatScreenName(routeType);
      }

      return '';
    }
  }

  String _formatScreenName(String name) {
    // Convert various naming conventions to readable format
    // Example: "homeScreen" -> "Home Screen", "user_profile" -> "User Profile"

    // Handle camelCase
    name = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Handle snake_case and kebab-case
    name = name.replaceAll('_', ' ').replaceAll('-', ' ');

    // Capitalize first letter of each word
    return name
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ')
        .trim();
  }
}
