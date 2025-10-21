import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({required String pathPrefix}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) throw Exception('No image selected');

    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref('$pathPrefix/$fileName.jpg');

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final task = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await task.ref.getDownloadURL();
    } else {
      final task = await ref.putFile(File(file.path), SettableMetadata(contentType: 'image/jpeg'));
      return await task.ref.getDownloadURL();
    }
  }
}
