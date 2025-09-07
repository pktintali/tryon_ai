import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import '../../controllers/saved_images_controller.dart';
import '../../controllers/auth_controller.dart';

class TryOnResultPage extends StatefulWidget {
  final File resultImage;
  final String? productUrl;
  final String?
      ecomPlatform; // e.g., "amazon", "flipkart", "image_share", "TryOn_Home_"

  const TryOnResultPage({
    super.key,
    required this.resultImage,
    this.productUrl,
    this.ecomPlatform,
  });

  @override
  State<TryOnResultPage> createState() => _TryOnResultPageState();
}

class _TryOnResultPageState extends State<TryOnResultPage> {
  bool _isSaving = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    // Reduce credit when try-on result is successfully displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      authController.decrementCredit(context);
    });
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Request storage permission
      if (!await Gal.hasAccess()) {
        final hasPermission = await Gal.requestAccess();
        if (!hasPermission) {
          _showSnackBar('Photo library access is required to save images');
          return;
        }
      }

      // Save to gallery using gal package
      await Gal.putImage(widget.resultImage.path);

      _showSnackBar('Image saved to gallery successfully!');

      // Also save to app's controller for instant reflection in mytryons page
      if (mounted) {
        final savedImagesController =
            Provider.of<SavedImagesController>(context, listen: false);
        await savedImagesController.addSavedImage(
          widget.resultImage.path,
          productUrl: widget.productUrl,
        );
      }
    } catch (e) {
      _showSnackBar('Error saving image: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Try-on Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PhotoView(
                      imageProvider: FileImage(widget.resultImage),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.resultImage.path,
                      ),
                      backgroundDecoration: BoxDecoration(
                        // color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // AI Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.05),
                  // color: Theme.of(context)
                  //     .colorScheme
                  //     .surfaceVariant
                  //     .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI-generated preview may not be perfect, images may vary.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveToGallery,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isSaving ? 'Saving...' : 'Save'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Share.shareXFiles([
                        XFile(widget.resultImage.path),
                      ], text: 'Tryom AI preview');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
