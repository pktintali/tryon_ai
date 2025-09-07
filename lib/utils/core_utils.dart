import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/widgets/conditional_widget.dart';
import 'package:provider/provider.dart';

class CoreUtils {
  const CoreUtils._();
  static void showSackBar(
    BuildContext context, {
    required String content,
    SnackBarAction? snackBarAction,
    Duration? snackBarTime,
    bool? showCloseIcon,
    bool cannotClose = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          dismissDirection: cannotClose ? DismissDirection.none : null,
          action: snackBarAction,
          showCloseIcon: showCloseIcon,
          duration: snackBarTime ?? const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Text(
            content,
          ),
        ),
      );
  }

  static Future<bool> showCreditLimitExceedModal(
      BuildContext context, bool isProUser) async {
    bool isPro = false;
    await showModalBottomSheet(
      useSafeArea: true,
      backgroundColor: context.theme.cardColor,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      appLogo,
                      height: context.deviceHeight * .20,
                      width: context.deviceHeight * .20,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    !isProUser
                        ? "Sorry, we had reach you chat limit \n either buy pro plan or wait till tomorrow!"
                        : "Sorry, Your chat credit is exceed",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              Selector<AuthController, bool>(
                selector: (context, authController) =>
                    authController.isPaywallLoading,
                builder: (context, isPaywallLoading, _) {
                  if (isPaywallLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('GO Back'),
                        ),
                      ),
                      isProUser
                          ? const SizedBox()
                          : Expanded(
                              child: FilledButton(
                                child: const Text('Upgrade Plan'),
                                onPressed: () async {
                                  context.authController.togglePaywallLoading();
                                  await context.authController
                                      .presentPaywallIfNeeded()
                                      .then(
                                    (value) {
                                      isPro = value;
                                      if (context.mounted) {
                                        context.pop();
                                        context.authController
                                            .togglePaywallLoading();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    return isPro;
  }

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String bodyText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = true,
    String confirmText = "Confirm",
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(bodyText),
        actions: [
          ConditionalWidget(
            condition: showCancelButton,
            child: TextButton(
              onPressed: () {
                context.pop();
                if (onCancel != null) {
                  onCancel();
                }
              },
              child: const Text('Cancel'),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static MaterialColor getColorByText(String text) {
    final List<MaterialColor> nodeColors = Colors.primaries
        .where((color) =>
            color != Colors.yellow &&
            color != Colors.amber &&
            color != Colors.lime)
        .toList();
    final index = text.hashCode % nodeColors.length;
    return nodeColors[index];
  }

  //?Backup function to generate variety of colors from string
  //!Not used anywhere
  Color getColor(String heading) {
    final hash = heading.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);

    // Ensure the color is not too light
    const minBrightness = 50;
    final adjustedR = r < minBrightness ? minBrightness : r;
    final adjustedG = g < minBrightness ? minBrightness : g;
    final adjustedB = b < minBrightness ? minBrightness : b;

    return Color.fromARGB(255, adjustedR, adjustedG, adjustedB);
  }
}
