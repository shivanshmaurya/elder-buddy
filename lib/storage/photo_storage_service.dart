import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  static const String _photosFolder = 'contact_photos';

  /// Get the photos directory, creating it if it doesn't exist
  static Future<Directory> _getPhotosDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/$_photosFolder');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    return photosDir;
  }

  /// Save contact photo bytes to a file and return the file path
  static Future<String?> savePhoto(
      Uint8List photoBytes, String phoneNumber) async {
    try {
      final photosDir = await _getPhotosDir();

      // Create a unique filename based on phone number
      final sanitizedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final fileName = 'contact_$sanitizedPhone.jpg';
      final filePath = '${photosDir.path}/$fileName';

      // Write the bytes to file
      final file = File(filePath);
      await file.writeAsBytes(photoBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Delete a contact photo
  static Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  /// Check if a photo file exists
  static Future<bool> photoExists(String? photoPath) async {
    if (photoPath == null) return false;

    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
