import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Đăng ký
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await _createUserProfile(credential.user!, name);
        notifyListeners();
        return credential.user;
      }
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
    }
    return null;
  }

  // Đăng nhập  
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential.user;
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
    }
    return null;
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // Quên mật khẩu
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Lỗi reset password: $e');
      return false;
    }
  }

  // Tạo profile cho user mới
  Future<void> _createUserProfile(User user, String name) async {
    try {
      await _database.ref('users/${user.uid}').set({
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'createdAt': ServerValue.timestamp,
        'favoriteCount': 0,
        'playlistCount': 0,
      });
    } catch (e) {
      debugPrint('Lỗi tạo profile: $e');
    }
  }

  // Cập nhật profile
  Future<bool> updateProfile({String? name, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final updates = <String, dynamic>{};
      
      if (name != null) {
        await user.updateDisplayName(name);
        updates['name'] = name;
      }
      
      if (email != null && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
        updates['email'] = email;
      }
      
      if (updates.isNotEmpty) {
        await _database.ref('users/${user.uid}').update(updates);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi cập nhật profile: $e');
      return false;
    }
  }

  // Lấy thông tin user
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final snapshot = await _database.ref('users/${user.uid}').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      debugPrint('Lỗi lấy user profile: $e');
    }
    return null;
  }

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

