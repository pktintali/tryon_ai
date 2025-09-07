import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/avatar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/routes_name.dart';
import '../../services/ecom_service.dart';
import '../../services/gemini_service.dart';
import '../../utils/extensions.dart';
import '../../utils/url_utils.dart';
import '../../widgets/scanner_animation.dart';

class SharedItemPreviewPage extends StatefulWidget {
  final File? imageFile;
  final String? textOrUrl;
  final String? title;

  const SharedItemPreviewPage({
    super.key,
    this.imageFile,
    this.textOrUrl,
    this.title,
  });

  @override
  State<SharedItemPreviewPage> createState() => _SharedItemPreviewPageState();
}

class _SharedItemPreviewPageState extends State<SharedItemPreviewPage> {
  bool _loading = false;
  bool _extracting = false;
  bool _initializing = true;
  bool _downloadingImage = false; // Track image download phase
  bool _hasValidProduct = false; // Track if we have a valid product to try on
  String? _productImageUrl;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      // Add a small delay to ensure providers are ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if user is authenticated before proceeding
      final authController =
          Provider.of<AuthController>(context, listen: false);
      if (authController.getCurrentUser == null) {
        // User is not authenticated, show login dialog and prevent access
        _showAuthenticationRequiredDialog();
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
          // Set _hasValidProduct based on whether we have a direct image file or valid product URL
          _hasValidProduct =
              widget.imageFile != null || _productImageUrl != null;
        });
      }
    }
  }

  void _showAuthenticationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to use virtual try-on features. Please sign in to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              // Navigate back to home instead of popping twice
              context.go('/home');
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.pop(); // Close dialog
              // Navigate to auth page using GoRouter
              context.pushNamed(RoutesName.auth);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showNoCreditsDialog(bool isPro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPro ? 'Try Ons Exhausted' : 'No Try Ons Left'),
        content: Text(
          isPro
              ? 'You have exhausted all your try ons for this month. It will reset back on next month.'
              : 'Upgrade to Pro for getting more try ons',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
          if (!isPro)
            FilledButton(
              onPressed: () {
                context.pop();
                final authController = context.read<AuthController>();
                authController.presentPaywallIfNeeded();
              },
              child: const Text('Upgrade to Pro'),
            ),
        ],
      ),
    );
  }

  bool get _canTryOn {
    // Can try on if we have a valid product (image file or extracted product image)
    return _hasValidProduct;
  }

  Future<void> _tryOn() async {
    // Check if we have a valid product first
    if (!_canTryOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid product image available for try-on.'),
        ),
      );
      return;
    }

    // Check authentication first - critical security check
    final authController = context.read<AuthController>();
    if (authController.getCurrentUser == null) {
      _showAuthenticationRequiredDialog();
      return;
    }

    // Check credits second
    if (authController.chatCredits <= 0) {
      _showNoCreditsDialog(authController.isPro);
      return;
    }

    final avatarController = context.read<AvatarProvider>();
    final avatar = avatarController.avatar?.imageFile;

    if (avatar == null) {
      // Prompt user to set up avatar first
      final shouldSetup = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Avatar Required'),
          content: const Text(
            'You need to set up your avatar first to try on products. Would you like to create one now?',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('Set Up Avatar'),
            ),
          ],
        ),
      );

      if (shouldSetup == true && mounted) {
        context.pushNamed(RoutesName.avatarConfig);
      }
      return;
    }

    setState(() {
      _loading = true;
      _downloadingImage = true; // First phase: downloading the image
    });

    try {
      final gemini = GeminiService();

      // Process image if provided directly
      File? productImage;
      String? ecomPlatform;

      if (widget.imageFile != null) {
        // Ensure the file exists and is readable
        if (await widget.imageFile!.exists()) {
          productImage = widget.imageFile!;
          ecomPlatform = 'image_share'; // Direct image sharing
        } else {
          throw Exception('Shared image file is not accessible');
        }
      } else if (_productImageUrl != null) {
        // Download product image temporarily (no gallery save)
        final bytes = await EcomService.downloadImage(_productImageUrl!);
        final dir = await getTemporaryDirectory();
        final tmp = File(
          '${dir.path}/product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tmp.writeAsBytes(bytes);
        productImage = tmp;

        // Determine ecom platform from URL
        final url = UrlUtils.extractUrlFromText(widget.textOrUrl ?? '');
        if (url != null) {
          if (url.contains('amazon.')) {
            ecomPlatform = 'amazon';
          } else if (url.contains('flipkart.')) {
            ecomPlatform = 'flipkart';
          } else if (url.contains('snitch.') || url.contains('theSnitch.')) {
            ecomPlatform = 'snitch';
          } else if (url.contains('nykaa.')) {
            ecomPlatform = 'nykaa';
          } else {
            ecomPlatform = 'unknown_ecom';
          }
        } else {
          ecomPlatform = 'unknown_ecom';
        }

        // Update state: image downloaded, now generating try-on
        if (mounted) {
          setState(() {
            _downloadingImage =
                false; // Image downloaded, now generating try-on
          });
        }
      } else {
        ecomPlatform = 'image_share'; // Fallback for text/URL only
      }

      // Only pass text/URL if no product image is present (to avoid confusing Gemini)
      String? productText;
      if (productImage == null &&
          widget.textOrUrl != null &&
          widget.textOrUrl!.trim().isNotEmpty) {
        productText = widget.textOrUrl!.trim();
      }

      final resultImage = await gemini.tryOn(
        avatarImage: avatar,
        productImage: productImage,
        productTextOrUrl: productText,
      );

      if (mounted) {
        context.pushReplacementNamed(
          RoutesName.tryonResult,
          extra: {
            'resultImage': resultImage,
            'productUrl': UrlUtils.extractUrlFromText(widget.textOrUrl ?? ''),
            'ecomPlatform': ecomPlatform, // Pass the ecom platform
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Enhanced error handling with alert dialog
      String errorTitle = 'Try-On Failed';
      String errorMessage = 'Unable to generate try-on preview';
      
      if (e.toString().contains('500')) {
        errorMessage = 'Server error - please try again or check image quality';
      } else if (e.toString().contains('not accessible')) {
        errorMessage = 'Shared image is not accessible - please try sharing again';
      } else if (e.toString().contains('No candidates')) {
        errorMessage = 'AI could not process the request - try a different image';
      } else if (e.toString().contains('Gemini did not return an image')) {
        errorMessage = 'AI was unable to generate a try-on image. Please try with clearer images of yourself and the product';
      } else {
        errorMessage = e.toString();
      }

      await context.showErrorDialog(
        title: errorTitle,
        message: errorMessage,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _downloadingImage = false; // Reset both states
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = context.watch<AvatarProvider>().hasAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Try On'),
        actions: [
          Consumer<AvatarProvider>(
            builder: (context, avatarProvider, _) {
              return GestureDetector(
                onTap: () {
                  context.pushNamed(RoutesName.avatarConfig);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: avatarProvider.hasAvatar
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            avatarProvider.avatar!.imageFile,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person_add,
                          size: 24,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                ),
              );
            },
          ),
        ],
      ),
      body: _initializing
          ? Center(
              child: _buildAnimatedLoader(theme, isInitializing: true),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: _extracting
                  ? // EXTRACTION STATE: Show Lottie animation
                  Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: _buildAnimatedLoader(theme,
                                isInitializing: false),
                          ),
                        ),
                      ],
                    )
                  : // NORMAL STATE: Show preview content and buttons (with optional scanner overlay)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Main preview content
                                  _buildPreviewContent(theme),

                                  // Scanner overlay when loading
                                  if (_loading)
                                    Positioned.fill(
                                      child: _buildScannerOverlay(theme),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Loading text when scanning
                        if (_loading)
                          Column(
                            children: [
                              if (_downloadingImage)
                                Text(
                                  "Applying the magic 🪄",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Text(
                                  "Generating Try On...",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        Consumer<AuthController>(
                          builder: (context, authController, _) {
                            // Check authentication status
                            bool isAuthenticated =
                                authController.getCurrentUser != null;
                            bool hasCredits = authController.chatCredits > 0;
                            bool isPro = authController.isPro;

                            // If not authenticated, show login required button
                            if (!isAuthenticated) {
                              return FilledButton(
                                onPressed: () =>
                                    _showAuthenticationRequiredDialog(),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.login),
                                    SizedBox(width: 8),
                                    Text('Sign In Required'),
                                  ],
                                ),
                              );
                            }

                            return FilledButton(
                              onPressed: hasCredits && !_loading && _canTryOn
                                  ? _tryOn
                                  : hasCredits && _loading
                                      ? null // Disable when loading but don't show dialog
                                      : !_canTryOn
                                          ? null // Disable when no valid product
                                          : () => _showNoCreditsDialog(isPro),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: !hasCredits || !_canTryOn
                                    ? theme.colorScheme.error
                                    : null, // Keep normal color when loading
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(!_canTryOn
                                      ? Icons.warning
                                      : hasCredits
                                          ? (_loading
                                              ? Icons.hourglass_empty
                                              : Icons.auto_awesome)
                                          : Icons.block),
                                  const SizedBox(width: 8),
                                  Text(!_canTryOn
                                      ? 'No Product Image'
                                      : _loading
                                          ? 'Processing...'
                                          : hasCredits
                                              ? (hasAvatar
                                                  ? 'Try On Me'
                                                  : 'Set Up Avatar & Try On')
                                              : (isPro
                                                  ? 'Try Ons Exhausted'
                                                  : 'No Try Ons Left')),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme) {
    if (_productImageUrl != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _productImageUrl!,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

    if (widget.imageFile != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              widget.imageFile!,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title ?? 'Shared Link',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (widget.textOrUrl != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.textOrUrl!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use the actual constraints of the parent container
            return ScannerAnimation(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child:
                  Container(), // Empty container, the scanner effect will be painted on top
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader(ThemeData theme, {bool isInitializing = false}) {
    // Fun loading messages
    final messages = [
      'Teleporting Your Item Here',
    ];

    // Pick a random message or cycle through them
    final message = messages[DateTime.now().millisecond % messages.length];

    // Adjust size based on whether it's shown during initialization or extraction
    final animationSize = isInitializing ? 200.0 : 120.0;

    // For initializing mode, use a different layout with more spacing
    if (isInitializing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie shopping cart animation with scaling effect (larger version for initializing)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.8, end: 1.1),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: animationSize,
                  height: animationSize,
                  child: Lottie.asset(
                    'assets/lottie/shopping_cart.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to a simple animated container if Lottie fails
                      return Container(
                        width: animationSize,
                        height: animationSize,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: animationSize * 0.4,
                          color: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          // Fun animated text with larger font for initializing
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              final visibleLength = (message.length * value).round();
              // Safely handle substring with boundary checks
              final visibleText = visibleLength <= 0
                  ? ''
                  : (visibleLength >= message.length
                      ? message
                      : message.substring(0, visibleLength));
              return Opacity(
                opacity: value,
                child: Text(
                  visibleText,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Subtle secondary text with fade-in
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value * 0.7,
                child: Text(
                  'Just a moment...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      );
    }

    // Standard implementation for non-initializing state (extraction phase)
    return Column(
      children: [
        // Lottie shopping cart animation with scaling effect
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 2000),
          tween: Tween(begin: 0.8, end: 1.1),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: animationSize,
                height: animationSize,
                child: Lottie.asset(
                  'assets/lottie/shopping_cart.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to a simple animated container if Lottie fails
                    return Container(
                      width: animationSize,
                      height: animationSize,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        size: animationSize * 0.4,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Animated dots before main text
        TweenAnimationBuilder<int>(
          duration: const Duration(milliseconds: 1500),
          tween: IntTween(begin: 0, end: 3),
          builder: (context, dotCount, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index < dotCount
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 12),
        // Fun animated text with typewriter effect
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 2000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            final visibleLength = (message.length * value).round();
            // Safely handle substring with boundary checks
            final visibleText = visibleLength <= 0
                ? ''
                : (visibleLength >= message.length
                    ? message
                    : message.substring(0, visibleLength));
            return Opacity(
              opacity: value,
              child: Text(
                visibleText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Subtle secondary text with fade-in
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value * 0.7,
              child: Text(
                'Getting everything ready for you...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }
}
