import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_result.dart';
import '../providers/auth_provider.dart';
import '../providers/calorie_provider.dart';
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
  bool _isBranded = false;
  String _calorieFilter = 'all'; 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<CalorieProvider>().fetchDailyStats(userId);
      }
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
        context.read<CalorieProvider>().searchFoods(
          value,
          isBranded: _isBranded,
        );
      }
    });
  }
  List<FoodResult> _getFilteredFoods(List<FoodResult> foods) {
    List<FoodResult> filtered = foods;
    filtered = filtered.where((food) {
      final cal = food.caloriesPer100g;
      if (_calorieFilter == 'low') return cal < 100;
      if (_calorieFilter == 'medium') return cal >= 100 && cal < 250;
      if (_calorieFilter == 'high') return cal >= 250;
      return true;
    }).toList();
    final query = _searchController.text.toLowerCase();
    filtered.sort((a, b) {
      final aExact = a.description.toLowerCase().startsWith(query) ? 0 : 1;
      final bExact = b.description.toLowerCase().startsWith(query) ? 0 : 1;
      if (aExact != bExact) return aExact.compareTo(bExact);
      return a.description.length.compareTo(b.description.length);
    });
    return filtered.take(20).toList();
  }
  Widget _buildKeywordBadges(String description) {
    final desc = description.toLowerCase();
    List<Widget> badges = [];
    if (desc.contains('cooked') ||
        desc.contains('boiled') ||
        desc.contains('steamed') ||
        desc.contains('baked') ||
        desc.contains('roasted') ||
        desc.contains('fried') ||
        desc.contains('ckd')) {
      badges.add(_buildSmallBadge('Cooked', Colors.green));
    } else if (desc.contains('raw') ||
        desc.contains('dry') ||
        desc.contains('uncooked') ||
        desc.contains('fresh')) {
      badges.add(_buildSmallBadge('Raw', Colors.orange));
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Wrap(spacing: 6, children: badges),
    );
  }
  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
  void _showFoodSearchDialog(String mealType) {
    _selectedMealType = mealType;
    _searchController.clear();
    _selectedFood = null;
    _servingSizeController.clear();
    _isBranded = false;
    _calorieFilter = 'all';
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
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
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        context
                                            .read<CalorieProvider>()
                                            .searchFoods('');
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
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Wholefood'),
                              icon: Icon(Icons.eco_outlined),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Branded'),
                              icon: Icon(Icons.storefront_outlined),
                            ),
                          ],
                          selected: {_isBranded},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _isBranded = newSelection.first;
                            });
                            if (_searchController.text.isNotEmpty) {
                              _onSearchChanged(_searchController.text);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _calorieFilter == 'all',
                                onSelected: (_) => setState(() => _calorieFilter = 'all'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Low (0-100)'),
                                selected: _calorieFilter == 'low',
                                onSelected: (_) => setState(() => _calorieFilter = 'low'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Medium (100-250)'),
                                selected: _calorieFilter == 'medium',
                                onSelected: (_) => setState(() => _calorieFilter = 'medium'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('High (250+)'),
                                selected: _calorieFilter == 'high',
                                onSelected: (_) => setState(() => _calorieFilter = 'high'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<CalorieProvider>(
                          builder: (context, provider, _) {
                            if (provider.isSearching) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }
                            if (provider.foodSearchResults.isEmpty &&
                                _searchController.text.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No foods found. Try a different search.',
                                ),
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
                              height: 300,
                              child: ListView.builder(
                                itemCount: _getFilteredFoods(provider.foodSearchResults).length,
                                itemBuilder: (context, index) {
                                  final food =
                                      _getFilteredFoods(provider.foodSearchResults)[index];
                                  final isSelected =
                                      _selectedFood?.id == food.id;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color:
                                        isSelected
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer
                                            : null,
                                    child: ListTile(
                                      title: Text(
                                        food.description.toTitleCase(),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildKeywordBadges(food.description),
                                          Text(
                                            '${food.caloriesPer100g.toStringAsFixed(0)} kcal/100g • P: ${food.protein.toStringAsFixed(1)}g • C: ${food.carbs.toStringAsFixed(1)}g • F: ${food.fat.toStringAsFixed(1)}g',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Serving Size:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Slider(
                                  value:
                                      double.tryParse(
                                        _servingSizeController.text,
                                      ) ??
                                      100,
                                  min: 10,
                                  max: 500,
                                  divisions: 49,
                                  label: '${_servingSizeController.text}g',
                                  onChanged: (value) {
                                    setState(() {
                                      _servingSizeController.text = value
                                          .toStringAsFixed(0);
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildNutritionPreview(
                                  _selectedFood!,
                                  double.tryParse(
                                        _servingSizeController.text,
                                      ) ??
                                      100,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          onPressed:
                              provider.isLoading
                                  ? null
                                  : () async {
                                    final userId =
                                        context.read<AuthProvider>().userId;
                                    if (userId != null) {
                                      await context.read<CalorieProvider>().logMeal(
                                        userId: userId,
                                        mealType: _selectedMealType!,
                                        foodQuery: _selectedFood!.description,
                                        servingSize:
                                            int.tryParse(
                                              _servingSizeController.text,
                                            ) ??
                                            100,
                                        fdsId: _selectedFood!.id,
                                      );
                                    }
                                    Navigator.pop(context);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${_selectedFood!.description.toTitleCase()} added to $mealType',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          child:
                              provider.isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Save'),
                        );
                      },
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Nutrition:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildNutritionBadge('$calories kcal', Colors.orange),
              _buildNutritionBadge('P: ${protein}g', Colors.red),
              _buildNutritionBadge('C: ${carbs}g', Colors.blue),
              _buildNutritionBadge('F: ${fat}g', Colors.green),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildNutritionBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: 0.9),
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
            final userId = context.read<AuthProvider>().userId;
            if (userId != null) {
              return calorieProvider.fetchDailyStats(userId);
            }
            return Future.value();
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (calorieProvider.errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          calorieProvider.errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              _buildMealCard(
                'Breakfast',
                _getMealCalories(dailyStats, 'Breakfast'),
                Icons.breakfast_dining,
                () => _showFoodSearchDialog('Breakfast'),
              ),
              _buildMealCard(
                'Lunch',
                _getMealCalories(dailyStats, 'Lunch'),
                Icons.lunch_dining,
                () => _showFoodSearchDialog('Lunch'),
              ),
              _buildMealCard(
                'Dinner',
                _getMealCalories(dailyStats, 'Dinner'),
                Icons.dinner_dining,
                () => _showFoodSearchDialog('Dinner'),
              ),
              _buildMealCard(
                'Snack',
                _getMealCalories(dailyStats, 'Snack'),
                Icons.fastfood,
                () => _showFoodSearchDialog('Snack'),
              ),
              const SizedBox(height: 24),
              if ((dailyStats['meals'] as List<dynamic>?)?.isNotEmpty ??
                  false) ...[
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
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  Widget _buildCalorieSummary(
    BuildContext context,
    int totalCals,
    int targetCals,
    Map<String, dynamic> dailyStats,
  ) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNutritionStat(context, 'Carbs', '${carbs}g'),
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
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
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
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
                              fontSize: 28,
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
                ),
                Expanded(
                  child: _buildNutritionStat(context, 'Protein', '${protein}g'),
                ),
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
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
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
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '$calories kcal',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.add_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
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
      children:
          meals.map<Widget>((meal) {
            if (meal == null) return const SizedBox.shrink();
            final foodName = meal['foodName'] ?? 'Unknown Food';
            final calories = meal['calories'] ?? 0;
            final mealType = meal['mealType'] ?? '';
            final mealId = meal['id']?.toString();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(foodName.toString().toTitleCase()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeywordBadges(foodName.toString()),
                    Text('$calories kcal'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mealType,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () async {
                        final userId = context.read<AuthProvider>().userId;
                        if (userId != null && mealId != null) {
                          final success = await context
                              .read<CalorieProvider>()
                              .deleteMeal(mealId: mealId, userId: userId);
                          if (mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${foodName.toString().toTitleCase()} removed',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
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
extension StringExtension on String {
  String toTitleCase() {
    if (trim().isEmpty) return this;
    return toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
