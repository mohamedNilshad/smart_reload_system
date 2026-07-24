import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserEntity user);
  Future<UserEntity?> getCachedUser();
  Future<void> clearCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _key = 'cached_user';

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheUser(UserEntity user) async {
    await secureStorage.write(key: _key, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    final jsonStr = await secureStorage.read(key: _key);
    if (jsonStr == null) return null;
    try {
      return UserEntity.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null; // corrupted cache — treat as no cache
    }
  }

  @override
  Future<void> clearCachedUser() async {
    await secureStorage.delete(key: _key);
  }
}