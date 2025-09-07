import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/saved_images_controller.dart';

class MyTryOnsPage extends StatelessWidget {
  const MyTryOnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedImagesController>(
      builder: (context, controller, child) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Try-Ons'),
            centerTitle: true,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.savedImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No try-ons saved yet',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try on some outfits and save them to see here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: controller.savedImages.length,
                        itemBuilder: (context, index) {
                          final imageFile = controller.savedImages[index];
                          return _ImageCard(
                            imageFile: imageFile,
                            controller: controller,
                            onDelete: () =>
                                _deleteImage(context, controller, imageFile),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  Future<void> _deleteImage(BuildContext context,
      SavedImagesController controller, File imageFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content:
            const Text('Are you sure you want to delete this try-on image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.deleteImage(imageFile);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting image: $e')),
          );
        }
      }
    }
  }
}

class _ImageCard extends StatelessWidget {
  final File imageFile;
  final SavedImagesController controller;
  final VoidCallback onDelete;

  const _ImageCard({
    required this.imageFile,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showImageDialog(context),
        child: Column(
          children: [
            Expanded(
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    _getFormattedDate(imageFile.lastModifiedSync()),
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.hasProductUrl(imageFile))
                      IconButton(
                        onPressed: () => _openProductUrl(context),
                        icon: Icon(
                          Icons.arrow_outward,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Open product link',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      tooltip: "Delete image",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProductUrl(BuildContext context) async {
    final productUrl = controller.getProductUrl(imageFile);
    if (productUrl != null) {
      try {
        final uri = Uri.parse(productUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open product page')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening URL: $e')),
          );
        }
      }
    }
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(imageFile),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.0,
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: imageFile.path),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.error.withOpacity(0.7),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await Share.shareXFiles([
                        XFile(imageFile.path),
                      ], text: 'Try-On AI result');
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.7),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            if (controller.hasProductUrl(imageFile))
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _openProductUrl(context),
                    icon: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                    ),
                    label: const Text('Shop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      if (hours == 0) {
        final minutes = difference.inMinutes;
        return minutes == 0 ? 'Just now' : '${minutes}m ago';
      }
      return '${hours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
