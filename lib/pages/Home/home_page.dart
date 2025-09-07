import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tryon_ai/widgets/pm_app_bar.dart';
import 'package:provider/provider.dart';

import '../../controllers/avatar_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/gemini_service.dart';
import '../../utils/extensions.dart';
import '../tryon/avatar_setup_page.dart';
import '../tryon/tryon_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  File? _selectedProductImage;
  File? _temporaryAvatarImage; // Temporary avatar selection
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  late AnimationController _scannerController;
  late AnimationController _plusController;
  late AnimationController _pulseController;
  late Animation<double> _scannerAnimation;
  late Animation<double> _plusRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scanner animation - moves from top to bottom
    _scannerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    // Plus icon rotation animation
    _plusController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _plusRotation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _plusController, curve: Curves.easeInOut),
    );

    // Pulse animation for the plus icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _plusController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _selectProductImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Product Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickImage(ImageSource.camera);
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.camera_alt, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Camera'),
                  ],
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickImage(ImageSource.gallery);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.photo_library, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gallery'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAvatarImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select A Different Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAvatarImage(ImageSource.camera);
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.camera_alt, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Camera'),
                  ],
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAvatarImage(ImageSource.gallery);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.photo_library, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gallery'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectInitialAvatar() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Set Up Your Avatar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAndSaveAvatar(ImageSource.camera);
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.camera_alt, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Camera'),
                  ],
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAndSaveAvatar(ImageSource.gallery);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.photo_library, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gallery'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (picked != null) {
      setState(() {
        _selectedProductImage = File(picked.path);
      });
    }
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (picked != null && mounted) {
      setState(() {
        _temporaryAvatarImage = File(picked.path);
      });
    }
  }

  Future<void> _pickAndSaveAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (picked != null && mounted) {
      final provider = context.read<AvatarProvider>();
      await provider.setAvatar(File(picked.path));
    }
  }

  Future<void> _tryOn() async {
    final avatarFile = _temporaryAvatarImage ??
        context.read<AvatarProvider>().avatar?.imageFile;
    if (avatarFile == null || _selectedProductImage == null) return;

    setState(() => _loading = true);

    // Start animations
    _scannerController.repeat();
    _plusController.repeat();
    _pulseController.repeat(reverse: true);

    try {
      final gemini = GeminiService();
      final resultImage = await gemini.tryOn(
        avatarImage: avatarFile,
        productImage: _selectedProductImage!,
        productTextOrUrl: null,
      );

      if (!mounted) return;

      // Clear the selected product image and temporary avatar before navigating
      setState(() {
        _selectedProductImage = null;
        _temporaryAvatarImage = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TryOnResultPage(
            resultImage: resultImage,
            ecomPlatform: 'TryOn_Home', // Home page try-on (removed trailing _)
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error dialog instead of SnackBar for better visibility
      await context.showErrorDialog(
        title: 'Try-On Failed',
        message: 'Unable to generate try-on preview: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        // Stop animations
        _scannerController.stop();
        _plusController.stop();
        _pulseController.stop();
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _scannerAnimation,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.scrim.withOpacity(0.3),
          ),
          child: Stack(
            children: [
              // Scanning line
              Positioned(
                top: _scannerAnimation.value *
                    (MediaQuery.of(context).size.height * 0.4),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.secondary.withOpacity(0.8),
                        theme.colorScheme.primary.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Grid overlay effect
              CustomPaint(
                painter: ScannerGridPainter(
                    _scannerAnimation.value, theme.colorScheme.primary),
                size: Size.infinite,
              ),
              // Center processing text
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedProductImage = null;
    });
  }

  void _clearTemporaryAvatar() {
    setState(() {
      _temporaryAvatarImage = null;
    });
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (!isPro)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                final authController = context.read<AuthController>();
                authController.presentPaywallIfNeeded();
              },
              child: const Text('Upgrade to Pro'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PMAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Avatar Section - Full image in natural shape
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Consumer<AvatarProvider>(
                  builder: (context, provider, __) => Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => provider.hasAvatar
                                  ? _selectAvatarImage()
                                  : _selectInitialAvatar(),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: theme.colorScheme.surface,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: _temporaryAvatarImage != null
                                      ? Image.file(
                                          _temporaryAvatarImage!,
                                          fit: BoxFit.contain,
                                        )
                                      : provider.avatar?.imageFile != null
                                          ? Image.file(
                                              provider.avatar!.imageFile,
                                              fit: BoxFit.contain,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_add,
                                                  size: 48,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Set Up Avatar',
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tap to choose from camera or gallery',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                            // Avatar action buttons - only show when avatar exists
                            if (!_loading &&
                                (provider.avatar?.imageFile != null ||
                                    _temporaryAvatarImage != null))
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    // Switch avatar icon
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.primaryContainer
                                            .withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: _selectAvatarImage,
                                        icon: Icon(
                                          Icons.switch_camera,
                                          color: theme.colorScheme.onSurface,
                                          size: 16,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Switch avatar',
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Clear temporary avatar or Edit avatar icon
                                    if (_temporaryAvatarImage != null)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: _clearTemporaryAvatar,
                                          icon: Icon(
                                            Icons.close,
                                            color: theme.colorScheme.onSurface,
                                            size: 16,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                            minHeight: 28,
                                          ),
                                          padding: EdgeInsets.zero,
                                          tooltip: 'Clear temporary avatar',
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const AvatarSetupPage(),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: theme.colorScheme.onSurface,
                                            size: 16,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                            minHeight: 28,
                                          ),
                                          padding: EdgeInsets.zero,
                                          tooltip: 'Edit avatar',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            // Scanning overlay when loading
                            if (_loading) _buildScanningOverlay(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _temporaryAvatarImage != null
                            ? 'Your Picked Image'
                            : provider.hasAvatar
                                ? 'Your Avatar'
                                : 'Avatar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _temporaryAvatarImage != null
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center Plus Icon
            Expanded(
              flex: 1,
              child: Center(
                child: AnimatedBuilder(
                  animation: _loading
                      ? _plusController
                      : Listenable.merge([_plusController, _pulseController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _loading ? _pulseAnimation.value : 1.0,
                      child: Transform.rotate(
                        angle: _loading ? _plusRotation.value * 3.14159 : 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _loading
                                ? null
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ),
                            color: _loading
                                ? theme.colorScheme.primary.withOpacity(0.8)
                                : null,
                            boxShadow: _loading
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: theme.colorScheme.surface
                                          .withOpacity(0.8),
                                      blurRadius: 6,
                                      spreadRadius: -2,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                          ),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: theme.colorScheme.onPrimary,
                            weight: 600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Product Image Selection
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Product Image',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Consumer<AuthController>(
                            builder: (context, authController, _) {
                              bool hasCredits = authController.chatCredits > 0;
                              bool isPro = authController.isPro;

                              return GestureDetector(
                                onTap: hasCredits
                                    ? _selectProductImage
                                    : () => _showNoCreditsDialog(isPro),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color: theme.colorScheme.surface,
                                  ),
                                  child: _selectedProductImage == null
                                      ? hasCredits
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  size: 48,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Select Product',
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tap to choose from camera or gallery',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '0',
                                                  style: theme
                                                      .textTheme.displayLarge
                                                      ?.copyWith(
                                                    color:
                                                        theme.colorScheme.error,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Try Ons Left',
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (!isPro) ...[
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Upgrade to Pro for getting more try ons',
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme
                                                          .colorScheme.onSurface
                                                          .withOpacity(0.7),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  FilledButton(
                                                    onPressed: () {
                                                      final authController =
                                                          context.read<
                                                              AuthController>();
                                                      authController
                                                          .presentPaywallIfNeeded();
                                                    },
                                                    style:
                                                        FilledButton.styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Upgrade'),
                                                  ),
                                                ],
                                              ],
                                            )
                                      : Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                                child: Image.file(
                                                  _selectedProductImage!,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: AnimatedOpacity(
                                                opacity: _loading ? 0.0 : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme
                                                        .primaryContainer
                                                        .withValues(alpha: 0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: _loading
                                                        ? null
                                                        : _clearSelection,
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                      size: 20,
                                                    ),
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 36,
                                                      minHeight: 36,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                          // Scanning overlay when loading
                          if (_loading) _buildScanningOverlay(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Try On Button - Full width at bottom when product is selected
            if (_selectedProductImage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _loading ? null : _tryOn,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        _loading ? theme.colorScheme.outline : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _loading ? Icons.hourglass_empty : Icons.auto_awesome,
                      ),
                      const SizedBox(width: 8),
                      Text(_loading ? 'Processing...' : 'Try On'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScannerGridPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  ScannerGridPainter(this.progress, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double i = 0; i <= size.width; i += gridSize) {
      final opacity = (1 - (i / size.width - progress).abs()).clamp(0.0, 1.0);
      paint.color = primaryColor.withOpacity(opacity * 0.3);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += gridSize) {
      final opacity = (1 - (i / size.height - progress).abs()).clamp(0.0, 1.0);
      paint.color = primaryColor.withOpacity(opacity * 0.3);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
