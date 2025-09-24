import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/models/meal/meal.dart';

/// Service for meal-related database operations
class MealService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all meals for the hackathon
  Future<List<Meal>> fetchAllMeals() async {
    try {
      print('🍽️ MealService: Fetching all meals');

      final response = await _supabase
          .from('meals')
          .select('*')
          .order('day', ascending: true)
          .order('meal_time', ascending: true);

      final meals = (response as List)
          .map((json) => Meal.fromJson(json))
          .toList();

      print('✅ MealService: Loaded ${meals.length} meals');
      return meals;
    } catch (e) {
      print('❌ MealService: Error fetching meals: $e');
      throw Exception('Failed to fetch meals: $e');
    }
  }

  /// Fetch meals for a specific day
  Future<List<Meal>> fetchMealsByDay(HackathonDay day) async {
    try {
      print('🍽️ MealService: Fetching meals for ${day.displayName}');

      final response = await _supabase
          .from('meals')
          .select('*')
          .eq('day', day.name)
          .order('meal_time', ascending: true);

      final meals = (response as List)
          .map((json) => Meal.fromJson(json))
          .toList();

      print(
        '✅ MealService: Loaded ${meals.length} meals for ${day.displayName}',
      );
      return meals;
    } catch (e) {
      print('❌ MealService: Error fetching meals for ${day.displayName}: $e');
      throw Exception('Failed to fetch meals for ${day.displayName}: $e');
    }
  }

  /// Fetch a specific meal by day and meal time
  Future<Meal?> fetchMeal(HackathonDay day, MealTime mealTime) async {
    try {
      print(
        '🍽️ MealService: Fetching ${day.displayName} ${mealTime.displayName}',
      );

      final response = await _supabase
          .from('meals')
          .select('*')
          .eq('day', day.name)
          .eq('meal_time', mealTime.name)
          .maybeSingle();

      if (response == null) {
        print(
          'ℹ️ MealService: No meal found for ${day.displayName} ${mealTime.displayName}',
        );
        return null;
      }

      final meal = Meal.fromJson(response);
      print(
        '✅ MealService: Loaded meal for ${day.displayName} ${mealTime.displayName}',
      );
      return meal;
    } catch (e) {
      print('❌ MealService: Error fetching meal: $e');
      throw Exception('Failed to fetch meal: $e');
    }
  }

  /// Get meals grouped by day for tab view
  Future<Map<HackathonDay, List<Meal>>> fetchMealsGroupedByDay() async {
    try {
      print('🍽️ MealService: Fetching meals grouped by day');

      final allMeals = await fetchAllMeals();
      final Map<HackathonDay, List<Meal>> groupedMeals = {};

      // Initialize all days
      for (final day in HackathonDay.values) {
        groupedMeals[day] = [];
      }

      // Group meals by day
      for (final meal in allMeals) {
        groupedMeals[meal.day]!.add(meal);
      }

      // Sort meals within each day by meal time
      for (final day in groupedMeals.keys) {
        groupedMeals[day]!.sort((a, b) {
          const mealTimeOrder = {
            MealTime.breakfast: 0,
            MealTime.lunch: 1,
            MealTime.dinner: 2,
          };
          return mealTimeOrder[a.mealTime]!.compareTo(
            mealTimeOrder[b.mealTime]!,
          );
        });
      }

      print('✅ MealService: Grouped meals by day');
      return groupedMeals;
    } catch (e) {
      print('❌ MealService: Error grouping meals: $e');
      throw Exception('Failed to group meals: $e');
    }
  }

  /// Create a new meal (admin function)
  Future<Meal> createMeal({
    required HackathonDay day,
    required MealTime mealTime,
    String? provider,
    String? description,
    List<String>? mains,
    List<String>? sides,
    List<String>? dietaryOptions,
    List<String>? items,
    String? imageUrl,
  }) async {
    try {
      print(
        '🍽️ MealService: Creating meal for ${day.displayName} ${mealTime.displayName}',
      );

      final response = await _supabase
          .from('meals')
          .insert({
            'day': day.name,
            'meal_time': mealTime.name,
            'provider': provider,
            'description': description,
            'mains': mains ?? [],
            'sides': sides ?? [],
            'dietary_options': dietaryOptions ?? [],
            'items': items ?? [],
            'image_url': imageUrl,
          })
          .select()
          .single();

      final meal = Meal.fromJson(response);
      print('✅ MealService: Created meal successfully');
      return meal;
    } catch (e) {
      print('❌ MealService: Error creating meal: $e');
      throw Exception('Failed to create meal: $e');
    }
  }

  /// Update an existing meal (admin function)
  Future<Meal> updateMeal(
    String mealId, {
    String? provider,
    String? description,
    List<String>? mains,
    List<String>? sides,
    List<String>? dietaryOptions,
    List<String>? items,
    String? imageUrl,
  }) async {
    try {
      print('🍽️ MealService: Updating meal $mealId');

      final updateData = <String, dynamic>{};
      if (provider != null) updateData['provider'] = provider;
      if (description != null) updateData['description'] = description;
      if (mains != null) updateData['mains'] = mains;
      if (sides != null) updateData['sides'] = sides;
      if (dietaryOptions != null)
        updateData['dietary_options'] = dietaryOptions;
      if (items != null) updateData['items'] = items;
      if (imageUrl != null) updateData['image_url'] = imageUrl;

      final response = await _supabase
          .from('meals')
          .update(updateData)
          .eq('id', mealId)
          .select()
          .single();

      final meal = Meal.fromJson(response);
      print('✅ MealService: Updated meal successfully');
      return meal;
    } catch (e) {
      print('❌ MealService: Error updating meal: $e');
      throw Exception('Failed to update meal: $e');
    }
  }

  /// Delete a meal (admin function)
  Future<void> deleteMeal(String mealId) async {
    try {
      print('🍽️ MealService: Deleting meal $mealId');

      await _supabase.from('meals').delete().eq('id', mealId);

      print('✅ MealService: Deleted meal successfully');
    } catch (e) {
      print('❌ MealService: Error deleting meal: $e');
      throw Exception('Failed to delete meal: $e');
    }
  }

  /// Check if a meal exists for specific day and time
  Future<bool> mealExists(HackathonDay day, MealTime mealTime) async {
    try {
      final meal = await fetchMeal(day, mealTime);
      return meal != null;
    } catch (e) {
      print('❌ MealService: Error checking meal existence: $e');
      return false;
    }
  }

  /// Get meal statistics
  Future<Map<String, int>> getMealStatistics() async {
    try {
      final meals = await fetchAllMeals();

      final stats = <String, int>{
        'total_meals': meals.length,
        'friday_meals': meals.where((m) => m.day == HackathonDay.friday).length,
        'saturday_meals': meals
            .where((m) => m.day == HackathonDay.saturday)
            .length,
        'sunday_meals': meals.where((m) => m.day == HackathonDay.sunday).length,
        'breakfast_meals': meals
            .where((m) => m.mealTime == MealTime.breakfast)
            .length,
        'lunch_meals': meals.where((m) => m.mealTime == MealTime.lunch).length,
        'dinner_meals': meals
            .where((m) => m.mealTime == MealTime.dinner)
            .length,
      };

      print('📊 MealService: Generated meal statistics');
      return stats;
    } catch (e) {
      print('❌ MealService: Error generating statistics: $e');
      throw Exception('Failed to generate meal statistics: $e');
    }
  }
}
