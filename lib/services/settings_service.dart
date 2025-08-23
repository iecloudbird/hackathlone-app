import 'package:hackathlone_app/models/user/notification_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/utils/storage.dart';

class SettingsService {
  final SupabaseClient _client;

  SettingsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Check if notification preferences cache is stale (older than 30 minutes)
  Future<bool> isCachedPreferencesStale(String userId) async {
    try {
      final cachedPrefs = HackCache.getNotificationPreferences(userId);
      if (cachedPrefs == null) {
        print('💾 No cached notification preferences found - cache is stale');
        return true;
      }

      final cacheAge = DateTime.now().difference(cachedPrefs.updatedAt);
      final isStale = cacheAge.inMinutes > 30;
      print('💾 Notification preferences cache age: ${cacheAge.inMinutes} minutes, is stale: $isStale');
      return isStale;
    } catch (e) {
      print('❌ Error checking cache staleness: $e');
      return true;
    }
  }

  /// Fetch notification preferences from Supabase
  Future<NotificationPreferences> fetchNotificationPreferences(String userId) async {
    try {
      print('🌐 Fetching notification preferences for user: $userId');
      final response = await _client
          .from('notification_preferences')
          .select('*')
          .eq('user_id', userId)
          .single();

      final preferences = NotificationPreferences.fromJson(response);
      print('✅ Fetched notification preferences successfully');

      // Cache the preferences
      try {
        await HackCache.cacheNotificationPreferences(preferences);
        print('💾 Cached notification preferences');
      } catch (cacheError) {
        print('⚠️ Failed to cache notification preferences: $cacheError');
      }

      return preferences;
    } catch (e) {
      print('❌ Failed to fetch notification preferences: $e');
      throw Exception('Failed to fetch notification preferences: $e');
    }
  }

  /// Update notification preferences
  Future<NotificationPreferences> updateNotificationPreferences({
    required String userId,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? eventNotifications,
    bool? adminNotifications,
    bool? marketingNotifications,
    bool? emergencyAlerts,
    bool? systemNotifications,
  }) async {
    try {
      print('🔄 Updating notification preferences for user: $userId');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pushNotifications != null) updateData['push_notifications'] = pushNotifications;
      if (emailNotifications != null) updateData['email_notifications'] = emailNotifications;
      if (eventNotifications != null) updateData['event_notifications'] = eventNotifications;
      if (adminNotifications != null) updateData['admin_notifications'] = adminNotifications;
      if (marketingNotifications != null) updateData['marketing_notifications'] = marketingNotifications;
      if (emergencyAlerts != null) updateData['emergency_alerts'] = emergencyAlerts;
      if (systemNotifications != null) updateData['system_notifications'] = systemNotifications;

      final response = await _client
          .from('notification_preferences')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      final updatedPreferences = NotificationPreferences.fromJson(response);
      print('✅ Updated notification preferences successfully');

      // Update cache
      try {
        await HackCache.cacheNotificationPreferences(updatedPreferences);
        print('💾 Updated notification preferences cache');
      } catch (cacheError) {
        print('⚠️ Failed to update notification preferences cache: $cacheError');
      }

      return updatedPreferences;
    } catch (e) {
      print('❌ Failed to update notification preferences: $e');
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount(String userId) async {
    try {
      print('🗑️ Deleting user account: $userId');
      
      // Note: The RLS policies should handle cascading deletes for related data
      await _client.from('profiles').delete().eq('id', userId);
      
      // Clear all cached data
      await HackCache.clearUserData(userId);
      
      print('✅ User account deleted successfully');
    } catch (e) {
      print('❌ Failed to delete user account: $e');
      throw Exception('Failed to delete user account: $e');
    }
  }

  /// Clear app data (cache only, keeps account)
  Future<void> clearAppData(String userId) async {
    try {
      print('🧹 Clearing app data for user: $userId');
      await HackCache.clearUserData(userId);
      print('✅ App data cleared successfully');
    } catch (e) {
      print('❌ Failed to clear app data: $e');
      throw Exception('Failed to clear app data: $e');
    }
  }
}
