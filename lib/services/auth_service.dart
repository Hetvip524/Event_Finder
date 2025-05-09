import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '28834744285-aotakauj03at8vuegg6g2kja14mdihtd.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );
  bool _isLoggedIn = false;
  String? _currentUser;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For web platform
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
        googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
        googleProvider.setCustomParameters({
          'prompt': 'select_account'
        });
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // For mobile platforms
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign in was aborted');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      if (e.toString().contains('popup_closed_by_user')) {
        throw Exception('Sign in was cancelled');
      }
      throw Exception('Failed to sign in with Google. Please try again.');
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Create a new credential
      final OAuthCredential credential = FacebookAuthProvider.credential(
        'FACEBOOK_ACCESS_TOKEN', // You need to implement Facebook login to get this token
      );

      // Sign in to Firebase with the Facebook credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Facebook: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        await _auth.signOut();
      } else {
        await Future.wait([
          _googleSignIn.signOut(),
          _auth.signOut(),
        ]);
      }
      _isLoggedIn = false;
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _isLoggedIn = true;
        _currentUser = userCredential.user!.email;
        await SharedPreferences.getInstance()
          ..setBool('isLoggedIn', true)
          ..setString('currentUser', _currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _isLoggedIn = true;
        _currentUser = userCredential.user!.email;
        await SharedPreferences.getInstance()
          ..setBool('isLoggedIn', true)
          ..setString('currentUser', _currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      _currentUser = null;
      await SharedPreferences.getInstance()
        ..setBool('isLoggedIn', false)
        ..remove('currentUser');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user.email;
      } else {
        final prefs = await SharedPreferences.getInstance();
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        _currentUser = prefs.getString('currentUser');
      }
    } catch (e) {
      print('Check login status error: $e');
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _currentUser = prefs.getString('currentUser');
    }
  }
} 