import 'package:analytics_service/analytics_service_package.dart';
import 'package:auth_service/auth_service_package.dart';
import 'package:flutter/foundation.dart';
import 'package:purchase_service/purchase_service.dart';

/// Service locator to access all services from one place
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  /// Factory constructor that returns the singleton instance
  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  /// Auth service instance
  final AuthService authService = AuthService();

  /// Purchases service instance
  final PurchasesService purchasesService = PurchasesService();

  /// Analytics service instance
  final analyticsService = AnalyticsService.instance;

  /// Initialize all services
  Future<void> initializeServices({
    required String purchasesApiKey,
    required String mixpanelToken,
    bool purchasesObserverMode = false,
  }) async {
    // Initialize auth service first (no special initialization needed)

    // Initialize analytics service
    await analyticsService.init(mixpanelToken: mixpanelToken);

    // Initialize purchases service
    await purchasesService.initialize(
      apiKey: purchasesApiKey,
      userId: authService.currentUser?.uid,
      observerMode: purchasesObserverMode,
    );

    // Listen to auth state changes to update other services
    authService.authStateChanges.listen((user) {
      if (user != null) {
        // User signed in
        try {
          purchasesService.updateUserId(user.uid);
        } catch (e) {
          debugPrint('Error updating purchases user ID: $e');
        }
      } else {
        // User signed out
        try {
          purchasesService.updateUserId(null);
        } catch (e) {
          debugPrint(
              'Error clearing purchases user ID (likely anonymous user): $e');
          // This is expected when logging out an anonymous user
        }
      }
    });
  }
}
