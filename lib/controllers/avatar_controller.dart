import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/avatar.dart';

/// Manages user's avatar file persistence and availability.
class AvatarProvider extends ChangeNotifier {
  Avatar? _avatar;
  Avatar? get avatar => _avatar;
  bool get hasAvatar => _avatar != null;

  static const _avatarPathKey = 'avatar_image_path';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_avatarPathKey);
    if (path != null && File(path).existsSync()) {
      _avatar = Avatar(imageFile: File(path));
      notifyListeners();
    }
  }

  Future<void> setAvatar(File file) async {
    // Persist a copy into app documents
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}${_ext(file.path)}',
    );
    await dest.writeAsBytes(await file.readAsBytes());
    _avatar = Avatar(imageFile: dest);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPathKey, dest.path);
    notifyListeners();
  }

  Future<void> clearAvatar() async {
    _avatar = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarPathKey);
    notifyListeners();
  }

  String _ext(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot);
  }
}
