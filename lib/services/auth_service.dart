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

  // verifies OTP for signup or password reset, updating password when type is 'recovery'.
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
      await saveCredentials('', false);
      return null;
    } catch (e) {
      return 'Failed to sign out: $e';
    }
  }

  Future<bool> isCachedProfileStale(String userId) async {
    try {
      UserProfile? cachedProfile;
      try {
        cachedProfile = HackCache.getUserProfile(userId);
      } catch (cacheError) {
        return true;
      }

      if (cachedProfile == null) {
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

      final isStale =
          cachedUpdatedAt == null || backendUpdatedAt.isAfter(cachedUpdatedAt);

      final qrCodeChanged = response['qr_code'] != cachedProfile.qrCode;

      if (isStale || qrCodeChanged) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return true;
    }
  }

  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select(
            'id, email, phone, role, full_name, bio, dietary_preferences, tshirt_size, job_role, skills, qr_code, avatar_url, created_at, updated_at',
          )
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);

      // Cache profile for future use
      try {
        await HackCache.cacheUserProfile(profile);
      } catch (cacheError) {
        debugPrint(
          '⚠️ Failed to cache profile: $cacheError (continuing anyway)',
        );
      }

      return profile;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<UserProfile> updateUserProfile({
    required String userId,
    String? fullName,
    String? jobRole,
    String? tshirtSize,
    String? dietaryPreferences,
    List<String>? skills,
    String? bio,
    String? phone,
    String? avatarUrl,
    bool isOnboarding = false,
  }) async {
    try {
      print(
        '🔄 Updating profile for user: $userId (onboarding: $isOnboarding)',
      );

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // For onboarding, include ID and email for upsert
      if (isOnboarding) {
        updateData['id'] = userId;
        final currentUser = _client.auth.currentUser;
        if (currentUser?.email != null) {
          updateData['email'] = currentUser!.email;
        }
      }

      if (fullName != null) updateData['full_name'] = fullName;
      if (jobRole != null) updateData['job_role'] = jobRole;
      if (tshirtSize != null) updateData['tshirt_size'] = tshirtSize;
      if (dietaryPreferences != null) {
        updateData['dietary_preferences'] = dietaryPreferences;
      }
      if (skills != null) updateData['skills'] = skills;
      if (bio != null) updateData['bio'] = bio;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      print('📝 Update data keys: ${updateData.keys}');

      Map<String, dynamic> response;

      if (isOnboarding) {
        // For onboarding, use upsert to handle profile creation
        print('🆕 Using upsert for onboarding');
        response = await _client
            .from('profiles')
            .upsert(updateData)
            .select()
            .single();
      } else {
        // For regular updates, use update
        print('🔄 Using update for profile edit');
        response = await _client
            .from('profiles')
            .update(updateData)
            .eq('id', userId)
            .select()
            .single();
      }

      print(
        '✅ Profile ${isOnboarding ? "created/updated" : "updated"} successfully',
      );

      final updatedProfile = UserProfile.fromJson(response);

      // cache
      await HackCache.cacheUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e) {
      print('❌ Failed to update user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  User? getCurrentUser() => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
