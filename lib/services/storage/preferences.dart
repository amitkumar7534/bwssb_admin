import 'dart:convert';
import 'package:bwssb/feature/data/models/dataModels/login_model/login_model.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _langKey = 'language_bwssb';
  static const _uidKey = 'uid_bwssb';
  static const _userPDataKey = 'profileData_bwssb';
  static const _authTokenPDataKey = 'authTokenData_bwssb';
  static const _fcmTokenKey = 'fcmToken_bwssb';
  static const _uploadedImageKey = 'uploadedImage_bwssb';
  static const _emailKey = 'email_bwssb';
  static const _seemypostKey = 'seemypost_bwssb';
  static const _sharepostKey = 'sharepost_bwssb';
  static const _rememberMeKey = 'rememberMe_bwssb';

  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  static Future<void> createInstance() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('Preferences not initialized. Call createInstance() first.');
    }
    return _prefs!;
  }

  // UID
  static set uid(String? uid) =>
      uid != null ? prefs.setString(_uidKey, uid) : prefs.remove(_uidKey);

  static String? get uid => prefs.getString(_uidKey);

  // Email
  static set email(String? value) =>
      value != null ? prefs.setString(_emailKey, value) : prefs.remove(_emailKey);

  static String? get email => prefs.getString(_emailKey);

  // See My Post
  static set seeMyPost(String? value) =>
      value != null ? prefs.setString(_seemypostKey, value) : prefs.remove(_seemypostKey);

  static String? get seeMyPost => prefs.getString(_seemypostKey);

  // Share My Post
  static set shareMyPost(String? value) =>
      value != null ? prefs.setString(_sharepostKey, value) : prefs.remove(_sharepostKey);

  static String? get shareMyPost => prefs.getString(_sharepostKey);

  static set rememberMe(bool value) =>
      prefs.setBool(_rememberMeKey, value);

  static bool get rememberMe => prefs.getBool(_rememberMeKey) ?? false;

  // Profile Data
  static set profile(LoginModel? data) {
    if (data != null) {
      final json = jsonEncode(data);
      prefs.setString(_userPDataKey, json);
    } else {
      prefs.remove(_userPDataKey);
    }
  }

  static LoginModel? get profile {
    final jsonString = prefs.getString(_userPDataKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return LoginModel.fromJson(json);
      } catch (e) {
        print('Error decoding profile JSON: $e');
        return null;
      }
    }
    return null;
  }

  // Auth Token
  static set authToken(String? value) =>
      value != null ? prefs.setString(_authTokenPDataKey, value) : prefs.remove(_authTokenPDataKey);

  static String? get authToken => prefs.getString(_authTokenPDataKey);

  static bool get hasSession => authToken.isNotNullEmpty;

  // FCM Token
  static set fcmToken(String? value) =>
      value != null ? prefs.setString(_fcmTokenKey, value) : prefs.remove(_fcmTokenKey);

  static String? get fcmToken => prefs.getString(_fcmTokenKey);

  // Uploaded Image
  static set uploadedImage(String? imageUrl) =>
      imageUrl != null ? prefs.setString(_uploadedImageKey, imageUrl) : prefs.remove(_uploadedImageKey);

  static String? get uploadedImage => prefs.getString(_uploadedImageKey);

  static String? getImage() => prefs.getString(_uploadedImageKey);

  // Language
  static set language(String? value) =>
      value != null ? prefs.setString(_langKey, value) : prefs.remove(_langKey);

  static String? get language => prefs.getString(_langKey);

  // Save Preferences
  static set savePrefOnLogin(LoginModel? data) {
    profile = data;
  }

  static set savePrefOnSocialLogin(LoginModel? data) {
    profile = data;
  }

  // Clear Methods
  static Future<void> clearAuthData() async {
    await prefs.remove(_authTokenPDataKey);
    await prefs.remove(_uidKey);
  }

  static Future<void> clearLanguage() async {
    await prefs.remove(_langKey);
  }

  static Future<void> clearUploadedImage() async {
    await prefs.remove(_uploadedImageKey);
  }

  static void clearUserData() {
    uid = null;
    profile = null;
    authToken = null;
    fcmToken = null;
    uploadedImage = null;
  }

  static Future<void> clearAll() async {
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final username = prefs.getString('username');
    final password = prefs.getString('password');

    await prefs.clear();

    if (rememberMe) {
      await prefs.setBool('remember_me', rememberMe);
      if (username != null) await prefs.setString('username', username);
      if (password != null) await prefs.setString('password', password);
    }
  }


  static Future<void> onLogout() async {
    clearUserData();
  }
}
