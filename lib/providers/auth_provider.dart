// providers/auth_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/auth_methods.dart';
import '../firebase/firestore_methods.dart';
import '../firebase/storage_methods.dart';
import '../models/user_model.dart';
import '../utils/toast_util.dart';

class AuthProvider with ChangeNotifier {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  final StorageMethods _storageMethods = StorageMethods();
  
  // User data
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  // Auth state
  bool _isLoggedIn = false;
  String _userType = ''; // 'provider' or 'seeker'
  
  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;
  bool get isProvider => _userType == 'provider';
  bool get isSeeker => _userType == 'seeker';
  String get userId => _auth.currentUser?.uid ?? '';
  
  // Constructor - Initialize auth state
  AuthProvider() {
    _initAuthState();
  }
  
  // Initialize authentication state
  Future<void> _initAuthState() async {
    _setLoading(true);
    
    // Check if user is logged in
    User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      // Get user data from Firestore
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          // User exists in Firestore
          _user = UserModel.fromSnap(userDoc);
          _userType = _user!.userType;
          _isLoggedIn = true;
          
          // Update last active timestamp
          await _firestore.collection('users').doc(currentUser.uid).update({
            'lastActive': Timestamp.now(),
            'isActive': true,
          });
          
          // Store user type in shared preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userType', _userType);
        } else {
          // User exists in Auth but not in Firestore
          await _auth.signOut();
          _isLoggedIn = false;
          _user = null;
          _userType = '';
        }
      } catch (e) {
        _error = e.toString();
        _isLoggedIn = false;
        _user = null;
        _userType = '';
      }
    } else {
      // No user is logged in
      _isLoggedIn = false;
      _user = null;
      
      // Try to get user type from shared preferences (for login screen routing)
      try {
        final prefs = await SharedPreferences.getInstance();
        _userType = prefs.getString('userType') ?? '';
      } catch (e) {
        _userType = '';
      }
    }
    
    _setLoading(false);
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Login user
  Future<bool> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Attempt to sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          // Check if user type matches
          if (userData['userType'] != userType) {
            await _auth.signOut();
            _setError(userType == 'provider' 
                ? 'This account is not registered as a service provider'
                : 'This account is not registered as a service seeker');
            _setLoading(false);
            return false;
          }
          
          // User exists and type matches
          _user = UserModel.fromSnap(userDoc);
          _userType = _user!.userType;
          _isLoggedIn = true;
          
          // Update last active timestamp
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastActive': Timestamp.now(),
            'isActive': true,
            'lastLogin': Timestamp.now(),
          });
          
          // Store user type in shared preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userType', _userType);
          
          _setLoading(false);
          ToastUtils.showLoginSuccessToast();
          return true;
        } else {
          // User exists in Auth but not in Firestore
          await _auth.signOut();
          _setError('User account not found');
          _setLoading(false);
          return false;
        }
      } else {
        _setError('Login failed');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign up as service seeker
  Future<bool> signUpSeeker({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    File? profileImage,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        
        // Upload profile image if provided
        String? profileImageUrl;
        if (profileImage != null) {
          profileImageUrl = await _storageMethods.uploadProfileImage(profileImage);
        }
        
        // Create user data
        UserModel userData = UserModel(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          userType: 'seeker',
          createdAt: Timestamp.now(),
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
        );
        
        // Store user data in Firestore
        await _firestore.collection('users').doc(uid).set(userData.toJson());
        
        // Set user data in provider
        _user = userData;
        _userType = 'seeker';
        _isLoggedIn = true;
        
        // Store user type in shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userType', 'seeker');
        
        _setLoading(false);
        ToastUtils.showSignUpSuccessToast();
        return true;
      } else {
        _setError('Signup failed');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Signup failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign up as service provider
  Future<bool> signUpProvider({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String category,
    required File icImage,
    required File resumeFile,
    File? profileImage,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        
        // Upload profile image if provided
        String? profileImageUrl;
        if (profileImage != null) {
          profileImageUrl = await _storageMethods.uploadProfileImage(profileImage);
        }
        
        // Upload IC image
        String icImageUrl = await _storageMethods.uploadProviderIC(icImage);
        
        // Upload resume
        String resumeUrl = await _storageMethods.uploadProviderResume(resumeFile);
        
        // Create user data
        UserModel userData = UserModel(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          userType: 'provider',
          createdAt: Timestamp.now(),
          profileImageUrl: profileImageUrl,
          category: category,
          icImageUrl: icImageUrl,
          resumeUrl: resumeUrl,
          isVerified: false, // Pending verification by admin
          availableForWork: true,
          rating: 0,
        );
        
        // Store user data in Firestore
        await _firestore.collection('users').doc(uid).set(userData.toJson());
        
        // Set user data in provider
        _user = userData;
        _userType = 'provider';
        _isLoggedIn = true;
        
        // Store user type in shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userType', 'provider');
        
        _setLoading(false);
        ToastUtils.showSignUpSuccessToast();
        return true;
      } else {
        _setError('Signup failed');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Signup failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Logout user
  Future<bool> logout() async {
    _setLoading(true);
    
    try {
      // Update user as inactive
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'isActive': false,
          'lastActive': Timestamp.now(),
        });
      }
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // Reset provider state
      _user = null;
      _isLoggedIn = false;
      // Don't reset userType to remember the user type for next login
      
      _setLoading(false);
      ToastUtils.showLogoutSuccessToast();
      return true;
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      _setLoading(false);
      ToastUtils.showPasswordResetToast();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Re-authenticate user
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null || currentUser.email == null) {
        _setError('User not found');
        _setLoading(false);
        return false;
      }
      
      // Create credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      
      // Re-authenticate
      await currentUser.reauthenticateWithCredential(credential);
      
      // Change password
      await currentUser.updatePassword(newPassword);
      
      _setLoading(false);
      ToastUtils.showPasswordChangedToast();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please login again before changing your password';
          break;
        default:
          errorMessage = 'Password change failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    File? profileImage,
    List<String>? skills,
    String? category,
    bool? availableForWork,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Check if user is logged in
      if (_user == null) {
        _setError('User not logged in');
        _setLoading(false);
        return false;
      }
      
      Map<String, dynamic> updateData = {};
      
      // Update fields if provided
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (bio != null) updateData['bio'] = bio;
      if (skills != null) updateData['skills'] = skills;
      if (category != null) updateData['category'] = category;
      if (availableForWork != null) updateData['availableForWork'] = availableForWork;
      
      // Upload profile image if provided
      if (profileImage != null) {
        String profileImageUrl = await _storageMethods.uploadProfileImage(profileImage);
        updateData['profileImageUrl'] = profileImageUrl;
      }
      
      // Update user document
      await _firestore.collection('users').doc(_user!.uid).update(updateData);
      
      // Update user object
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
      
      _user = UserModel.fromSnap(userDoc);
      
      _setLoading(false);
      ToastUtils.showProfileUpdatedToast();
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Delete user account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Re-authenticate user
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null || currentUser.email == null) {
        _setError('User not found');
        _setLoading(false);
        return false;
      }
      
      // Create credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      
      // Re-authenticate
      await currentUser.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      if (_user != null) {
        // Delete user's profile image
        if (_user!.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty) {
          await _storageMethods.deleteFile(_user!.profileImageUrl!);
        }
        
        // If provider, delete IC and resume files and services
        if (_user!.isProvider) {
          // Delete IC and resume files
          if (_user!.icImageUrl != null) {
            await _storageMethods.deleteFile(_user!.icImageUrl!);
          }
          if (_user!.resumeUrl != null) {
            await _storageMethods.deleteFile(_user!.resumeUrl!);
          }
          
          // Delete services
          QuerySnapshot servicesSnapshot = await _firestore
              .collection('services')
              .where('providerId', isEqualTo: _user!.uid)
              .get();
              
          for (var doc in servicesSnapshot.docs) {
            await _firestore.collection('services').doc(doc.id).delete();
          }
        }
        
        // Delete user document
        await _firestore.collection('users').doc(_user!.uid).delete();
      }
      
      // Delete user from Firebase Auth
      await currentUser.delete();
      
      // Reset provider state
      _user = null;
      _isLoggedIn = false;
      _userType = '';
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userType');
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Password is incorrect';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please login again before deleting your account';
          break;
        default:
          errorMessage = 'Account deletion failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_isLoggedIn || _user == null) return;
    
    _setLoading(true);
    
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
          
      if (userDoc.exists) {
        _user = UserModel.fromSnap(userDoc);
        
        // Update last active timestamp
        await _firestore.collection('users').doc(_user!.uid).update({
          'lastActive': Timestamp.now(),
        });
      }
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
    
    _setLoading(false);
  }
  
  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _firestoreMethods.getUserById(userId);
    } catch (e) {
      _setError('Failed to get user: ${e.toString()}');
      return null;
    }
  }
  
  // Update FCM token for push notifications
  Future<void> updateFcmToken(String token) async {
    if (!_isLoggedIn || _user == null) return;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      print('Failed to update FCM token: ${e.toString()}');
    }
  }
  
  // Change language preference
  Future<bool> changeLanguage(String languageCode) async {
    if (!_isLoggedIn || _user == null) return false;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'language': languageCode,
      });
      
      // Update local user object
      _user = _user!.copyWith(language: languageCode);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to change language: ${e.toString()}');
      return false;
    }
  }
}