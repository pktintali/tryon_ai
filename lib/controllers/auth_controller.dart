import 'dart:developer';

import 'package:auth_service/auth_service_package.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:tryon_ai/models/signin_provider.dart';
import 'package:tryon_ai/models/user_info.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/services/service_locator.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/core_utils.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/services/analytics_helper.dart';
import 'package:purchase_service/purchase_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService;
  final PurchasesService _purchasesService;

  AuthController(this._authService, this._purchasesService) {
    // Start listening for purchase updates immediately
    listenForPurchaseUpdates();

    _authService.authStateChanges.listen((user) async {
      _currentUser = user != null ? PmUserInfo.fromUser(user) : null;
      if (_currentUser != null) {
        debugPrint('Configuring Purchases and Credit');
        // Now purchases configuration is handled by the ServiceLocator
        // The ServiceLocator will link user auth state with purchases service
        await _initializeProsStatusAndCredit();
      }
      notifyListeners();
    });
  }

  // to show loading while auth is in progress
  bool _isAuthenticating = false;
  bool _isPaywallLoading = false;
  bool _isEverythingReady = false;
  bool _isDeletingAccountAndData = false;
  // When an exiting pro user installs the app and open it for the first time
  bool _creditNeedSpecialInitialization = false;
  bool _isPro = false;
  int _chatCredits = 1;

  // getter of the loading
  bool get isAuthenticating => _isAuthenticating;

  bool get isPaywallLoading => _isPaywallLoading;

  bool get isEverythingReady => _isEverythingReady;

  bool get isDeletingAccountAndData => _isDeletingAccountAndData;

  bool get isPro => _isPro;

  int get chatCredits => _chatCredits;

  /// Get display-friendly credits (shows credits for pro users)
  String get creditsDisplay => _chatCredits.toString();

  PmUserInfo? _currentUser;

  PmUserInfo? get getCurrentUser => _currentUser;

  Future<String?> getCurrentUserToken() async {
    return await _authService.getIdToken();
  }

  void toggleAuthenticating() {
    _isAuthenticating = !_isAuthenticating;
    notifyListeners();
  }

  void togglePaywallLoading() {
    _isPaywallLoading = !_isPaywallLoading;
    notifyListeners();
  }

  Future<void> logout() async {
    // Track sign out event before signing out
    AnalyticsHelper.trackSignOut();

    await _authService.signOut();
    await Hive.userBox.put(isLoggedInKey, false);
    _currentUser = null;
    _isAuthenticating = false;

    // Reset user tracking data
    AnalyticsHelper.resetUser();

    notifyListeners();
  }

  void turnOnDeletingAccountAndDataFlag() {
    _isDeletingAccountAndData = true;
    notifyListeners();
  }

  Future<void> deleteAccountAndData() async {
    // Track account deletion (you might want to add a custom event for this in AnalyticsEvents)
    // For now we'll use sign out event
    AnalyticsHelper.trackSignOut();

    await _authService.deleteAccount();
    await Hive.deleteFromDisk();
    _currentUser = null;
    _isDeletingAccountAndData = false;

    // Reset user tracking data
    AnalyticsHelper.resetUser();

    notifyListeners();
  }

  void updateUserWithCredentials(UserCredential userCredential) {
    _currentUser = PmUserInfo.fromUserCredential(userCredential);
    notifyListeners();
  }

  void signIn({
    required BuildContext context,
    required SigninProvider provider,
  }) async {
    try {
      toggleAuthenticating();
      final userCredential = provider == SigninProvider.google
          ? await _authService.signInWithGoogle()
          : await _authService.signInWithApple();
      if (userCredential != null) {
        updateUserWithCredentials(userCredential);

        // Track sign in event with provider method
        AnalyticsHelper.trackSignIn(
          method: provider == SigninProvider.google ? 'google' : 'apple',
        );

        // Identify user for analytics
        if (userCredential.user?.uid != null) {
          AnalyticsHelper.identifyUser(userCredential.user!.uid);

          // Set user properties for analytics
          Map<String, dynamic> userProperties = {
            'email': userCredential.user?.email,
            'display_name': userCredential.user?.displayName,
          };
          AnalyticsHelper.setUserProperties(userProperties);
        }

        _initializeProsStatusAndCredit();
        await Hive.userBox.put(isLoggedInKey, true);

        // Mark onboarding as completed since user has signed in
        await Hive.userBox.put(isOnboardingSeenKey, true);

        await Future.delayed(const Duration(seconds: 1));
        if (_isDeletingAccountAndData) {
          if (context.mounted) {
            return await CoreUtils.showConfirmationDialog(
              context: context,
              title: 'Confirm Deleting Your Account?',
              bodyText: 'Click Delete Account to delete your account and data.',
              onConfirm: () async {
                await deleteAccountAndData();
                if (context.mounted) {
                  toggleAuthenticating();
                  context.goNamed(RoutesName.auth);
                  return;
                }
              },
              onCancel: () {
                _isDeletingAccountAndData = false;
                if (context.mounted) {
                  context.goNamed(RoutesName.avatarConfig);
                  return;
                }
              },
              confirmText: 'Delete Account',
              showCancelButton: true,
            );
          }
        }
        // Skip paywall during sign-in, will be shown after avatar config
        // await presentPaywallIfNeeded();

        toggleAuthenticating();
        if (context.mounted) {
          context.goNamed(RoutesName.avatarConfig);
        }
      }
    } catch (e) {
      log(e.toString());
    }
    toggleAuthenticating();
  }

  Future<bool> presentPaywallIfNeeded() async {
    try {
      bool wasUserPro = _isPro;
      final paywallResult = await _purchasesService.presentPaywallIfNeeded(
        entitlement: 'pro',
        showCloseButton: true,
      );

      // Store the paywall result

      if (paywallResult == PaywallResult.purchased) {
        _isPro = true;
        await Hive.creditBox.put(chatCreditKey, proMonthlyCredits);
        _chatCredits = proMonthlyCredits;
        // Set the monthly reset timestamp
        final now = DateTime.now();
        Hive.timeStampBox
            .put(lastMonthTimeStampKey, now.millisecondsSinceEpoch);
        notifyListeners();
      } else if (paywallResult == PaywallResult.restored) {
        // After restore, verify the actual subscription status from customer info
        try {
          final customerInfo = await _purchasesService.getCustomerInfo();
          EntitlementInfo? pro = customerInfo.entitlements.all['pro'];
          bool hasActiveSubscription = pro?.isActive ?? false;

          if (hasActiveSubscription) {
            _isPro = true;
            if (!wasUserPro) {
              await Hive.creditBox.put(chatCreditKey, proMonthlyCredits);
              _chatCredits = proMonthlyCredits;
              // Set the monthly reset timestamp
              final now = DateTime.now();
              Hive.timeStampBox
                  .put(lastMonthTimeStampKey, now.millisecondsSinceEpoch);
            }
            log('Restore successful: User has active pro subscription');
          } else {
            _isPro = false;
            log('Restore attempted but no active subscription found');
          }
        } catch (e) {
          // If we can't verify subscription status, don't grant pro access
          _isPro = false;
          log('Error verifying subscription during restore: $e');
        }
        notifyListeners();
      }
      log('Paywall result: $paywallResult');
      return _isPro;
    } catch (e) {
      log('Error Presenting Paywall: $e');
      return false;
    }
  }

  Future<void> _initializeProsStatusAndCredit() async {
    try {
      // Get current customer info to check subscription status
      final customerInfo = await _purchasesService.getCustomerInfo();
      EntitlementInfo? pro = customerInfo.entitlements.all['pro'];
      _isPro = pro?.isActive ?? false;

      debugPrint('✅ Pro status initialized: $_isPro');

      // Initialize credits based on pro status
      _initializeCredit();

      // Log final state
      logCurrentState();
    } catch (e) {
      debugPrint('⚠️ Error initializing pro status: $e');
      // Fallback to credit initialization without pro status
      _initializeCredit();
      logCurrentState();
    }
  }

  void _initializeCredit() {
    int? credit = Hive.creditBox.get(chatCreditKey);

    if (credit == null) {
      // First time installing the app
      if (_isPro) {
        _chatCredits = proMonthlyCredits; // Give 60 credits for new pro users
      } else {
        _chatCredits =
            freeUserInitialCredits; // Give 2 free credits for first-time users
      }
      Hive.userBox
          .put(isFirstTimeUserKey, false); // Mark as no longer first-time
      _creditNeedSpecialInitialization = true;
    } else {
      // If user is pro, check for monthly reset
      if (_isPro) {
        _chatCredits = credit;
        _checkAndResetMonthlyCredits();
      } else {
        // If user is not pro but has pro credits stored (was pro before), reset to 0
        if (credit > freeUserInitialCredits) {
          _chatCredits = 0;
          Hive.creditBox.put(chatCreditKey, 0);
          debugPrint('🔄 Non-pro user had pro credits - Reset to 0');
        } else {
          //TODO: Use credit in production
          // _chatCredits = credit;
          _chatCredits = 2;
        }
      }
    }
    notifyListeners();
    // Complete initialization
    _isEverythingReady = true;
    notifyListeners();
  }

  void _checkAndResetMonthlyCredits() {
    final lastResetTimestamp = Hive.timeStampBox.get(lastMonthTimeStampKey);
    final now = DateTime.now();

    if (lastResetTimestamp == null) {
      // First time, set the timestamp
      Hive.timeStampBox.put(lastMonthTimeStampKey, now.millisecondsSinceEpoch);
    } else {
      final then = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);

      // Check if a month has passed (different month or different year)
      if (now.year != then.year || now.month != then.month) {
        // Reset monthly credits for pro users
        Hive.timeStampBox
            .put(lastMonthTimeStampKey, now.millisecondsSinceEpoch);
        _chatCredits = proMonthlyCredits;
        Hive.creditBox.put(chatCreditKey, _chatCredits);

        debugPrint('🔄 Monthly credits reset for pro user: $proMonthlyCredits');

        // Track monthly credit refresh using service locator
        ServiceLocator().analyticsService.trackEvent(
          'monthly_credit_refreshed',
          properties: {
            'new_credit_amount': _chatCredits,
            'user_type': 'pro',
          },
        );
      }
    }
  }

  void decrementCredit(BuildContext context) {
    // Both pro and non-pro users consume credits now
    if (chatCredits > 0) {
      _chatCredits--;
      Hive.creditBox.put(chatCreditKey, _chatCredits);

      // Track credit spent event
      AnalyticsHelper.trackCreditSpent(
        feature: 'tryon_query', // Updated feature name for TryOn AI
        remainingCredits: _chatCredits,
      );

      // Track credit limit reached if this was the last credit
      if (_chatCredits == 0) {
        AnalyticsHelper.trackCreditLimitReached(
          feature: 'tryon_query',
        );
      }

      notifyListeners();
    }
  }

  /// Debug method to log current pro status and credits
  void logCurrentState() {
    debugPrint('🔍 AuthController State:');
    debugPrint('   - isPro: $_isPro');
    debugPrint('   - chatCredits: $_chatCredits');
    debugPrint('   - currentUser: ${_currentUser?.uid}');
    debugPrint('   - isEverythingReady: $_isEverythingReady');
  }

  // Use the purchases service to listen for subscription changes
  void listenForPurchaseUpdates() {
    final purchasesService = ServiceLocator().purchasesService;
    purchasesService.customerInfoStream.listen((customerInfo) async {
      EntitlementInfo? pro = customerInfo.entitlements.all['pro'];
      bool wasProBefore = _isPro;
      _isPro = pro?.isActive ?? false;

      debugPrint(
          '🔄 Purchase update received - Pro status: $_isPro (was: $wasProBefore)');

      // If user became pro, give them monthly credits
      if (_isPro && (_creditNeedSpecialInitialization || !wasProBefore)) {
        await Hive.creditBox.put(chatCreditKey, proMonthlyCredits);
        _chatCredits = proMonthlyCredits;
        // Set the monthly reset timestamp
        final now = DateTime.now();
        Hive.timeStampBox
            .put(lastMonthTimeStampKey, now.millisecondsSinceEpoch);
        _creditNeedSpecialInitialization = false;
        debugPrint(
            '✅ Monthly credits ($proMonthlyCredits) granted for new pro user');
      }
      // If existing pro user, check for monthly reset
      else if (_isPro && wasProBefore) {
        _checkAndResetMonthlyCredits();
      }
      // If user lost pro status (subscription expired), reset credits to 0
      else if (!_isPro && wasProBefore) {
        await Hive.creditBox.put(chatCreditKey, 0);
        _chatCredits = 0;
        debugPrint('🔄 Pro subscription expired - Credits reset to 0');

        // Track subscription cancellation/expiration using the service locator
        ServiceLocator().analyticsService.trackEvent(
          'subscription_expired',
          properties: {
            'previous_status': 'pro',
            'new_status': 'free',
            'credits_reset_to': 0,
          },
        );
      }

      notifyListeners();
      logCurrentState();
    });
  }
}
