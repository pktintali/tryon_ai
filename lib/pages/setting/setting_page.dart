import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/services/analytics_helper.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/core_utils.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import 'supported_platforms_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({
    super.key,
    this.fromTab = false,
  });

  final bool fromTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !fromTab
          ? AppBar(
              notificationPredicate: (_) => false,
              title: const Text('Settings'),
            )
          : null,
      body: Selector<AppController, bool>(
        selector: (context, appController) => appController.isDarkMode,
        builder: (context, isDarkMode, _) {
          return ListView(
            children: [
              ExpansionTile(
                title: Text(
                  'Account',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                initiallyExpanded: true,
                shape: Border(
                  bottom: BorderSide(color: context.theme.dividerColor),
                ),
                children: [
                  Builder(builder: (context) {
                    final user = context.authController.getCurrentUser;
                    if (user == null) {
                      return ListTile(
                        title: const Text('No user signed in'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.goNamed(RoutesName.auth);
                          },
                          child: const Text('Sign In'),
                        ),
                      );
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoURL ??
                            'https://static.vecteezy.com/system/resources/previews/008/302/513/original/eps10-blue-user-icon-or-logo-in-simple-flat-trendy-modern-style-isolated-on-white-background-free-vector.jpg'),
                      ),
                      title: (user.displayName ?? '').isNotEmpty
                          ? Text(user.displayName ?? '')
                          : Text(user.email),
                      subtitle: (user.displayName ?? '').isNotEmpty
                          ? Text(user.email)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          CoreUtils.showConfirmationDialog(
                            context: context,
                            title: 'Confirm Logout',
                            bodyText: 'Are you sure you want to log out?',
                            onConfirm: () async {
                              context.pop();
                              await context.authController.logout();
                              if (context.mounted) {
                                context.goNamed(RoutesName.auth);
                              }
                            },
                          );
                        },
                      ),
                    );
                  }),
                  Selector<AuthController, Tuple2<int, bool>>(
                    selector: (context, authController) => Tuple2(
                        authController.chatCredits, authController.isPro),
                    builder: (context, items, _) {
                      int credits = items.item1;
                      bool isPro = items.item2;
                      return ListTile(
                        leading: const Icon(
                          Icons.flash_on_rounded,
                          size: 40,
                          color: Colors.amber,
                        ),
                        title: const Text("Try Ons left"),
                        subtitle: Text(
                          credits.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: isPro
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Pro',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  // Track upgrade button click from settings
                                  AnalyticsHelper
                                      .trackUpgradeButtonClickedFromSettings();
                                  context.authController
                                      .presentPaywallIfNeeded();
                                },
                                child: const Text(
                                  'Upgrade',
                                ),
                              ),
                      );
                    },
                  ),
                  const Divider(
                    thickness: 0.6,
                  ),
                  ListTile(
                    title: const Text('Manage Subscription'),
                    leading: const Icon(Icons.payments),
                    onTap: () async {
                      // Track manage subscription click event
                      AnalyticsHelper.trackManageSubscription();

                      String url;
                      if (Platform.isAndroid) {
                        url =
                            'https://play.google.com/store/account/subscriptions';
                      } else if (Platform.isIOS) {
                        url = 'https://apps.apple.com/account/subscriptions';
                      } else {
                        return;
                      }
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Could not open subscription page')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Delete your account & data'),
                    leading: const Icon(Icons.person_off_outlined),
                    onTap: () {
                      // Don't track here - will track in onConfirm to avoid duplicate events
                      CoreUtils.showConfirmationDialog(
                        context: context,
                        title: 'Delete Account?',
                        bodyText:
                            'Are you sure you want to delete your account and data permanently? This action cannot be undone. If you have any active subscription, please cancel it first. You need to login again to compete this process.',
                        onConfirm: () async {
                          // Only track delete account event once, when user confirms
                          AnalyticsHelper.trackDeleteAccount();

                          context.authController
                              .turnOnDeletingAccountAndDataFlag();
                          await context.authController.logout();
                          if (context.mounted) {
                            if (context.canPop()) {
                              context.pop();
                            }
                            context.goNamed(RoutesName.auth);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Appearance',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                initiallyExpanded: true,
                shape: Border(
                  bottom: BorderSide(color: context.theme.dividerColor),
                ),
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Dark Theme'),
                    value: isDarkMode,
                    onChanged: (bool value) {
                      context.appController.setTheme(value);
                      // Track theme change event
                      AnalyticsHelper.trackThemeChanged(
                        newTheme: value ? 'dark' : 'light',
                      );
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Help Center',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                initiallyExpanded: true,
                shape: Border(
                  bottom: BorderSide(color: context.theme.dividerColor),
                ),
                children: [
                  ListTile(
                    title: const Text('Help & Support'),
                    leading: const Icon(Icons.help_outline),
                    onTap: () {
                      // Track help & support click event
                      AnalyticsHelper.trackHelpAndSupportClicked();
                      context.goNamed(RoutesName.support);
                    },
                  ),
                  ListTile(
                    title: const Text('Supported Platforms'),
                    leading: const Icon(Icons.store),
                    onTap: () {
                      // Navigate to supported platforms page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SupportedPlatformsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'About',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                initiallyExpanded: true,
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    // Track about section click event
                    AnalyticsHelper.trackAboutClicked();
                  }
                },
                shape: Border(
                  bottom: BorderSide(color: context.theme.dividerColor),
                ),
                children: [
                  AboutListTile(
                    applicationVersion: 'v1.0.0',
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        appLogo,
                        height: 60,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
