import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tryon_ai/controllers/avatar_controller.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/widgets/avatar_selection_widget.dart';

class AvatarConfigPage extends StatefulWidget {
  const AvatarConfigPage({super.key});

  @override
  State<AvatarConfigPage> createState() => _AvatarConfigPageState();
}

class _AvatarConfigPageState extends State<AvatarConfigPage> {
  final _picker = ImagePicker();
  bool _saving = false;
  bool _showContinueButton = false;

  Future<void> _pick(ImageSource source) async {
    final provider = context.read<AvatarProvider>();
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() => _saving = true);
    await provider.setAvatar(File(picked.path));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _showContinueButton = true; // Show continue button after avatar is set
    });
  }

  void _skip() {
    // Skip avatar setup and go directly to paywall
    if (context.mounted) {
      // Mark onboarding as completed in Hive
      Hive.userBox.put(isOnboardingSeenKey, true).then((_) {
        if (context.mounted) {
          _presentPaywallAndNavigateHome();
        }
      });
    }
  }

  Future<void> _continue() async {
    // Continue button clicked - show paywall and navigate to home
    if (context.mounted) {
      // Mark onboarding as completed in Hive
      await Hive.userBox.put(isOnboardingSeenKey, true);
      await _presentPaywallAndNavigateHome();
    }
  }

  Future<void> _presentPaywallAndNavigateHome() async {
    try {
      final authController = context.read<AuthController>();
      await authController.presentPaywallIfNeeded();

      if (context.mounted) {
        context.goNamed(RoutesName.home);
      }
    } catch (e) {
      // If paywall fails, still navigate to home
      if (context.mounted) {
        context.goNamed(RoutesName.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();
    final hasAvatar = avatarProvider.hasAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your avatar'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Column(
        children: [
          Expanded(
            child: AvatarSelectionWidget(
              isFromSettings: false,
              isSaving: _saving,
              onImagePick: _pick,
              onSkip: _showContinueButton
                  ? null
                  : _skip, // Hide skip if continue is shown
              existingAvatarFile:
                  hasAvatar ? avatarProvider.avatar!.imageFile : null,
            ),
          ),
          // Show continue button after avatar is selected
          if (_showContinueButton)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
