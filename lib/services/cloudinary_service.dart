import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Parse từ CLOUDINARY_URL environment variable
  static const String _cloudinaryUrl = 'cloudinary://761183948665527:cbVe7DoK87qIA4lK_NlbJGqQNXM@dr09dvzai';
  
  static String get _cloudName {
    final uri = Uri.parse(_cloudinaryUrl);
    return uri.host;
  }
  
  static String get _apiKey {
    final uri = Uri.parse(_cloudinaryUrl);
    return uri.userInfo.split(':')[0];
  }
  
  static String get _apiSecret {
    final uri = Uri.parse(_cloudinaryUrl);
    return uri.userInfo.split(':')[1];
  }
  
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// Upload ảnh lên Cloudinary
  static Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Tạo signature cho bảo mật
      final signature = _generateSignature(timestamp, folder);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$_cloudName/image/upload'),
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
          if (folder != null) 'folder': folder,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['secure_url']; // URL HTTPS
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Upload với transformations (resize, crop, etc.)
  static Future<String?> uploadImageWithTransform(
    File imageFile, {
    String? folder,
    int? width,
    int? height,
    String crop = 'fill',
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      String transformation = '';
      if (width != null && height != null) {
        transformation = 'w_$width,h_$height,c_$crop';
      }
      
      final signature = _generateSignature(timestamp, folder, transformation);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$_cloudName/image/upload'),
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
          if (folder != null) 'folder': folder,
          if (transformation.isNotEmpty) 'transformation': transformation,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tạo signature bảo mật
  static String _generateSignature(String timestamp, String? folder, [String? transformation]) {
    final params = <String>[];
    if (folder != null) params.add('folder=$folder');
    if (transformation != null) params.add('transformation=$transformation');
    params.add('timestamp=$timestamp');
    
    final paramString = params.join('&') + _apiSecret;
    final bytes = utf8.encode(paramString);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// Tạo URL với transformation
  static String getTransformedUrl(String publicId, {int? width, int? height, String crop = 'fill'}) {
    String transformation = '';
    if (width != null && height != null) {
      transformation = 'w_$width,h_$height,c_$crop/';
    }
    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformation$publicId';
  }
}

