import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/meal_provider.dart';
import 'package:hackathlone_app/models/meal/meal.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MealProvider _mealProvider;

  @override
  void initState() {
    super.initState();
    _mealProvider = Provider.of<MealProvider>(context, listen: false);

    // Initialize tab controller after we know how many tabs we need
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final availableDays = _mealProvider.availableDays;
        _tabController = TabController(
          length: availableDays.length.clamp(1, 3),
          vsync: this,
        );
        setState(() {});
      }
    });

    // Fetch meals on screen load
    _mealProvider.fetchMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithBack(title: 'Meal Menus'),
      backgroundColor: const Color(0xFF000613), // Same as events screen
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, child) {
          // Show loading indicator on initial load
          if (mealProvider.isLoading && mealProvider.allMeals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.brightYellow),
                  SizedBox(height: 16),
                  Text(
                    'Loading meal menus...',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ],
              ),
            );
          }

          // Show error if loading failed and no cached data
          if (mealProvider.error != null && mealProvider.allMeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.rocketRed,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load meals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Overpass',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealProvider.error!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Overpass',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mealProvider.fetchMeals(force: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get available days with meals
          final availableDays = mealProvider.availableDays;
          if (availableDays.isEmpty) {
            return _buildEmptyState(mealProvider);
          }

          // Initialize tab controller if needed
          if (_tabController.length != availableDays.length) {
            _tabController.dispose();
            _tabController = TabController(
              length: availableDays.length,
              vsync: this,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab section
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildDateTabs(availableDays),
              ),

              // Content area
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: availableDays
                      .map((day) => _buildDayContent(day, mealProvider))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateTabs(List<HackathonDay> availableDays) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.brightYellow,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.maastrichtBlue,
        unselectedLabelColor: AppColors.brightYellow,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Overpass',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Overpass',
        ),
        tabs: availableDays.map((day) {
          return Tab(text: day.displayName);
        }).toList(),
      ),
    );
  }

  Widget _buildDayContent(HackathonDay day, MealProvider mealProvider) {
    final dayMeals = mealProvider.getMealsForDay(day);

    return RefreshIndicator(
      onRefresh: () => mealProvider.refreshMeals(),
      color: AppColors.brightYellow,
      backgroundColor: AppColors.deepBlue,
      child: dayMeals.isEmpty
          ? _buildEmptyDayState(day)
          : _buildMealsList(dayMeals),
    );
  }

  Widget _buildMealsList(List<Meal> meals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMealCard(meal),
        );
      },
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF16213E), width: 1),
      ),
      child: InkWell(
        onTap: () => _showMealDetails(meal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal title - made bigger as requested
              Text(
                meal.mealTime.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Overpass',
                ),
              ),

              const SizedBox(height: 12),

              // Meal source info
              if (meal.provider != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brightYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.brightYellow.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'From ${meal.provider}',
                    style: const TextStyle(
                      color: AppColors.brightYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ),

              if (meal.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  meal.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Overpass',
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Food items - moved before dietary options as requested
              const SizedBox(height: 16),
              _buildFoodItemsPreview(meal),

              // Dietary options - moved below items as requested
              const SizedBox(height: 16),
              _buildDietaryOptionsPreview(meal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItemsPreview(Meal meal) {
    final allItems = <String>[];
    allItems.addAll(meal.mains);
    allItems.addAll(meal.sides);
    allItems.addAll(meal.items);

    if (allItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Overpass',
          ),
        ),
        const SizedBox(height: 8),
        ...allItems.take(6).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.brightYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Overpass',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (allItems.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${allItems.length - 6} more items',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontFamily: 'Overpass',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDietaryOptionsPreview(Meal meal) {
    if (meal.dietaryOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Options',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Overpass',
          ),
        ),
        const SizedBox(height: 8),
        ...meal.dietaryOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.brightYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: AppColors.brightYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Overpass',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal title
                    Text(
                      meal.mealTime.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Overpass',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Provider
                    if (meal.provider != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brightYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brightYellow.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'From ${meal.provider}',
                          style: const TextStyle(
                            color: AppColors.brightYellow,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Overpass',
                          ),
                        ),
                      ),

                    if (meal.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        meal.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Overpass',
                          height: 1.4,
                        ),
                      ),
                    ],

                    // All items section
                    const SizedBox(height: 24),
                    _buildDetailedFoodItems(meal),

                    // Dietary options section
                    const SizedBox(height: 24),
                    _buildDetailedDietaryOptions(meal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedFoodItems(Meal meal) {
    final allItems = <String>[];
    allItems.addAll(meal.mains);
    allItems.addAll(meal.sides);
    allItems.addAll(meal.items);

    if (allItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Overpass',
          ),
        ),
        const SizedBox(height: 12),
        ...allItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.brightYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Overpass',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedDietaryOptions(Meal meal) {
    if (meal.dietaryOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Options',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Overpass',
          ),
        ),
        const SizedBox(height: 12),
        ...meal.dietaryOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.brightYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: AppColors.brightYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Overpass',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyDayState(HackathonDay day) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.restaurant, size: 64, color: Colors.white38),
        const SizedBox(height: 16),
        const Text(
          'No meals scheduled',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Overpass',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'No meals are currently scheduled for ${day.displayName}.',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 16,
            fontFamily: 'Overpass',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(MealProvider mealProvider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.restaurant_menu, size: 80, color: Colors.white38),
        const SizedBox(height: 24),
        const Text(
          'No Meal Menus Available',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Overpass',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Meal menus for the hackathon will be posted here soon. '
          'Check back later for updates!',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            fontFamily: 'Overpass',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => mealProvider.fetchMeals(force: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightYellow,
              foregroundColor: AppColors.deepBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
