import 'dart:convert';
import 'package:flutter/material.dart';

class ImageUtils {
  static ImageProvider<Object> imageFromBase64String(String base64String) {
    try {
      if (base64String.isEmpty) {
        return AssetImage('assets/images/placeholder.png');
      }

      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      if (cleanBase64.isEmpty) {
        return AssetImage('assets/images/placeholder.png');
      }

      try {
        final bytes = base64.decode(cleanBase64);
        
        if (bytes.isEmpty) {
          return AssetImage('assets/images/placeholder.png');
        }
        
        if (bytes.length < 8) {
          return AssetImage('assets/images/placeholder.png');
        }
        
        return MemoryImage(bytes);
      } catch (decodeError) {
        return AssetImage('assets/images/placeholder.png');
      }
    } catch (e) {
      return AssetImage('assets/images/placeholder.png');
    }
  }

  static Image imageFromBase64StringWidget(String base64String) {
    return Image(
      image: imageFromBase64String(base64String),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/placeholder.png',
          fit: BoxFit.cover,
        );
      },
    );
  }

  static bool isValidBase64(String base64String) {
    try {
      if (base64String.isEmpty) {
        return false;
      }

      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      if (cleanBase64.isEmpty) {
        return false;
      }

      final bytes = base64.decode(cleanBase64);
      return bytes.isNotEmpty && bytes.length > 8;
    } catch (e) {
      return false;
    }
  }
}