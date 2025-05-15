import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String providerDocumentsPath = 'provider_documents';
  static const String serviceImagesPath = 'service_images';
  static const String chatAttachmentsPath = 'chat_attachments';
  
  // Image compression quality (0-100)
  static const int compressionQuality = 85;
  
  // Maximum image size (in bytes) before compression is applied
  static const int maxImageSize = 1024 * 1024; // 1MB
  
  // Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      if (currentUserId.isEmpty) {
        return 'User not logged in';
      }
      
      // Compress image if needed
      File processedFile = await _processImageBeforeUpload(imageFile);
      
      // Create reference to file path
      String filePath = '$profileImagesPath/$currentUserId';
      Reference storageRef = _storage.ref().child(filePath);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(processedFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      return e.toString();
    }
  }
  
  // Upload provider verification documents (IC)
  Future<String> uploadProviderIC(File documentFile) async {
    try {
      if (currentUserId.isEmpty) {
        return 'User not logged in';
      }
      
      // Create reference to file path
      String filePath = '$providerDocumentsPath/$currentUserId/ic';
      Reference storageRef = _storage.ref().child(filePath);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading provider IC: $e');
      }
      return e.toString();
    }
  }
  
  // Upload provider resume/CV
  Future<String> uploadProviderResume(File resumeFile) async {
    try {
      if (currentUserId.isEmpty) {
        return 'User not logged in';
      }
      
      // Create reference to file path
      String filePath = '$providerDocumentsPath/$currentUserId/resume${path.extension(resumeFile.path)}';
      Reference storageRef = _storage.ref().child(filePath);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(resumeFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading provider resume: $e');
      }
      return e.toString();
    }
  }
  
  // Upload service image
  Future<String> uploadServiceImage(File imageFile, String serviceId) async {
    try {
      if (currentUserId.isEmpty) {
        return 'User not logged in';
      }
      
      // Compress image if needed
      File processedFile = await _processImageBeforeUpload(imageFile);
      
      // Create reference to file path
      String filePath = '$serviceImagesPath/$serviceId';
      Reference storageRef = _storage.ref().child(filePath);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(processedFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading service image: $e');
      }
      return e.toString();
    }
  }
  
  // Upload chat attachment
  Future<String> uploadChatAttachment(File file, String chatId) async {
    try {
      if (currentUserId.isEmpty) {
        return 'User not logged in';
      }
      
      // Generate unique file name
      String fileName = const Uuid().v4() + path.extension(file.path);
      
      // Process file if it's an image
      File fileToUpload = file;
      if (_isImageFile(file.path)) {
        fileToUpload = await _processImageBeforeUpload(file);
      }
      
      // Create reference to file path
      String filePath = '$chatAttachmentsPath/$chatId/$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(fileToUpload);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading chat attachment: $e');
      }
      return e.toString();
    }
  }
  
  // Pick image from gallery or camera
  Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Reduce quality a bit to save space
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }
  
  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85, // Reduce quality a bit to save space
      );
      
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple images: $e');
      }
      return [];
    }
  }
  
  // Pick document file (PDF, DOC, etc.)
  Future<File?> pickDocument() async {
    // Note: This requires additional packages like file_picker
    // Implement based on your file picker package choice
    return null;
  }
  
  // Delete a file from storage
  Future<String> deleteFile(String fileUrl) async {
    try {
      // Extract the path from the URL
      Reference reference = _storage.refFromURL(fileUrl);
      
      // Delete the file
      await reference.delete();
      
      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return e.toString();
    }
  }
  
  // Delete all files in a directory
  Future<String> deleteDirectory(String directoryPath) async {
    try {
      // List all items in the directory
      ListResult result = await _storage.ref().child(directoryPath).listAll();
      
      // Delete each item
      for (var item in result.items) {
        await item.delete();
      }
      
      // Recursively delete subdirectories
      for (var prefix in result.prefixes) {
        await deleteDirectory(prefix.fullPath);
      }
      
      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting directory: $e');
      }
      return e.toString();
    }
  }
  
  // Delete all files related to a user (for account deletion)
  Future<String> deleteUserFiles(String userId) async {
    try {
      // Delete profile image
      await deleteDirectory('$profileImagesPath/$userId');
      
      // Delete provider documents
      await deleteDirectory('$providerDocumentsPath/$userId');
      
      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user files: $e');
      }
      return e.toString();
    }
  }
  
  // Delete all files related to a service (for service deletion)
  Future<String> deleteServiceFiles(String serviceId) async {
    try {
      await deleteDirectory('$serviceImagesPath/$serviceId');
      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting service files: $e');
      }
      return e.toString();
    }
  }
  
  // Get download URL from storage path
  Future<String?> getDownloadURL(String storagePath) async {
    try {
      return await _storage.ref().child(storagePath).getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL: $e');
      }
      return null;
    }
  }
  
  // Check if a file exists in storage
  Future<bool> fileExists(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper function to process and compress images before upload
  Future<File> _processImageBeforeUpload(File imageFile) async {
    try {
      // Check file size
      int fileSize = await imageFile.length();
      
      // If file size is small, return the original file
      if (fileSize <= maxImageSize) {
        return imageFile;
      }
      
      // Create a temporary file for the compressed image
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.jpg';
      
      // Compress image
     XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
  imageFile.path,
  targetPath,
  quality: compressionQuality,
  format: CompressFormat.jpeg,
);
File compressedFile = compressedXFile != null 
    ? File(compressedXFile.path) 
    : imageFile;
      
      return compressedFile ?? imageFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing image: $e');
      }
      return imageFile; // Return original if compression fails
    }
  }
  
  // Helper function to check if a file is an image
  bool _isImageFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.gif';
  }
  
  // Upload multiple files and return a list of URLs
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String basePath,
  }) async {
    try {
      List<String> uploadedUrls = [];
      
      for (File file in files) {
        String fileName = const Uuid().v4() + path.extension(file.path);
        String filePath = '$basePath/$fileName';
        
        // Process file if it's an image
        File fileToUpload = file;
        if (_isImageFile(file.path)) {
          fileToUpload = await _processImageBeforeUpload(file);
        }
        
        // Upload file
        Reference storageRef = _storage.ref().child(filePath);
        UploadTask uploadTask = storageRef.putFile(fileToUpload);
        TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading multiple files: $e');
      }
      return [];
    }
  }
  
  // Upload before and after images for completed services
  Future<Map<String, List<String>>> uploadBeforeAfterImages({
    required String bookingId,
    required List<File> beforeImages,
    required List<File> afterImages,
  }) async {
    try {
      // Upload "before" images
      List<String> beforeUrls = await uploadMultipleFiles(
        files: beforeImages,
        basePath: 'service_evidence/$bookingId/before',
      );
      
      // Upload "after" images
      List<String> afterUrls = await uploadMultipleFiles(
        files: afterImages,
        basePath: 'service_evidence/$bookingId/after',
      );
      
      return {
        'before': beforeUrls,
        'after': afterUrls,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading before/after images: $e');
      }
      return {
        'before': [],
        'after': [],
      };
    }
  }
  
  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String fileUrl) async {
    try {
      Reference reference = _storage.refFromURL(fileUrl);
      FullMetadata metadata = await reference.getMetadata();
      
      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file metadata: $e');
      }
      return null;
    }
  }
}