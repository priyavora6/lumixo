import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload photo
  Future<String?> uploadPhoto(File file, String userId) async {
    try {
      final String fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference ref = _storage
          .ref()
          .child(AppConstants.storageUploads)
          .child(fileName);

      final UploadTask task = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await task;
      final String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Upload Photo Error: $e');
      return null;
    }
  }

  // Upload result photo
  Future<String?> uploadResult(File file, String userId) async {
    try {
      final String fileName =
          'result_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference ref = _storage
          .ref()
          .child(AppConstants.storageResults)
          .child(fileName);

      final UploadTask task = ref.putFile(file);
      final TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Upload Result Error: $e');
      return null;
    }
  }

  // Delete photo by URL
  Future<void> deletePhoto(String url) async {
    try {
      final Reference ref =
      _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Delete Photo Error: $e');
    }
  }
}
