import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/models/qr_code/info.dart';

class HackCache {
  static late final Box<UserProfile> userProfile;
  static late final Box<QrCode> qrCodes;
  static late final Box<dynamic> localCache;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    _registerAdapters();
    // User profiles box
    userProfile = await Hive.openBox<UserProfile>(
      'userProfile',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 2;
      },
    );
    // QR codes box
    qrCodes = await Hive.openBox<QrCode>(
      'qrCodes',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 1;
      },
    );
    // General cache for future use (e.g., events)
    localCache = await Hive.openBox(
      'localCache',
      compactionStrategy: (int entries, int deletedEntries) {
        return deletedEntries > 4;
      },
    );
  }

  static void _registerAdapters() {
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(QrCodeAdapter());
  }

  static Future<void> close() async {
    await userProfile.compact();
    await userProfile.close();
    await qrCodes.compact();
    await qrCodes.close();
    await localCache.compact();
    await localCache.close();
  }

  static Future<void> cacheUserProfile(UserProfile profile) async {
    await userProfile.put(profile.id, profile);
  }

  static UserProfile? getUserProfile(String userId) {
    return userProfile.get(userId);
  }

  static Future<void> cacheQrCode(QrCode qrCode) async {
    await qrCodes.put(qrCode.id, qrCode);
  }

  static QrCode? getQrCode(String id) {
    return qrCodes.get(id);
  }

  static List<QrCode> getQrCodesByUserId(String userId) {
    return qrCodes.values
        .where((qr) => qr.userId == userId)
        .toList(); // decide whether we want participant to have only one qr code or multiple, personally I think one is enough
  }
}
