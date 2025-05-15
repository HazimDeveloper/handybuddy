// firebase/auth_methods.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// AuthMethods provides a set of static methods to handle all authentication operations
/// This class serves as a wrapper around Firebase Authentication and Firestore
/// to provide a unified interface for authentication operations.
class AuthMethods {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get the current user
  static User? get currentUser => _auth.currentUser;

  /// Check if a user is logged in
  static bool get isUserLoggedIn => currentUser != null;

  /// Register a new user
  /// 
  /// Creates a new account with Firebase Authentication and adds user data to Firestore
  /// [email] - User email address
  /// [password] - User password
  /// [userData] - Map containing additional user data to be stored in Firestore
  /// [profileImage] - Optional profile image file to be uploaded to Firebase Storage
  /// 
  /// Returns a Future that resolves to the User ID if successful
  static Future<String> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
    File? profileImage,
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw 'Failed to create user';
      }
      
      final String userId = userCredential.user!.uid;
      
      // If profile image is provided, upload it to Firebase Storage
      String? profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(userId, profileImage);
      }
      
      // Add profile image URL to user data if it exists
      if (profileImageUrl != null) {
        userData['profileImageUrl'] = profileImageUrl;
      }
      
      // Add creation timestamp to user data
      userData['createdAt'] = Timestamp.now();
      userData['email'] = email;
      
      // Store user data in Firestore
      await _firestore.collection('users').doc(userId).set(userData);
      
      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during registration: ${e.toString()}';
    }
  }

  /// Sign in an existing user
  /// 
  /// Authenticates a user with email and password
  /// [email] - User email address
  /// [password] - User password
  /// [isProvider] - If true, checks if the user is registered as a service provider
  /// 
  /// Returns a Future that resolves to the User ID if successful
  static Future<String> signIn({
    required String email,
    required String password,
    required bool isProvider,
  }) async {
    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw 'Failed to sign in';
      }
      
      final String userId = userCredential.user!.uid;
      
      // Check if user exists in Firestore and has the correct role
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        await _auth.signOut();
        throw 'User account not found';
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final bool userIsProvider = userData['isProvider'] ?? false;
      
      // Validate user role based on login type
      if (isProvider && !userIsProvider) {
        await _auth.signOut();
        throw 'This account is not registered as a service provider';
      } else if (!isProvider && userIsProvider) {
        await _auth.signOut();
        throw 'This account is registered as a service provider. Please use the provider login';
      }
      
      // Update last login timestamp
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': Timestamp.now(),
      });
      
      return userId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during login: ${e.toString()}';
    }
  }

  /// Sign out the current user
  /// 
  /// Returns a Future that completes when the user is signed out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  /// Reset password for a given email
  /// 
  /// Sends a password reset email to the user
  /// [email] - User email address
  /// 
  /// Returns a Future that completes when the reset email is sent
  static Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: ${e.toString()}';
    }
  }

  /// Change password for the current user
  /// 
  /// Updates the password for the authenticated user
  /// [currentPassword] - Current password for verification
  /// [newPassword] - New password to set
  /// 
  /// Returns a Future that completes when the password is changed
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentUser == null) {
        throw 'No user is currently logged in';
      }
      
      final email = currentUser!.email;
      if (email == null) {
        throw 'User email is not available';
      }
      
      // Re-authenticate user with current password
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // Update the password
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to change password: ${e.toString()}';
    }
  }

  /// Update user profile information
  /// 
  /// Updates specific fields in the user document in Firestore
  /// [userId] - The ID of the user to update
  /// [data] - Map containing fields and values to update
  /// 
  /// Returns a Future that completes when the profile is updated
  static Future<void> updateUserProfile({
    String? userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final String uid = userId ?? currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        throw 'No user is currently logged in';
      }
      
      // Add update timestamp
      data['updatedAt'] = Timestamp.now();
      
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile: ${e.toString()}';
    }
  }

  /// Update user profile image
  /// 
  /// Uploads a new profile image to Firebase Storage and updates the user profile
  /// [userId] - The ID of the user to update
  /// [imageFile] - The new profile image file
  /// 
  /// Returns a Future that resolves to the URL of the uploaded image
  static Future<String> updateProfileImage({
    String? userId,
    required File imageFile,
  }) async {
    try {
      final String uid = userId ?? currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        throw 'No user is currently logged in';
      }
      
      // Upload new profile image
      final String imageUrl = await _uploadProfileImage(uid, imageFile);
      
      // Update user document with new image URL
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      
      return imageUrl;
    } catch (e) {
      throw 'Failed to update profile image: ${e.toString()}';
    }
  }

  /// Delete the current user account
  /// 
  /// Removes the user from Firebase Authentication and Firestore
  /// [password] - Current password for verification
  /// 
  /// Returns a Future that completes when the user is deleted
  static Future<void> deleteAccount({required String password}) async {
    try {
      if (currentUser == null) {
        throw 'No user is currently logged in';
      }
      
      final email = currentUser!.email;
      if (email == null) {
        throw 'User email is not available';
      }
      
      // Re-authenticate user
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      final String userId = currentUser!.uid;
      
      // Get user data to check for profile image
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      
      // Delete profile image from storage if exists
      if (userData.containsKey('profileImageUrl') && userData['profileImageUrl'] != null) {
        try {
          final String imagePath = userData['profileImageUrl'];
          final Reference ref = _storage.refFromURL(imagePath);
          await ref.delete();
        } catch (e) {
          // Continue with account deletion even if image deletion fails
          print('Failed to delete profile image: ${e.toString()}');
        }
      }
      
      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete user from Firebase Authentication
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account: ${e.toString()}';
    }
  }

  /// Get user data from Firestore
  /// 
  /// Retrieves the user document from Firestore
  /// [userId] - The ID of the user to fetch, defaults to current user
  /// 
  /// Returns a Future that resolves to a Map containing user data
  static Future<Map<String, dynamic>> getUserData({String? userId}) async {
    try {
      final String uid = userId ?? currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        throw 'No user is currently logged in';
      }
      
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        throw 'User data not found';
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Convert Timestamp objects to DateTime for easier handling in the UI
      if (userData.containsKey('createdAt') && userData['createdAt'] is Timestamp) {
        userData['createdAt'] = (userData['createdAt'] as Timestamp).toDate();
      }
      
      if (userData.containsKey('updatedAt') && userData['updatedAt'] is Timestamp) {
        userData['updatedAt'] = (userData['updatedAt'] as Timestamp).toDate();
      }
      
      if (userData.containsKey('lastLogin') && userData['lastLogin'] is Timestamp) {
        userData['lastLogin'] = (userData['lastLogin'] as Timestamp).toDate();
      }
      
      return userData;
    } catch (e) {
      throw 'Failed to get user data: ${e.toString()}';
    }
  }

  /// Check if a user exists with the given email
  /// 
  /// [email] - Email address to check
  /// 
  /// Returns a Future that resolves to true if a user exists with the email
  static Future<bool> checkUserExists({required String email}) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return result.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check if user exists: ${e.toString()}';
    }
  }

  /// Upload a profile image to Firebase Storage
  /// 
  /// Helper method to upload profile image
  /// [userId] - The ID of the user
  /// [imageFile] - The profile image file
  /// 
  /// Returns a Future that resolves to the URL of the uploaded image
  static Future<String> _uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a reference to the file location in Firebase Storage
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      
      // Upload the file
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload profile image: ${e.toString()}';
    }
  }

  /// Handle Firebase Auth exceptions
  /// 
  /// Helper method to convert Firebase Auth exceptions to user-friendly error messages
  /// [e] - The FirebaseAuthException
  /// 
  /// Returns a user-friendly error message
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}