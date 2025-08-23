import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mentor/mentor.dart';

/// Service for mentor operations
class MentorService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all active mentors
  Future<List<Mentor>> fetchMentors() async {
    print('🧑‍🏫 MentorService: Fetching mentors');

    final response = await _supabase
        .from('mentors')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: true);

    print('📊 MentorService: Received ${response.length} mentors');

    return response.map<Mentor>((data) {
      return Mentor.fromJson(data);
    }).toList();
  }

  /// Get mentor by ID
  Future<Mentor?> getMentorById(String mentorId) async {
    try {
      final response = await _supabase
          .from('mentors')
          .select()
          .eq('id', mentorId)
          .eq('is_active', true)
          .single();

      return Mentor.fromJson(response);
    } catch (e) {
      print('⚠️ MentorService: Mentor not found: $e');
      return null;
    }
  }
}
