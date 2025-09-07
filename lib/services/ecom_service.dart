import 'dart:typed_data';

import 'package:dio/dio.dart';

class EcomService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// List of supported e-commerce platforms
  static const List<String> supportedPlatforms = [
    'amazon.',
    'amzn.',
    'snitch.com',
    'flipkart.com',
    'nykaafashion.com',
  ];

  /// Check if the URL is from any supported e-commerce platform
  static bool isSupportedEcomUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return supportedPlatforms.any((platform) => lowerUrl.contains(platform));
  }

  /// Get the platform name from URL for display purposes
  static String getPlatformName(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('amazon.') || lowerUrl.contains('amzn.')) {
      return 'Amazon';
    } else if (lowerUrl.contains('snitch.com')) {
      return 'Snitch';
    } else if (lowerUrl.contains('flipkart.com')) {
      return 'Flipkart';
    } else if (lowerUrl.contains('nykaafashion.com')) {
      return 'Nykaa Fashion';
    }

    return 'Unknown';
  }

  static Future<List<int>> downloadImage(String imageUrl) async {
    final resp = await _dio.get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = resp.data;
    if (data == null) throw Exception('Failed to download image');
    return Uint8List.fromList(data);
  }
}
