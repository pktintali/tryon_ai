import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Custom exception for Gemini service that provides clean error messages
class GeminiServiceException implements Exception {
  final String message;
  
  const GeminiServiceException(this.message);
  
  @override
  String toString() => message; // Return just the message without "Exception:" prefix
}

class GeminiService {
  final Dio _dio;
  final String apiKey;
  final String model;

  GeminiService({Dio? dio, String? apiKey, String? model})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
              ),
            ),
        apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
        model = model ?? 'gemini-2.5-flash-image-preview';

  bool get isConfigured => apiKey.isNotEmpty;

  Future<File> tryOn({
    required File avatarImage,
    File? productImage,
    String? productTextOrUrl,
  }) async {
    if (!isConfigured) {
      throw GeminiServiceException(
        'TryOn AI service is not properly configured. Please contact support if this issue persists.',
      );
    }

    // Prepare images (compress to ~1024px max dimension)
    final avatarBytes = await _encodeImage(await avatarImage.readAsBytes());
    // Build request parts: prompt text first, then labeled images as inline_data
    final List<Map<String, dynamic>> parts = [];

    final promptBuffer = StringBuffer(
      "Create a realistic try-on preview of the person in the first image wearing the product from the second image. Maintain the consistency of the person and product image. If image is not suitable or clear for tryon generation, respond with a polite message indicating the issue. Do not ask follow up questions or clarifications.",
    );

    if ((productTextOrUrl ?? '').trim().isNotEmpty) {
      promptBuffer.write(" Product context: ${productTextOrUrl!.trim()}.");
    }

    parts.add({'text': promptBuffer.toString()});
    parts.add({'text': 'First Image:'});
    parts.add({
      'inline_data': {
        'mime_type': _getMimeType(avatarBytes),
        'data': base64Encode(avatarBytes),
      },
    });

    if (productImage != null) {
      final productBytes = await _encodeImage(await productImage.readAsBytes());
      parts.add({'text': 'Second Image'});
      parts.add({
        'inline_data': {
          'mime_type': _getMimeType(productBytes),
          'data': base64Encode(productBytes),
        },
      });
    }

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
    final payload = {
      'contents': [
        {'parts': parts},
      ],
    };

    final options = Options(
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
    );

    // Basic retry with up to 2 additional attempts on network/server errors
    Response? resp;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        print("Calling Gemini=====>>>>>>>");
        resp = await _dio.post(url, data: payload, options: options);
        break;
      } on DioException {
        if (attempt == 2) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      } catch (e) {
        if (attempt == 2) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }

    final data = resp!.data as Map<String, dynamic>;

    // Attempt to extract an image from response
    final candidates = (data['candidates'] as List?) ?? const [];
    if (candidates.isEmpty) {
      final fb = data['promptFeedback'] ?? data['prompt_feedback'];
      throw GeminiServiceException(
        'The AI was unable to process your images. Please ensure both your photo and the product image are clear and well-lit.${fb != null ? ' Additional info: $fb' : ''}',
      );
    }

    String? b64;
    String? geminiTextResponse;
    for (final cand in candidates.cast<Map<String, dynamic>>()) {
      final content = cand['content'] as Map<String, dynamic>?;
      final partsResp =
          (content?['parts'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
      for (final p in partsResp) {
        // First, check for text responses (Gemini's explanations)
        final text = p['text'] as String?;
        if (text != null && text.trim().isNotEmpty) {
          geminiTextResponse = text.trim();
          // Check if it's a data URI in text
          if (text.contains('data:image/')) {
            final idx = text.indexOf('base64,');
            if (idx != -1) {
              final maybe = text.substring(idx + 'base64,'.length).trim();
              if (maybe.isNotEmpty) {
                b64 = maybe;
                break;
              }
            }
          }
        }
        
        // inline_data (snake_case)
        final inlineSnake = p['inline_data'] as Map<String, dynamic>?;
        if (inlineSnake != null &&
            inlineSnake['data'] is String &&
            (inlineSnake['data'] as String).isNotEmpty) {
          b64 = inlineSnake['data'] as String;
          break;
        }
        // inlineData (camelCase) – seen in some variants
        final inlineCamel = p['inlineData'] as Map<String, dynamic>?;
        if (inlineCamel != null &&
            inlineCamel['data'] is String &&
            (inlineCamel['data'] as String).isNotEmpty) {
          b64 = inlineCamel['data'] as String;
          break;
        }
      }
      if (b64 != null) break;
    }

    if (b64 == null || b64.isEmpty) {
      // If Gemini provided a text explanation, use it; otherwise use generic message
      String errorMessage = geminiTextResponse ?? 
        'The AI could not generate a try-on image. This may happen if the images are not suitable for virtual try-on. Please try with clearer photos showing your full body and a clear product image.';
      
      throw GeminiServiceException(errorMessage);
    }

    final bytes = base64Decode(b64);
    final dir = await getTemporaryDirectory();
    final out = File(
      '${dir.path}/tryon_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(bytes);
    return out;
  }

  Future<List<int>> _encodeImage(List<int> input) async {
    final decoded = img.decodeImage(Uint8List.fromList(input));
    if (decoded == null) return input;

    // Increased max dimension for better AI processing
    const maxDim = 1536;
    img.Image resized = decoded;
    if (decoded.width > maxDim || decoded.height > maxDim) {
      resized = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? maxDim : null,
        height: decoded.height >= decoded.width ? maxDim : null,
      );
    }

    // Check if the original image has transparency
    bool hasTransparency = decoded.hasAlpha;

    // If image has transparency, keep as PNG to preserve it
    if (hasTransparency) {
      return img.encodePng(resized);
    }

    // Use higher quality JPEG for better AI processing (was 85, now 95)
    return img.encodeJpg(resized, quality: 95);
  }

  String _getMimeType(List<int> imageBytes) {
    // Check the file signature (magic bytes) to determine format
    if (imageBytes.length >= 8) {
      // PNG signature: 89 50 4E 47 0D 0A 1A 0A
      if (imageBytes[0] == 0x89 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E &&
          imageBytes[3] == 0x47) {
        return 'image/png';
      }
      // JPEG signature: FF D8 FF
      if (imageBytes[0] == 0xFF &&
          imageBytes[1] == 0xD8 &&
          imageBytes[2] == 0xFF) {
        return 'image/jpeg';
      }
    }
    // Default to JPEG if we can't determine
    return 'image/jpeg';
  }
}
