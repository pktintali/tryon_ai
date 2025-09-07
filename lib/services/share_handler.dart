import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../controllers/auth_controller.dart';
import '../routes/routes_name.dart';

/// Handles Android intents and iOS share extension events by showing preview screen.
class ShareHandler {
  StreamSubscription? _mediaSub;
  StreamSubscription? _textSub;
  final _receiver = ReceiveSharingIntent.instance;
  final GlobalKey<NavigatorState> navigatorKey;

  ShareHandler(this.navigatorKey);

  void startListening() {
    // Media stream
    _mediaSub = _receiver.getMediaStream().listen(
      (List<SharedMediaFile> value) async {
        if (value.isEmpty) return;

        for (final m in value) {
          try {
            await _handleSharedMedia(m);
          } catch (e) {
            if (kDebugMode) {
              print('Error handling shared media: $e');
            }
          }
        }
      },
      onError: (err) {
        if (kDebugMode) {
          print('getMediaStream error: $err');
        }
      },
    );
  }

  Future<void> handleInitialShare() async {
    try {
      // Add a delay to ensure the app is fully initialized
      await Future.delayed(const Duration(milliseconds: 1000));

      final media = await _receiver.getInitialMedia();
      if (media.isEmpty) return;

      for (final m in media) {
        await _handleSharedMedia(m);
      }
      await _receiver.reset();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling initial share: $e');
      }
      // Try to reset the receiver even if there was an error
      try {
        await _receiver.reset();
      } catch (resetError) {
        if (kDebugMode) {
          print('Error resetting receiver: $resetError');
        }
      }
    }
  }

  void dispose() {
    _mediaSub?.cancel();
    _textSub?.cancel();
  }

  Future<void> _handleSharedMedia(SharedMediaFile m) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      // If context is not available, wait and retry
      await Future.delayed(const Duration(milliseconds: 500));
      final retryContext = navigatorKey.currentContext;
      if (retryContext == null) {
        if (kDebugMode) {
          print('Navigator context not available for shared media handling');
        }
        return;
      }
    }

    final activeContext = navigatorKey.currentContext!;

    File? imageFile;
    String? textOrUrl;
    String? title;

    if (m.type.toString().toLowerCase().contains('text') ||
        (m.mimeType ?? '').startsWith('text/')) {
      if (m.path.isNotEmpty) {
        textOrUrl = m.path;
        title = _extractTitleFromUrl(m.path);
      }
    } else if (m.path.startsWith('http')) {
      // URL shared as text
      textOrUrl = m.path;
      title = _extractTitleFromUrl(m.path);
    } else if ((m.mimeType ?? '').startsWith('image/') && m.path.isNotEmpty) {
      // Image file
      imageFile = File(m.path);
      title = 'Shared Image';
    }

    // Navigate to preview screen only if we have valid content
    if (imageFile != null || textOrUrl != null) {
      // Add a small delay to ensure the app is fully loaded
      await Future.delayed(const Duration(milliseconds: 300));

      if (navigatorKey.currentContext != null) {
        // Check authentication status before allowing access to shared content
        final authController =
            Provider.of<AuthController>(activeContext, listen: false);

        if (authController.getCurrentUser == null) {
          // User is not authenticated, show a dialog
          showDialog(
            context: activeContext,
            builder: (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text(
                'You need to sign in to use virtual try-on features with shared content.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        // Use GoRouter for proper navigation state management
        GoRouter.of(activeContext).pushNamed(
          RoutesName.sharedItemPreview,
          extra: {
            'imageFile': imageFile,
            'textOrUrl': textOrUrl,
            'title': title,
          },
        );
      }
    }
  }

  String? _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'Shared Link';
    }
  }
}
