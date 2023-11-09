import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/user_profile.dart';

abstract class ISecureStorageService {
  Future<String?> get(String key);

  Future<void> set(String key, String value);

  Future<void> deleteAll();

  Future<void> setLoginSuccess(AuthSuccess info);

  Future<void> setUserProfile(UserProfile profile);

  Future<UserProfile?> getUserProfile();
}

class SecureStorageService implements ISecureStorageService {
  final storage = const FlutterSecureStorage();

  @override
  Future<String?> get(String key) async {
    try {
      return storage.read(key: key);
    } on PlatformException catch (_) {
      await storage.deleteAll();
      return null;
    }
  }

  @override
  Future<void> set(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  @override
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  @override
  Future<void> setLoginSuccess(AuthSuccess authResult) async {
    await set("token", authResult.token);
    await set("refreshToken", authResult.refreshToken);
    await set("refreshExpiresIn", authResult.refreshExpiresIn.toString());
  }

  @override
  Future<void> setUserProfile(UserProfile profile) async {
    var profileString = jsonEncode(profile.toJson());
    await set("profile", profileString);
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    var profileString = await get("profile");
    if (profileString != null) {
      var json = jsonDecode(profileString);
      return UserProfile.fromJson(json);
    }
    return null;
  }
}
