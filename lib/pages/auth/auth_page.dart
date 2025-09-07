import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/widgets/conditional_widget.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/signin_provider.dart';

class PMAuthPage extends StatelessWidget {
  const PMAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Selector<AuthController, Tuple2<bool, bool>>(
            selector: (context, authController) => Tuple2(
                authController.isAuthenticating,
                authController.isDeletingAccountAndData),
            builder: (context, items, child) {
              bool isAuthenticating = items.item1;
              bool isDeletingAccountAndData = items.item2;
              if (isAuthenticating) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: <Widget>[
                  // Logo and branding section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logos/tryon_icon.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isDeletingAccountAndData
                              ? "Sad to see you go!"
                              : "Try Before You Buy",
                          textAlign: TextAlign.center,
                          style:
                              context.theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDeletingAccountAndData
                              ? "Sign in again to confirm deleting your account"
                              : "See yourself in any outfit instantly with AI.",
                          textAlign: TextAlign.center,
                          style: context.theme.textTheme.bodyLarge?.copyWith(
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Banner image
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/tryon_banner.png',
                          width: context.deviceWidth * 0.6,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Auth buttons section
                  ConditionalWidget(
                    condition: Platform.isIOS || Platform.isMacOS,
                    child: Column(
                      children: [
                        _ModernAuthButton(
                          onPressed: () async {
                            context.authController.signIn(
                                context: context,
                                provider: SigninProvider.apple);
                          },
                          image: appleLogo,
                          text: 'Continue with Apple',
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  _ModernAuthButton(
                    onPressed: () {
                      context.authController.signIn(
                          context: context, provider: SigninProvider.google);
                    },
                    image: googleLogo,
                    text: 'Continue with Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    hasBorder: true,
                  ),
                  const SizedBox(height: 16),
                  // Footer text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                      children: [
                        TextSpan(text: 'By continuing, you agree to our '),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () async {
                              try {
                                final uri = Uri.parse(
                                    'https://picbankai.com/privacy-policy');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  // Fallback: try with platform default
                                  await launchUrl(uri);
                                }
                              } catch (e) {
                                // Handle error gracefully
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Could not open Terms of Service'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Terms of Service',
                              style:
                                  context.theme.textTheme.bodySmall?.copyWith(
                                color: context.theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    context.theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModernAuthButton extends StatelessWidget {
  const _ModernAuthButton({
    required this.image,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.hasBorder = false,
  });

  final String image;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: hasBorder ? 0 : 2,
          shadowColor: Colors.black.withOpacity(0.1),
          side: hasBorder
              ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Image.asset(
          image,
          width: 24,
          height: 24,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
