import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/avatar_controller.dart';
import '../../widgets/avatar_selection_widget.dart';

class AvatarSetupPage extends StatefulWidget {
  const AvatarSetupPage({super.key});

  @override
  State<AvatarSetupPage> createState() => _AvatarSetupPageState();
}

class _AvatarSetupPageState extends State<AvatarSetupPage> {
  final _picker = ImagePicker();
  bool _saving = false;

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
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();
    final hasAvatar = avatarProvider.hasAvatar;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasAvatar ? 'Update your avatar' : 'Set up your avatar'),
      ),
      body: AvatarSelectionWidget(
        isFromSettings: true,
        isSaving: _saving,
        onImagePick: _pick,
        existingAvatarFile: hasAvatar ? avatarProvider.avatar!.imageFile : null,
      ),
    );
  }
}
