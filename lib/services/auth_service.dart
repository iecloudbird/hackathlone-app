import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: 'https://www.hackathlone.com/auth_action?type=signup',
      );

      if (response.user == null) {
        return 'Sign-up failed. Please check your email and try again.';
      }
      return null;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.statusCode) {
        case '400':
          errorMessage = 'Invalid email or password. Please try again.';
        case '422':
          errorMessage =
              'Email already in use or invalid. Please use a different email.';
        default:
          errorMessage = 'Sign-up failed: ${e.message} (${e.statusCode})';
      }
      return errorMessage;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> resetPassword({required String email}) async {
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }

    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'https://www.hackathlone.com/auth_action?type=recovery',
      );
      return null;
    } on AuthException catch (e) {
      return 'Failed to send reset email: ${e.message} (${e.statusCode})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Verifies OTP for signup or password reset, updating password when type is 'recovery'.
  Future<String?> verifyOtp({
    required String email,
    required String token,
    required String type,
    String? password,
  }) async {
    try {
      await _client.auth.verifyOTP(
        token: token,
        type: type == 'signup' ? OtpType.signup : OtpType.recovery,
        email: email.trim(),
      );

      if (type == 'recovery' && password != null) {
        await _client.auth.updateUser(UserAttributes(password: password));
      }
      return null;
    } on AuthException catch (e) {
      return 'Failed to process: ${e.message} (Status: ${e.statusCode}, Code: ${e.code})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final response = await _client
          .from('profiles')
          .select('email')
          .eq('email', email.trim())
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      return false;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        return 'Sign-in failed. Please check your credentials.';
      }
      return null;
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        // This is commented out to prevent re-sending confirmation emails.
        // await _client.auth.resend(
        //   type: OtpType.signup,
        //   email: email.trim(),
        //   emailRedirectTo:
        //       'https://www.hackathlone.com/auth_action?type=signup',
        // );
        return 'Email not confirmed. Check your email for confirmation mail.';
      }
      return e.code == 'invalid_credentials'
          ? 'Invalid email or password'
          : 'Sign-in failed: ${e.message} (${e.statusCode})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> saveCredentials(String email, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<Map<String, dynamic>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    return {'email': savedEmail, 'rememberMe': rememberMe};
  }

  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      await saveCredentials('', false); // clear credentials
      return null;
    } catch (e) {
      return 'Failed to sign out: $e';
    }
  }

  Future<bool> isCachedProfileStale(String userId) async {
    try {
      debugPrint('🔍 Checking if cached profile is stale for userId: $userId');

      UserProfile? cachedProfile;
      try {
        cachedProfile = HackCache.getUserProfile(userId);
      } catch (cacheError) {
        debugPrint('⚠️ Cache access failed: $cacheError, assuming stale');
        return true;
      }

      // If no cached profile exists, we need to fetch fresh
      if (cachedProfile == null) {
        debugPrint('💾 No cached profile found, needs fresh fetch');
        return true;
      }

      // Get minimal profile data from backend to check if stale
      final response = await _client
          .from('profiles')
          .select('updated_at, qr_code')
          .eq('id', userId)
          .single();

      final backendUpdatedAt = DateTime.parse(response['updated_at']);
      final cachedUpdatedAt = cachedProfile.updatedAt;

      debugPrint('💾 Cached profile updated_at: $cachedUpdatedAt');
      debugPrint('🌐 Backend profile updated_at: $backendUpdatedAt');
      debugPrint('📱 Cached QR Code: ${cachedProfile.qrCode}');
      debugPrint('� Backend QR Code: ${response['qr_code']}');

      // Check if timestamps differ (backend is newer)
      final isStale =
          cachedUpdatedAt == null || backendUpdatedAt.isAfter(cachedUpdatedAt);

      // Check if QR code has changed
      final qrCodeChanged = response['qr_code'] != cachedProfile.qrCode;

      if (isStale || qrCodeChanged) {
        debugPrint(
          '� Cache is stale - timestamp: $isStale, qrCode: $qrCodeChanged',
        );
        return true;
      } else {
        debugPrint('✅ Cache is current, no refresh needed');
        return false;
      }
    } catch (e) {
      debugPrint('🔄 Assuming cache is stale due to validation error');
      return true;
    }
  }

  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      debugPrint('🔍 Fetching user profile for userId: $userId');
      final response = await _client
          .from('profiles')
          .select(
            'id, email, phone, role, full_name, bio, dietary_preferences, tshirt_size, qr_code, avatar_url, created_at, updated_at',
          )
          .eq('id', userId)
          .single();

      debugPrint('📦 Raw Supabase response: $response');
      debugPrint('🔑 QR Code from database: ${response['qr_code']}');

      final profile = UserProfile.fromJson(response);
      debugPrint('✅ Profile created successfully');
      debugPrint('👤 Final profile - ID: ${profile.id}');
      debugPrint('👤 Final profile - Name: ${profile.fullName}');
      debugPrint('👤 Final profile - Role: ${profile.role}');
      debugPrint('📱 Final profile - QR Code: ${profile.qrCode}');

      // Cache profile for future use
      try {
        await HackCache.cacheUserProfile(profile);
        debugPrint('💾 Profile cached successfully');
      } catch (cacheError) {
        debugPrint(
          '⚠️ Failed to cache profile: $cacheError (continuing anyway)',
        );
      }

      return profile;
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile with onboarding or edit information
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? fullName,
    String? jobRole,
    String? tshirtSize,
    String? dietaryPreferences,
    List<String>? skills,
    String? bio,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (jobRole != null) updateData['role'] = jobRole;
      if (tshirtSize != null) updateData['tshirt_size'] = tshirtSize;
      if (dietaryPreferences != null) {
        updateData['dietary_preferences'] = dietaryPreferences;
      }
      if (skills != null) updateData['skills'] = skills;
      if (bio != null) updateData['bio'] = bio;
      if (phone != null) updateData['phone'] = phone;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = UserProfile.fromJson(response);
      // Cache updated profile
      await HackCache.cacheUserProfile(updatedProfile);
      debugPrint('💾 Updated profile cached successfully');
      return updatedProfile;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Future<QrCode?> fetchQrCode(String qrCodeValue) async {
  //   try {
  //     final response = await _client
  //         .from('qr_codes')
  //         .select('id, user_id, qr_code, type, created_at, used')
  //         .eq('qr_code', qrCodeValue)
  //         .maybeSingle();
  //     if (response == null) return null;
  //     final qrCode = QrCode.fromJson(response);
  //     await HackCache.cacheQrCode(qrCode);
  //     return qrCode;
  //   } catch (e) {
  //     debugPrint('Error fetching QR code: $e');
  //     return null;
  //   }
  // }

  // Future<void> markQrCodeAsUsed(String qrCodeId) async {
  //   try {
  //     await _client
  //         .from('qr_codes')
  //         .update({'used': true}).eq('id', qrCodeId);
  //     final qrCode = HackCache.getQrCode(qrCodeId);
  //     if (qrCode != null) {
  //       qrCode.used = true;
  //       await HackCache.cacheQrCode(qrCode);
  //     }
  //   } catch (e) {
  //     debugPrint('Error marking QR code as used: $e');
  //   }
  // }

  User? getCurrentUser() => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
