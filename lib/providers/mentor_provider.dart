import 'package:flutter/material.dart';
import '../services/mentor_service.dart';
import '../models/mentor/mentor.dart';
import '../utils/storage.dart';

/// Provider for mentors with caching and state management
class MentorProvider with ChangeNotifier {
  final MentorService _mentorService;

  List<Mentor> _mentors = [];
  bool _isLoading = false;
  String? _errorMessage;

  MentorProvider({MentorService? mentorService})
    : _mentorService = mentorService ?? MentorService();

  // Getters
  List<Mentor> get mentors => _mentors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch mentors with smart caching
  Future<void> fetchMentors() async {
    print('🧑‍🏫 MentorProvider: Starting to fetch mentors');
    _setLoading(true);
    _clearError();

    try {
      // Check cache staleness first
      final isCacheStale = await _isCachedMentorsStale();
      print('🔍 MentorProvider: Cache stale check result: $isCacheStale');

      if (isCacheStale) {
        // Cache is stale, fetch fresh from database
        print('🌐 MentorProvider: Fetching fresh mentors from database');
        _mentors = await _mentorService.fetchMentors();

        // Cache the fresh mentors
        await _cacheMentors(_mentors);
        print('💾 MentorProvider: Cached ${_mentors.length} mentors');
      } else {
        // Cache is current, use cached mentors
        print('📱 MentorProvider: Using cached mentors');
        _mentors = _getCachedMentors();
      }

      print('✅ MentorProvider: Loaded ${_mentors.length} mentors');
      notifyListeners();
    } catch (e) {
      print('❌ MentorProvider: Error fetching mentors: $e');
      _setError('Failed to load mentors: ${e.toString()}');

      // Fallback to cache
      try {
        _mentors = _getCachedMentors();
        print('🔄 MentorProvider: Using cached mentors as fallback');
        notifyListeners();
      } catch (cacheError) {
        print('💥 MentorProvider: Cache fallback also failed: $cacheError');
        // Final fallback to mock data for development
        _mentors = _getMockMentors();
        print('🎭 MentorProvider: Using mock data as final fallback');
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Get mentor by ID
  Future<Mentor?> getMentorById(String mentorId) async {
    // First check if we have it in memory
    try {
      return _mentors.firstWhere((mentor) => mentor.id == mentorId);
    } catch (e) {
      // Not in memory, try service
      return await _mentorService.getMentorById(mentorId);
    }
  }

  /// Check if cached mentors are stale
  Future<bool> _isCachedMentorsStale() async {
    try {
      final lastFetch =
          HackCache.localCache.get('mentors_last_fetch') as DateTime?;
      if (lastFetch == null) return true;

      // Consider cache stale after 60 minutes (mentors change less frequently)
      final staleDuration = const Duration(hours: 1);
      return DateTime.now().difference(lastFetch) > staleDuration;
    } catch (e) {
      print('⚠️ MentorProvider: Cache staleness check failed: $e');
      return true;
    }
  }

  /// Cache mentors
  Future<void> _cacheMentors(List<Mentor> mentors) async {
    try {
      final mentorsJson = mentors.map((m) => m.toJson()).toList();
      await HackCache.localCache.put('mentors', mentorsJson);
      await HackCache.localCache.put('mentors_last_fetch', DateTime.now());
      print('💾 MentorProvider: Cached ${mentors.length} mentors');
    } catch (e) {
      print('⚠️ MentorProvider: Failed to cache mentors: $e');
    }
  }

  /// Get cached mentors
  List<Mentor> _getCachedMentors() {
    try {
      final mentorsJson = HackCache.localCache.get('mentors') as List?;
      if (mentorsJson == null) return [];

      return mentorsJson.map<Mentor>((json) {
        return Mentor.fromJson(Map<String, dynamic>.from(json));
      }).toList();
    } catch (e) {
      print('⚠️ MentorProvider: Failed to get cached mentors: $e');
      return [];
    }
  }

  /// Get mock mentors for development/demo
  List<Mentor> _getMockMentors() {
    return [
      Mentor(
        id: '1',
        name: 'Michael Chen',
        role: 'AI/ML Engineer',
        company: 'OpenAI',
        description:
            'Machine learning researcher focused on practical AI applications in mobile and web development.',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '2',
        name: 'Emily Rodriguez',
        role: 'Product Manager',
        company: 'Meta',
        description:
            'Product strategy expert helping teams build user-centered solutions that scale globally.',
        imageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '3',
        name: 'Alex Kumar',
        role: 'DevOps Engineer',
        company: 'AWS',
        description:
            'Cloud infrastructure specialist with expertise in scalable systems and CI/CD pipelines.',
        imageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '4',
        name: 'Jessica Wong',
        role: 'UX Designer',
        company: 'Spotify',
        description:
            'User experience designer focused on creating intuitive and accessible digital experiences.',
        imageUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
      ),
    ];
  }

  /// Force refresh mentors (for pull-to-refresh)
  Future<void> refreshMentors() async {
    print('🔄 MentorProvider: Force refreshing mentors');

    // Clear cache to force fresh fetch
    await HackCache.localCache.delete('mentors');
    await HackCache.localCache.delete('mentors_last_fetch');

    await fetchMentors();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _mentors = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
