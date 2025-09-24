import 'package:flutter/foundation.dart';
import 'package:hackathlone_app/models/meal/meal.dart';
import 'package:hackathlone_app/services/meal_service.dart';
import 'package:hackathlone_app/utils/storage.dart';

/// Provider for meal-related state management with offline caching
class MealProvider extends ChangeNotifier {
  final MealService _mealService = MealService();

  // State variables
  bool _isLoading = false;
  String? _error;
  Map<HackathonDay, List<Meal>> _mealsByDay = {};
  DateTime? _lastFetchTime;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<HackathonDay, List<Meal>> get mealsByDay => _mealsByDay;
  DateTime? get lastFetchTime => _lastFetchTime;

  /// Check if cached meal data is stale (older than 30 minutes)
  bool get isCacheStale {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!).inMinutes > 30;
  }

  /// Get all meals as a flat list
  List<Meal> get allMeals {
    final meals = <Meal>[];
    for (final dayMeals in _mealsByDay.values) {
      meals.addAll(dayMeals);
    }
    return meals;
  }

  /// Get meals for a specific day
  List<Meal> getMealsForDay(HackathonDay day) {
    return _mealsByDay[day] ?? [];
  }

  /// Get a specific meal
  Meal? getMeal(HackathonDay day, MealTime mealTime) {
    final dayMeals = _mealsByDay[day] ?? [];
    try {
      return dayMeals.firstWhere((meal) => meal.mealTime == mealTime);
    } catch (e) {
      return null;
    }
  }

  /// Get days that have meals available
  List<HackathonDay> get availableDays {
    return _mealsByDay.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  /// Initialize provider - load from cache first, then fetch if needed
  Future<void> initialize() async {
    print('🍽️ MealProvider: Initializing...');

    // Load from cache first
    await _loadFromCache();

    // Fetch fresh data if cache is stale or empty
    if (isCacheStale || _mealsByDay.isEmpty) {
      await fetchMeals();
    }
  }

  /// Fetch meals from the server
  Future<void> fetchMeals({bool force = false}) async {
    if (_isLoading && !force) {
      print('🔄 MealProvider: Already loading, skipping duplicate request');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🍽️ MealProvider: Fetching meals from server');

      final groupedMeals = await _mealService.fetchMealsGroupedByDay();
      _mealsByDay = groupedMeals;
      _lastFetchTime = DateTime.now();

      // Cache the data
      await _saveToCache();

      print('✅ MealProvider: Successfully fetched ${allMeals.length} meals');
    } catch (e) {
      print('❌ MealProvider: Error fetching meals: $e');
      _setError('Failed to load meals: $e');

      // Try to load from cache as fallback
      if (_mealsByDay.isEmpty) {
        await _loadFromCache();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh meals (pull-to-refresh)
  Future<void> refreshMeals() async {
    print('🔄 MealProvider: Refreshing meals');
    await fetchMeals(force: true);
  }

  /// Fetch meals for a specific day
  Future<void> fetchMealsForDay(HackathonDay day) async {
    try {
      print('🍽️ MealProvider: Fetching meals for ${day.displayName}');

      final dayMeals = await _mealService.fetchMealsByDay(day);
      _mealsByDay[day] = dayMeals;

      // Update cache
      await _saveToCache();

      notifyListeners();
      print(
        '✅ MealProvider: Updated ${dayMeals.length} meals for ${day.displayName}',
      );
    } catch (e) {
      print('❌ MealProvider: Error fetching meals for ${day.displayName}: $e');
      _setError('Failed to load meals for ${day.displayName}: $e');
    }
  }

  /// Create a new meal (admin function)
  Future<bool> createMeal({
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
        '🍽️ MealProvider: Creating meal for ${day.displayName} ${mealTime.displayName}',
      );

      final meal = await _mealService.createMeal(
        day: day,
        mealTime: mealTime,
        provider: provider,
        description: description,
        mains: mains,
        sides: sides,
        dietaryOptions: dietaryOptions,
        items: items,
        imageUrl: imageUrl,
      );

      // Update local state
      if (_mealsByDay[day] == null) {
        _mealsByDay[day] = [];
      }
      _mealsByDay[day]!.add(meal);

      // Sort meals by time
      _sortMealsByTime(_mealsByDay[day]!);

      // Update cache
      await _saveToCache();

      notifyListeners();
      print('✅ MealProvider: Successfully created meal');
      return true;
    } catch (e) {
      print('❌ MealProvider: Error creating meal: $e');
      _setError('Failed to create meal: $e');
      return false;
    }
  }

  /// Update an existing meal (admin function)
  Future<bool> updateMeal(
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
      print('🍽️ MealProvider: Updating meal $mealId');

      final updatedMeal = await _mealService.updateMeal(
        mealId,
        provider: provider,
        description: description,
        mains: mains,
        sides: sides,
        dietaryOptions: dietaryOptions,
        items: items,
        imageUrl: imageUrl,
      );

      // Update local state
      for (final day in _mealsByDay.keys) {
        final dayMeals = _mealsByDay[day]!;
        for (int i = 0; i < dayMeals.length; i++) {
          if (dayMeals[i].id == mealId) {
            _mealsByDay[day]![i] = updatedMeal;
            break;
          }
        }
      }

      // Update cache
      await _saveToCache();

      notifyListeners();
      print('✅ MealProvider: Successfully updated meal');
      return true;
    } catch (e) {
      print('❌ MealProvider: Error updating meal: $e');
      _setError('Failed to update meal: $e');
      return false;
    }
  }

  /// Delete a meal (admin function)
  Future<bool> deleteMeal(String mealId) async {
    try {
      print('🍽️ MealProvider: Deleting meal $mealId');

      await _mealService.deleteMeal(mealId);

      // Update local state
      for (final day in _mealsByDay.keys) {
        _mealsByDay[day]!.removeWhere((meal) => meal.id == mealId);
      }

      // Update cache
      await _saveToCache();

      notifyListeners();
      print('✅ MealProvider: Successfully deleted meal');
      return true;
    } catch (e) {
      print('❌ MealProvider: Error deleting meal: $e');
      _setError('Failed to delete meal: $e');
      return false;
    }
  }

  /// Get meal statistics
  Future<Map<String, int>> getMealStatistics() async {
    try {
      return await _mealService.getMealStatistics();
    } catch (e) {
      print('❌ MealProvider: Error getting statistics: $e');
      return {};
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _sortMealsByTime(List<Meal> meals) {
    const mealTimeOrder = {
      MealTime.breakfast: 0,
      MealTime.lunch: 1,
      MealTime.dinner: 2,
    };

    meals.sort((a, b) {
      return mealTimeOrder[a.mealTime]!.compareTo(mealTimeOrder[b.mealTime]!);
    });
  }

  /// Save meals to local cache
  Future<void> _saveToCache() async {
    try {
      // Convert to a format suitable for caching
      final cacheData = {
        'mealsByDay': _mealsByDay.map(
          (day, meals) =>
              MapEntry(day.name, meals.map((meal) => meal.toJson()).toList()),
        ),
        'lastFetchTime': _lastFetchTime?.millisecondsSinceEpoch,
      };

      await HackCache.localCache.put('meals_cache', cacheData);
      print('💾 MealProvider: Saved meals to cache');
    } catch (e) {
      print('❌ MealProvider: Error saving to cache: $e');
    }
  }

  /// Load meals from local cache
  Future<void> _loadFromCache() async {
    try {
      final cacheData = HackCache.localCache.get('meals_cache');
      if (cacheData == null) {
        print('ℹ️ MealProvider: No cached meals found');
        return;
      }

      // Restore meals by day
      final Map<String, dynamic> mealsByDayData = cacheData['mealsByDay'] ?? {};

      _mealsByDay.clear();
      for (final entry in mealsByDayData.entries) {
        final dayName = entry.key;
        final mealsData = entry.value as List;

        // Find the matching HackathonDay enum
        final day = HackathonDay.values
            .where((d) => d.name == dayName)
            .firstOrNull;

        if (day != null) {
          _mealsByDay[day] = mealsData
              .map((mealJson) => Meal.fromJson(mealJson))
              .toList();
        }
      }

      // Restore last fetch time
      final lastFetchTimeMs = cacheData['lastFetchTime'] as int?;
      if (lastFetchTimeMs != null) {
        _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchTimeMs);
      }

      print('💾 MealProvider: Loaded ${allMeals.length} meals from cache');
      notifyListeners();
    } catch (e) {
      print('❌ MealProvider: Error loading from cache: $e');
      _mealsByDay.clear();
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await HackCache.localCache.delete('meals_cache');
      _mealsByDay.clear();
      _lastFetchTime = null;
      notifyListeners();
      print('🗑️ MealProvider: Cleared meal cache');
    } catch (e) {
      print('❌ MealProvider: Error clearing cache: $e');
    }
  }
}
