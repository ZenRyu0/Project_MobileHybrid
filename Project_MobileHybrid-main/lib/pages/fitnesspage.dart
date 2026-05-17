import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../workoutdetail.dart';
import 'createroutinepage.dart';

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkoutPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateRoutinePage()),
            ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Custom Workout'),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          return ListView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 80.0,
            ),
            children: [
              const Text(
                'Workout Plans',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (workoutProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (workoutProvider.workoutPlans.isEmpty)
                const Center(child: Text('No workout plans available'))
              else
                ...workoutProvider.workoutPlans.map((plan) {
                  return _buildWorkoutCard(
                    context,
                    plan['name'] ?? 'Workout',
                    '${plan['duration'] ?? 0} mins • ${plan['difficulty'] ?? 'Intermediate'}',
                    Icons.fitness_center,
                    plan,
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    dynamic plan,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.play_circle_fill,
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => WorkoutDetailPage(
                    title: title,
                    subtitle: subtitle,
                    headerIcon: icon,
                  ),
            ),
          );
        },
      ),
    );
  }
}
