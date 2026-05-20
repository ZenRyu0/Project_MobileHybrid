import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_result.dart';
import '../providers/calorie_provider.dart';
import '../providers/auth_provider.dart';

class CaloriePage extends StatefulWidget {
  const CaloriePage({super.key});

  @override
  State<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends State<CaloriePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedMealType;
  FoodResult? _selectedFood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = '1'; // TODO: Get from AuthProvider when userId is stored
      context.read<CalorieProvider>().fetchDailyStats(userId);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<CalorieProvider>().searchFoods(value);
      }
    });
  }

  void _showFoodSearchDialog(String mealType) {
    _selectedMealType = mealType;
    _searchController.clear();
    _selectedFood = null;
    _servingSizeController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add $mealType'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search food (e.g., rice, chicken)',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<CalorieProvider>().searchFoods('');
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        _onSearchChanged(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<CalorieProvider>(
                      builder: (context, provider, _) {
                        if (provider.isSearching) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (provider.foodSearchResults.isEmpty && _searchController.text.isNotEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No foods found. Try a different search.'),
                          );
                        }

                        if (_searchController.text.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Type to search foods',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }

                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: provider.foodSearchResults.length,
                            itemBuilder: (context, index) {
                              final food = provider.foodSearchResults[index];
                              final isSelected = _selectedFood?.id == food.id;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                                child: ListTile(
                                  title: Text(food.description),
                                  subtitle: Text(
                                    '${food.caloriesPer100g.toStringAsFixed(0)} kcal/100g • P: ${food.protein.toStringAsFixed(1)}g • C: ${food.carbs.toStringAsFixed(1)}g • F: ${food.fat.toStringAsFixed(1)}g',
                                    style: const TextStyle(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedFood = food;
                                      _servingSizeController.text = '100';
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    if (_selectedFood != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Serving Size:',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _servingSizeController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      suffix: const Text('g'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: double.tryParse(_servingSizeController.text) ?? 100,
                              min: 10,
                              max: 500,
                              divisions: 49,
                              label: '${_servingSizeController.text}g',
                              onChanged: (value) {
                                setState(() {
                                  _servingSizeController.text = value.toStringAsFixed(0);
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildNutritionPreview(
                                _selectedFood!, double.tryParse(_servingSizeController.text) ?? 100),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (_selectedFood != null)
                Consumer<CalorieProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              final userId = '1'; // TODO: Get from AuthProvider when userId is stored
                              context.read<CalorieProvider>().logMeal(
                                    userId: userId,
                                    mealType: _selectedMealType!,
                                    foodQuery: _selectedFood!.description,
                                    servingSize: int.tryParse(_servingSizeController.text) ?? 100,
                                    fdsId: _selectedFood!.id,
                                  );
                              Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${_selectedFood!.description} added to $mealType'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      child: provider.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                    );
                  },
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildNutritionPreview(FoodResult food, double servingSize) {
    final multiplier = servingSize / 100;
    final calories = (food.caloriesPer100g * multiplier).toStringAsFixed(0);
    final protein = (food.protein * multiplier).toStringAsFixed(1);
    final carbs = (food.carbs * multiplier).toStringAsFixed(1);
    final fat = (food.fat * multiplier).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Nutrition:', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildNutritionBadge('$calories kcal', Colors.orange),
            _buildNutritionBadge('P: ${protein}g', Colors.red),
            _buildNutritionBadge('C: ${carbs}g', Colors.blue),
            _buildNutritionBadge('F: ${fat}g', Colors.yellow),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, _) {
        final dailyStats = calorieProvider.dailyStats ?? {};
        final totalCals = dailyStats['totalConsumed'] as int? ?? 0;
        final targetCals = dailyStats['dailyTarget'] as int? ?? 2000;

        return RefreshIndicator(
          onRefresh: () {
            final userId = '1'; // TODO: Get from AuthProvider when userId is stored
            return calorieProvider.fetchDailyStats(userId);
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                "Today's Nutrition",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCalorieSummary(context, totalCals, targetCals, dailyStats),
              const SizedBox(height: 24),
              const Text(
                'Add Meals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMealCard('Breakfast', _getMealCalories(dailyStats, 'Breakfast'), Icons.breakfast_dining,
                  () => _showFoodSearchDialog('Breakfast')),
              _buildMealCard('Lunch', _getMealCalories(dailyStats, 'Lunch'), Icons.lunch_dining,
                  () => _showFoodSearchDialog('Lunch')),
              _buildMealCard('Dinner', _getMealCalories(dailyStats, 'Dinner'), Icons.dinner_dining,
                  () => _showFoodSearchDialog('Dinner')),
              _buildMealCard('Snack', _getMealCalories(dailyStats, 'Snack'), Icons.fastfood,
                  () => _showFoodSearchDialog('Snack')),
              const SizedBox(height: 24),
              if ((dailyStats['meals'] as List<dynamic>?)?.isNotEmpty ?? false) ...[
                const Text(
                  'Today\'s Meals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildMealsList(dailyStats['meals'] as List<dynamic>),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No meals logged yet. Add a meal to get started!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalorieSummary(BuildContext context, int totalCals, int targetCals, Map<String, dynamic> dailyStats) {
    double progress = (totalCals / targetCals).clamp(0.0, 1.0);
    final macros = dailyStats['macros'] as Map<String, dynamic>? ?? {};
    int carbs = (macros['carbs'] as num?)?.toInt() ?? 0;
    int protein = (macros['protein'] as num?)?.toInt() ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionStat(context, 'Carbs', '${carbs}g'),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, child) {
                          return CircularProgressIndicator(
                            value: animatedValue,
                            strokeWidth: 10,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalCals',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kcal Eaten',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                _buildNutritionStat(context, 'Protein', '${protein}g'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Goal: $targetCals kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMealCard(
    String title,
    int calories,
    IconData icon,
    VoidCallback onAddTapped,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '$calories kcal',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 32),
          onPressed: onAddTapped,
        ),
      ),
    );
  }

  Widget _buildMealsList(List<dynamic> meals) {
    if (meals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: meals.map<Widget>((meal) {
        if (meal == null) return const SizedBox.shrink();

        final foodName = meal['foodName'] ?? 'Unknown Food';
        final calories = meal['calories'] ?? 0;
        final mealType = meal['mealType'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(foodName),
            subtitle: Text('$calories kcal'),
            trailing: Text(
              mealType,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }).toList(),
    );
  }

  int _getMealCalories(Map<String, dynamic> dailyStats, String mealType) {
    try {
      final meals = dailyStats['meals'] as List<dynamic>? ?? [];
      if (meals.isEmpty) return 0;

      final mealCalories = meals
          .where((meal) => meal?['mealType'] == mealType)
          .fold<int>(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
      return mealCalories;
    } catch (e) {
      debugPrint('Error calculating meal calories: $e');
      return 0;
    }
  }
}

