import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/workout_provider.dart';
class LogWorkoutPage extends StatefulWidget {
  const LogWorkoutPage({super.key});
  @override
  State<LogWorkoutPage> createState() => _LogWorkoutPageState();
}
class _LogWorkoutPageState extends State<LogWorkoutPage> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesBurnedController;
  late TextEditingController _notesController;
  String _selectedDifficulty = 'Intermediate';
  final List<String> _selectedExercises = [];
  final List<String> _availableExercises = [
    'Push-ups',
    'Squats',
    'Lunges',
    'Plank',
    'Burpees',
    'Jumping Jacks',
    'Running',
    'Cycling',
    'Swimming',
    'Weight Lifting',
    'Yoga',
    'Stretching',
  ];
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _durationController = TextEditingController();
    _caloriesBurnedController = TextEditingController();
    _notesController = TextEditingController();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesBurnedController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  Future<void> _submitWorkout() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }
    if (_durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter duration')),
      );
      return;
    }
    if (_caloriesBurnedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter calories burned')),
      );
      return;
    }
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final duration = int.tryParse(_durationController.text) ?? 0;
    final caloriesBurned = int.tryParse(_caloriesBurnedController.text) ?? 0;
    final success = await context.read<WorkoutProvider>().logWorkout(
      userId: userId,
      name: _nameController.text,
      duration: duration,
      caloriesBurned: caloriesBurned,
      difficulty: _selectedDifficulty,
      exercises: _selectedExercises,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} logged successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log workout')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Workout Name',
                    hintText: 'e.g., Morning Cardio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration',
                    hintText: 'Minutes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: 'min',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _caloriesBurnedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calories Burned',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: 'kcal',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'Beginner',
                      label: Text('Beginner'),
                    ),
                    ButtonSegment<String>(
                      value: 'Intermediate',
                      label: Text('Intermediate'),
                    ),
                    ButtonSegment<String>(
                      value: 'Advanced',
                      label: Text('Advanced'),
                    ),
                  ],
                  selected: {_selectedDifficulty},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedDifficulty = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableExercises.map((exercise) {
                    final isSelected = _selectedExercises.contains(exercise);
                    return FilterChip(
                      label: Text(exercise),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedExercises.add(exercise);
                          } else {
                            _selectedExercises.remove(exercise);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'How did you feel? Any comments?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: workoutProvider.isLoading ? null : _submitWorkout,
                  icon: workoutProvider.isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    workoutProvider.isLoading ? 'Logging...' : 'Log Workout',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (workoutProvider.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                            workoutProvider.errorMessage,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
