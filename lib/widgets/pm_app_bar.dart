import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/services/analytics_helper.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

class PMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PMAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      notificationPredicate: (_) => false,
      title: Row(
        children: [
          Image.asset(
            appIconPng,
            height: 30,
          ),
          const SizedBox(width: 4),
          const Text('TryOn AI'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () async {
            // Track share button click
            AnalyticsHelper.trackAppShared(
              platform: Platform.isIOS ? 'ios' : 'android',
            );

            await Share.share(
              Platform.isIOS
                  ? 'com.apple.pm.app'
                  : 'https://play.google.com/store/apps/details?id=com.ai.tryon.clothes.outfits',
              subject: 'Share TryOn AI',
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: _CreditsWidget(),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: _AccountWidget(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CreditsWidget extends StatelessWidget {
  const _CreditsWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Selector<AuthController, Tuple2<int, bool>>(
      selector: (context, authController) =>
          Tuple2(authController.chatCredits, authController.isPro),
      builder: (context, items, _) {
        int credits = items.item1;
        bool isPro = items.item2;

        final backgroundColor = isPro
            ? (isDark
                ? Colors.green.shade700.withOpacity(0.2)
                : Colors.green.shade50)
            : (isDark
                ? Colors.orange.shade700.withOpacity(0.2)
                : Colors.orange.shade50);

        final borderColor = isPro
            ? (isDark ? Colors.green.shade400 : Colors.green.shade300)
            : (isDark ? Colors.orange.shade400 : Colors.orange.shade300);

        final iconColor = isPro
            ? (isDark ? Colors.green.shade300 : Colors.green.shade600)
            : (isDark ? Colors.orange.shade300 : Colors.orange.shade600);

        final textColor = isPro
            ? (isDark ? Colors.green.shade200 : Colors.green.shade700)
            : (isDark ? Colors.orange.shade200 : Colors.orange.shade700);

        return GestureDetector(
          onTap: () {
            _CreditsInfoDialog.show(context, credits, isPro);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isPro ? Colors.green : Colors.orange).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPro ? Icons.diamond_sharp : Icons.flash_on_rounded,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  credits.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountWidget extends StatelessWidget {
  const _AccountWidget();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Track profile/settings button click
        AnalyticsHelper.trackScreenView('Settings');
        context.pushNamed(RoutesName.settings);
      },
      child: Builder(builder: (context) {
        if (context.authConGetCurrUserR == null) {
          return const CircleAvatar(
            radius: 16,
            child: Icon(Icons.account_circle_rounded),
          );
        }
        return CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(context.authConGetCurrUserR!.photoURL ??
              'https://static.vecteezy.com/system/resources/previews/008/302/513/original/eps10-blue-user-icon-or-logo-in-simple-flat-trendy-modern-style-isolated-on-white-background-free-vector.jpg'),
        );
      }),
    );
  }
}

/// Dialog that shows detailed information about credits
class _CreditsInfoDialog extends StatelessWidget {
  final int credits;
  final bool isPro;

  const _CreditsInfoDialog({
    required this.credits,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.95, // Increased from 0.9 to 0.95
        constraints: BoxConstraints(
          maxWidth: 500, // Added maximum width constraint for larger screens
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 20, 16, 20), // Reduced left/right padding
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPro
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPro ? Icons.diamond_sharp : Icons.flash_on_rounded,
                      color: isPro ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Try Ons Quota',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPro ? 'Pro Account' : 'Free Account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isPro ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    20, 0, 20, 20), // Reduced horizontal padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Credits
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                          18), // Slightly increased for better visual balance
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Try Ons Left',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            credits.toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPro ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Try Ons Quota
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                          18), // Increased for better content spacing
                      decoration: BoxDecoration(
                        color: isPro
                            ? Colors.green.withOpacity(0.05)
                            : Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPro
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPro ? Icons.all_inclusive : Icons.schedule,
                                color: isPro ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Try Ons Quota',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isPro ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Free Users',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '1 try-on only',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'No refresh',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                              const SizedBox(
                                  width:
                                      12), // Reduced from 16 to 12 for better space utilization
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pro Users',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '60 try-ons per month',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Resets monthly',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cost explanation message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                          18), // Increased for better readability
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.construction_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Try-ons have limited availability due to AI processing costs. We aim to keep our service as affordable as possible.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!isPro) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            AnalyticsHelper
                                .trackUpgradeButtonClickedFromSettings();
                            context
                                .read<AuthController>()
                                .presentPaywallIfNeeded();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.diamond,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Upgrade to Pro',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, int credits, bool isPro) {
    // Track analytics event
    AnalyticsHelper.trackScreenView('Credits Info Dialog');

    showDialog(
      context: context,
      builder: (context) => _CreditsInfoDialog(
        credits: credits,
        isPro: isPro,
      ),
    );
  }
}
