import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/models/qr_code/info.dart';
import 'package:hackathlone_app/utils/cache_consent.dart';

class HackCache {
  static late final Box<UserProfile> userProfile;
  static late final Box<QrCode> qrCodes;
  static late final Box<dynamic> localCache;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    _registerAdapters();

    try {
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
    } catch (e) {
      // If opening boxes fails due to schema changes, clear cache and retry
      print('🧹 Cache schema mismatch detected, clearing cache...');
      await _clearAllCacheFiles();
      _registerAdapters();

      // Try opening boxes again
      userProfile = await Hive.openBox<UserProfile>(
        'userProfile',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      );
      qrCodes = await Hive.openBox<QrCode>(
        'qrCodes',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 1;
        },
      );
      localCache = await Hive.openBox(
        'localCache',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 4;
        },
      );
    }
  }

  static void _registerAdapters() {
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(QrCodeAdapter());
  }

  static Future<void> _clearAllCacheFiles() async {
    try {
      await Hive.deleteBoxFromDisk('userProfile');
      await Hive.deleteBoxFromDisk('qrCodes');
      await Hive.deleteBoxFromDisk('localCache');
    } catch (e) {
      print('⚠️ Error clearing cache files: $e');
    }
  }

  static Future<void> close() async {
    await userProfile.compact();
    await userProfile.close();
    await qrCodes.compact();
    await qrCodes.close();
    await localCache.compact();
    await localCache.close();
  }

  /// Cache user profile (only if user has given consent)
  static Future<void> cacheUserProfile(UserProfile profile) async {
    // Check if user has given consent to cache their profile
    final hasConsent = await CacheConsent.hasConsent();
    if (!hasConsent) {
      print('🚫 Profile caching skipped - no user consent');
      return;
    }

    // Check if a different user is trying to cache data
    final isDifferentUser = await CacheConsent.isDifferentUser(profile.id);
    if (isDifferentUser) {
      print('🔄 Different user detected, clearing previous cache');
      await clearUserCache();
    }

    await userProfile.put(profile.id, profile);
    print('💾 Profile cached with user consent: ${profile.id}');
  }

  /// Get user profile (only for consenting users)
  static UserProfile? getUserProfile(String userId) {
    return userProfile.get(userId);
  }

  /// Clear specific user's cached data
  static Future<void> clearUserCache([String? userId]) async {
    try {
      if (userId != null) {
        // Clear specific user's data
        await userProfile.delete(userId);
        // Also clear QR codes for this user
        final userQrCodes = getQrCodesByUserId(userId);
        for (final qr in userQrCodes) {
          await qrCodes.delete(qr.id);
        }
        print('🗑️ Cleared cache for user: $userId');
      } else {
        // Clear all user profiles and QR codes
        await userProfile.clear();
        await qrCodes.clear();
        print('🧹 Cleared all user cache data');
      }
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Force cache user profile (bypasses consent - use carefully)
  static Future<void> forceCacheUserProfile(UserProfile profile) async {
    await userProfile.put(profile.id, profile);
    print('⚠️ Profile force-cached (bypassed consent): ${profile.id}');
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
