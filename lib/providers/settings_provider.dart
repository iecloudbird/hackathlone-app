import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/user/notification_preferences.dart';
import 'package:hackathlone_app/services/settings_service.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:hackathlone_app/utils/toast.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  
  NotificationPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  SettingsProvider({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService();

  // Getters
  NotificationPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load notification preferences with smart caching
  Future<void> loadPreferences(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      print('🔄 Loading notification preferences for user: $userId');

      // Check cache staleness first
      final isCacheStale = await _settingsService.isCachedPreferencesStale(userId);
      
      NotificationPreferences? preferences;

      if (isCacheStale) {
        print('📡 Fetching fresh notification preferences from API');
        try {
          preferences = await _settingsService.fetchNotificationPreferences(userId);
        } catch (e) {
          print('❌ API fetch failed, checking cache: $e');
          preferences = HackCache.getNotificationPreferences(userId);
        }
      } else {
        print('💾 Using cached notification preferences');
        preferences = HackCache.getNotificationPreferences(userId);
      }

      // Final fallback - try fresh fetch if cache is null
      preferences ??= await _settingsService.fetchNotificationPreferences(userId);

      _preferences = preferences;
      print('✅ Notification preferences loaded successfully');

    } catch (e) {
      print('❌ Failed to load notification preferences: $e');
      _error = 'Failed to load notification preferences: ${e.toString()}';
      ToastNotification.showError('Failed to load notification settings');
    } finally {
      _setLoading(false);
    }
  }

  /// Update a specific notification preference
  Future<void> updatePreference(String userId, String preferenceType, bool value) async {
    if (_preferences == null) return;

    try {
      print('🔄 Updating $preferenceType preference to $value');

      // Create update parameters
      final Map<String, bool> updates = {};
      
      switch (preferenceType) {
        case 'push':
          updates['pushNotifications'] = value;
          break;
        case 'email':
          updates['emailNotifications'] = value;
          break;
        case 'event':
          updates['eventNotifications'] = value;
          break;
        case 'admin':
          updates['adminNotifications'] = value;
          break;
        case 'marketing':
          updates['marketingNotifications'] = value;
          break;
        case 'emergency':
          updates['emergencyAlerts'] = value;
          break;
        case 'system':
          updates['systemNotifications'] = value;
          break;
        default:
          throw Exception('Unknown preference type: $preferenceType');
      }

      // Optimistically update UI
      _preferences = _updatePreferencesOptimistically(_preferences!, preferenceType, value);
      notifyListeners();

      // Update backend
      final updatedPreferences = await _settingsService.updateNotificationPreferences(
        userId: userId,
        pushNotifications: preferenceType == 'push' ? value : null,
        emailNotifications: preferenceType == 'email' ? value : null,
        eventNotifications: preferenceType == 'event' ? value : null,
        adminNotifications: preferenceType == 'admin' ? value : null,
        marketingNotifications: preferenceType == 'marketing' ? value : null,
        emergencyAlerts: preferenceType == 'emergency' ? value : null,
        systemNotifications: preferenceType == 'system' ? value : null,
      );

      _preferences = updatedPreferences;
      print('✅ Preference updated successfully');
      
      ToastNotification.showSuccess('Setting updated');

    } catch (e) {
      print('❌ Failed to update preference: $e');
      
      // Revert optimistic update
      await loadPreferences(userId);
      
      ToastNotification.showError('Failed to update setting');
    }

    notifyListeners();
  }

  /// Toggle notification preference
  Future<void> togglePreference(String userId, String preferenceType) async {
    if (_preferences == null) return;

    bool currentValue;
    switch (preferenceType) {
      case 'push':
        currentValue = _preferences!.pushNotifications;
        break;
      case 'email':
        currentValue = _preferences!.emailNotifications;
        break;
      case 'event':
        currentValue = _preferences!.eventNotifications;
        break;
      case 'admin':
        currentValue = _preferences!.adminNotifications;
        break;
      case 'marketing':
        currentValue = _preferences!.marketingNotifications;
        break;
      case 'emergency':
        currentValue = _preferences!.emergencyAlerts;
        break;
      case 'system':
        currentValue = _preferences!.systemNotifications;
        break;
      default:
        return;
    }

    await updatePreference(userId, preferenceType, !currentValue);
  }

  /// Clear app data
  Future<void> clearAppData(String userId) async {
    try {
      await _settingsService.clearAppData(userId);
      
      // Clear local preferences
      _preferences = null;
      notifyListeners();
      
      ToastNotification.showSuccess('App data cleared');
    } catch (e) {
      print('❌ Failed to clear app data: $e');
      ToastNotification.showError('Failed to clear app data');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      await _settingsService.deleteUserAccount(userId);
      
      // Clear local state
      _preferences = null;
      notifyListeners();
      
      ToastNotification.showSuccess('Account deleted');
    } catch (e) {
      print('❌ Failed to delete account: $e');
      ToastNotification.showError('Failed to delete account');
      rethrow;
    }
  }

  /// Helper to optimistically update preferences for UI responsiveness
  NotificationPreferences _updatePreferencesOptimistically(
    NotificationPreferences current, 
    String preferenceType, 
    bool value
  ) {
    switch (preferenceType) {
      case 'push':
        return current.copyWith(pushNotifications: value);
      case 'email':
        return current.copyWith(emailNotifications: value);
      case 'event':
        return current.copyWith(eventNotifications: value);
      case 'admin':
        return current.copyWith(adminNotifications: value);
      case 'marketing':
        return current.copyWith(marketingNotifications: value);
      case 'emergency':
        return current.copyWith(emergencyAlerts: value);
      case 'system':
        return current.copyWith(systemNotifications: value);
      default:
        return current;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
