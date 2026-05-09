import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';

class CaloriePage extends StatefulWidget {
  const CaloriePage({super.key});

  @override
  State<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends State<CaloriePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalorieProvider>().fetchDailyStats('1');
    });
  }

  void _showAddCalorieDialog(String mealName, Function(int) onSave) {
    final TextEditingController calorieController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $mealName'),
          content: TextField(
            controller: calorieController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter calories'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                int addedCals = int.tryParse(calorieController.text) ?? 0;
                onSave(addedCals);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, _) {
        final dailyStats = calorieProvider.dailyStats ?? {};
        final totalCals = dailyStats['totalConsumed'] ?? 0;
        final targetCals = dailyStats['dailyTarget'] ?? 2000;

        return ListView(
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
              'Meals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMealCard('Breakfast', _getMealCalories(dailyStats, 'Breakfast'), Icons.breakfast_dining, () {
              _showAddCalorieDialog('Breakfast', (cals) {
                context.read<CalorieProvider>().logMeal(
                  userId: '1',
                  mealType: 'Breakfast',
                  foodName: 'Breakfast',
                  calories: cals,
                  protein: 0,
                  carbs: 0,
                  fat: 0,
                );
              });
            }),
            _buildMealCard('Lunch', _getMealCalories(dailyStats, 'Lunch'), Icons.lunch_dining, () {
              _showAddCalorieDialog('Lunch', (cals) {
                context.read<CalorieProvider>().logMeal(
                  userId: '1',
                  mealType: 'Lunch',
                  foodName: 'Lunch',
                  calories: cals,
                  protein: 0,
                  carbs: 0,
                  fat: 0,
                );
              });
            }),
            _buildMealCard('Dinner', _getMealCalories(dailyStats, 'Dinner'), Icons.dinner_dining, () {
              _showAddCalorieDialog('Dinner', (cals) {
                context.read<CalorieProvider>().logMeal(
                  userId: '1',
                  mealType: 'Dinner',
                  foodName: 'Dinner',
                  calories: cals,
                  protein: 0,
                  carbs: 0,
                  fat: 0,
                );
              });
            }),
          ],
        );
      },
    );
  }

  Widget _buildCalorieSummary(BuildContext context, int totalCals, int targetCals, Map<String, dynamic> dailyStats) {
    double progress = (totalCals / targetCals).clamp(0.0, 1.0);
    final macros = dailyStats['macros'] as Map<String, dynamic>? ?? {};
    int carbs = macros['carbs'] ?? 0;
    int protein = macros['protein'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
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
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            _buildNutritionStat(context, 'Protein', '${protein}g'),
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
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 32),
          onPressed: onAddTapped,
        ),
      ),
    );
  }

  int _getMealCalories(Map<String, dynamic> dailyStats, String mealType) {
    try {
      final meals = dailyStats['meals'] as List<dynamic>? ?? [];
      final mealCalories = meals
          .where((meal) => meal['mealType'] == mealType)
          .fold<int>(0, (sum, meal) => sum + (meal['calories'] as int? ?? 0));
      return mealCalories;
    } catch (e) {
      debugPrint('Error calculating meal calories: $e');
      return 0;
    }
  }
}

