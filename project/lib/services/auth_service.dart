import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // FIXED: Renamed to avoid duplicate
  Stream<UserModel?> get currentUserStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        print('👤 No user logged in');
        return null;
      }

      print('🔄 Fetching user data for: ${firebaseUser.uid}');
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          print('✅ User data found');
          return UserModel.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          print('⚠️ User document does not exist');
          return null;
        }
      } catch (e) {
        print('❌ Error fetching user data: $e');
        return null;
      }
    });
  }

  // Keep existing currentUserData method
  Stream<UserModel?> get currentUserData {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        print('👤 No user logged in');
        return null;
      }

      print('🔄 Fetching user data for: ${user.uid}');
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          print('✅ User data found');
          return UserModel.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          print('⚠️ User document does not exist');
          return null;
        }
      } catch (e) {
        print('❌ Error fetching user data: $e');
        return null;
      }
    });
  }

  // Signup with additional user data
  Future<User?> signUp(String email, String password, String name) async {
    try {
      print('🔄 Starting signup for: $email');

      UserCredential result =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      print('✅ Auth user created: ${result.user!.uid}');

      // Save user data to Firestore
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        favoriteEvents: [],
        registeredEvents: [],
      );

      print('📝 Saving user data to Firestore...');
      await _firestore.collection('users').doc(result.user!.uid).set(newUser.toMap());
      print('✅ User data saved to Firestore');

      notifyListeners();
      return result.user;
    } catch (e) {
      print("❌ Signup Error: $e");
      rethrow;
    }
  }

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      print('🔄 Logging in: $email');
      UserCredential result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      print('✅ Login successful: ${result.user!.uid}');
      notifyListeners();
      return result.user;
    } catch (e) {
      print("❌ Login Error: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    print('🔄 Logging out...');
    await _auth.signOut();
    print('✅ Logout successful');
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    XFile? profileImage,
  }) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      print('🔄 Updating profile for user: $userId');
      Map<String, dynamic> updates = {};

      if (name != null && name.isNotEmpty) {
        print('📝 Updating name to: $name');
        updates['name'] = name;
      }

      if (profileImage != null) {
        print('🖼️ Uploading profile image...');
        final imageUrl = await _uploadProfileImage(profileImage);
        print('✅ Image uploaded, URL: $imageUrl');
        updates['profileImage'] = imageUrl;
      }

      if (updates.isNotEmpty) {
        print('📤 Saving updates to Firestore: $updates');
        await userRef.update(updates);
        print('✅ Profile updated successfully');
        notifyListeners();
      } else {
        print('ℹ️ No updates to save');
      }
    } catch (e) {
      print('❌ Profile update error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile image
  Future<String> _uploadProfileImage(XFile imageFile) async {
    try {
      final userId = _auth.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_images/$userId-$timestamp.jpg';
      final ref = _storage.ref().child(fileName);

      print('🔼 Starting image upload: $fileName');

      // Show progress
      final task = ref.putFile(File(imageFile.path));

      // Listen to upload progress
      task.snapshotEvents.listen((snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await task;
      final imageUrl = await ref.getDownloadURL();

      print('✅ Image upload complete. URL: $imageUrl');
      return imageUrl;

    } catch (e) {
      print('❌ Image upload error: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Get user document directly
  Future<DocumentSnapshot> getUserDocument() async {
    final userId = _auth.currentUser!.uid;
    return await _firestore.collection('users').doc(userId).get();
  }

  // Force refresh user data
  Future<void> refreshUserData() async {
    notifyListeners();
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      print('🔄 Changing password...');
      await _auth.currentUser!.updatePassword(newPassword);
      print('✅ Password changed successfully');
    } catch (e) {
      print('❌ Password change error: $e');
      throw Exception('Failed to change password: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('🔄 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Password reset error: $e');
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = _auth.currentUser!.uid;
      print('🗑️ Deleting account for user: $userId');

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User data deleted from Firestore');

      // Delete user from Auth
      await _auth.currentUser!.delete();
      print('✅ User deleted from Auth');

      notifyListeners();
    } catch (e) {
      print('❌ Delete account error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final isLogged = _auth.currentUser != null;
    print('🔐 User logged in: $isLogged');
    return isLogged;
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      print('🔄 Getting user by ID: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('✅ User found');
        return UserModel.fromMap(doc.data()! as Map<String, dynamic>);
      }
      print('⚠️ User not found');
      return null;
    } catch (e) {
      print("❌ Get user error: $e");
      return null;
    }
  }

  // Check if user document exists
  Future<bool> userDocumentExists() async {
    try {
      final userId = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Update specific fields only
  Future<void> updateField(String field, dynamic value) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(userId).update({field: value});
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update field: $e');
    }
  }

  // Add event to favorites
  Future<void> addToFavorites(String eventId) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'favoriteEvents': FieldValue.arrayUnion([eventId])
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove event from favorites
  Future<void> removeFromFavorites(String eventId) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'favoriteEvents': FieldValue.arrayRemove([eventId])
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Register for event
  Future<void> registerForEvent(String eventId) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'registeredEvents': FieldValue.arrayUnion([eventId])
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }
}