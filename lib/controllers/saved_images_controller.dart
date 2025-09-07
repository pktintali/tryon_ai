import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedImagesController extends ChangeNotifier {
  List<File> _savedImages = [];
  bool _isLoading = false;

  // Map to store hash-to-URL mappings
  Map<String, String> _hashToUrlMap = {};

  List<File> get savedImages => _savedImages;
  bool get isLoading => _isLoading;

  SavedImagesController() {
    loadSavedImages();
    _loadHashToUrlMappings();
  }

  Future<void> loadSavedImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final myTryonsDir = Directory('${appDir.path}/mytryons');

      if (await myTryonsDir.exists()) {
        final files = await myTryonsDir
            .list()
            .where((entity) {
              return entity is File &&
                  (entity.path.toLowerCase().endsWith('.jpg') ||
                      entity.path.toLowerCase().endsWith('.jpeg') ||
                      entity.path.toLowerCase().endsWith('.png'));
            })
            .cast<File>()
            .toList();

        // Sort by modification date (newest first)
        files.sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

        _savedImages = files;
      } else {
        _savedImages = [];
      }
    } catch (e) {
      print('Error loading saved images: $e');
      _savedImages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSavedImage(String imagePath, {String? productUrl}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final myTryonsDir = Directory('${appDir.path}/mytryons');

      if (!await myTryonsDir.exists()) {
        await myTryonsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String fileName = 'tryon_$timestamp';

      // If productUrl is provided, create a short hash instead of encoding the full URL
      if (productUrl != null && productUrl.isNotEmpty) {
        // Use hashCode to create a short, consistent identifier for the URL
        final urlHash = productUrl.hashCode.abs().toString();
        fileName = 'tryon_${timestamp}_${urlHash}';

        // Store the hash-to-URL mapping for later retrieval
        _hashToUrlMap[urlHash] = productUrl;
        await _saveHashToUrlMappings();
      }

      fileName += '.jpg';
      final savedFile = File('${myTryonsDir.path}/$fileName');

      await File(imagePath).copy(savedFile.path);

      // Add to the beginning of the list (newest first)
      _savedImages.insert(0, savedFile);
      notifyListeners();
    } catch (e) {
      print('Error saving to app directory: $e');
    }
  }

  Future<void> deleteImage(File file) async {
    try {
      await file.delete();
      _savedImages.remove(file);
      notifyListeners();
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  void refresh() {
    loadSavedImages();
  }

  // Helper method to extract product URL from filename
  String? getProductUrl(File imageFile) {
    try {
      final fileName = imageFile.path.split('/').last;
      // New format: tryon_timestamp_hash.jpg
      if (fileName.startsWith('tryon_') &&
          fileName.contains('_') &&
          fileName.length > 20) {
        final parts = fileName.split('_');
        if (parts.length >= 3) {
          final hashPart = parts[2].split('.jpg')[0]; // Remove file extension
          return _hashToUrlMap[hashPart];
        }
      }
      // Legacy format: tryon_timestamp_url_encodedUrl.jpg (for backward compatibility)
      else if (fileName.contains('_url_')) {
        final urlPart = fileName.split('_url_')[1];
        final encodedUrl = urlPart.split('.jpg')[0]; // Remove file extension
        final decodedUrl = utf8.decode(base64Url.decode(encodedUrl));
        return decodedUrl;
      }
    } catch (e) {
      print('Error extracting URL from filename: $e');
    }
    return null;
  }

  // Helper method to check if an image has a product URL
  bool hasProductUrl(File imageFile) {
    return getProductUrl(imageFile) != null;
  }

  // Save hash-to-URL mappings to persistent storage
  Future<void> _saveHashToUrlMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mappingsJson = jsonEncode(_hashToUrlMap);
      await prefs.setString('hash_to_url_mappings', mappingsJson);
    } catch (e) {
      print('Error saving hash-to-URL mappings: $e');
    }
  }

  // Load hash-to-URL mappings from persistent storage
  Future<void> _loadHashToUrlMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mappingsJson = prefs.getString('hash_to_url_mappings');
      if (mappingsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(mappingsJson);
        _hashToUrlMap = decoded.cast<String, String>();
      }
    } catch (e) {
      print('Error loading hash-to-URL mappings: $e');
      _hashToUrlMap = {};
    }
  }
}
