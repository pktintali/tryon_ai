import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tryon_ai/controllers/app_controller.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/controllers/feedback_controller.dart';
import 'package:tryon_ai/models/user_info.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:provider/provider.dart';

extension ContextExtension on BuildContext {
  Size get _screenSize => MediaQuery.sizeOf(this);
  double get deviceWidth => _screenSize.width;
  double get deviceHeight => _screenSize.height;

  /// all values that change when rebuilds append(R) after that

  //  app controllers data
  bool get isDarkModeR =>
      select<AppController, bool>((appController) => appController.isDarkMode);

  // auth controller variables

  bool get authConIsProUserR =>
      select<AuthController, bool>((authController) => authController.isPro);
  PmUserInfo? get authConGetCurrUserR => select<AuthController, PmUserInfo?>(
      (authController) => authController.getCurrentUser);

  /// for accessing the them stuff
  ThemeData get theme => Theme.of(this);

  /// Show error alert dialog
  Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// all the controller that only reads
  AppController get appController => read<AppController>();
  AuthController get authController => read<AuthController>();
  FeedbackController get feedBackController => read<FeedbackController>();
}

/// extensions for all the box in PM
extension HiveExtension on HiveInterface {
  Box<bool> get userBox => box(userBoxName);
  Box<int> get creditBox => box(creditBoxName);
  Box<int> get timeStampBox => box(timeStampBoxName);
  Box<Map> get downloadBox => box(downloadsBoxName);
  Box<String> get deviceTokenBox => box(deviceTokenBoxName);
  Box<Map> get progressBox => box(progressBoxName);
}
