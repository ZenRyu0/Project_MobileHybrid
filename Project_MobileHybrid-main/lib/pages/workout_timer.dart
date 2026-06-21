import 'package:flutter/material.dart';
import 'dart:async';
class WorkoutSet {
  int setNumber;
  int duration;
  int reps;
  bool completed;
  WorkoutSet({
    required this.setNumber,
    required this.duration,
    required this.reps,
    this.completed = false,
  });
}
class WorkoutExercise {
  String name;
  List<WorkoutSet> sets;
  WorkoutExercise({
    required this.name,
    required this.sets,
  });
  int get completedSets => sets.where((s) => s.completed).length;
}
class WorkoutTimerPage extends StatefulWidget {
  final String workoutTitle;
  final String workoutDuration;
  final List<dynamic>? exercises;
  const WorkoutTimerPage({
    super.key,
    required this.workoutTitle,
    required this.workoutDuration,
    this.exercises,
  });
  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}
class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
  late List<WorkoutExercise> _exercises;
  DateTime? _startTime;
  @override
  void initState() {
    super.initState();
    _initializeExercises();
    _startTime = DateTime.now();
  }
  void _initializeExercises() {
    if (widget.exercises != null && widget.exercises!.isNotEmpty) {
      _exercises = widget.exercises!.map((ex) {
        int sets = ex['sets'] ?? 3;
        int reps = ex['reps'] ?? 12;
        int duration = ex['duration'] ?? 5;
        return WorkoutExercise(
          name: ex['name'] ?? 'Exercise',
          sets: List.generate(
            sets,
            (i) => WorkoutSet(
              setNumber: i + 1,
              duration: duration,
              reps: reps,
            ),
          ),
        );
      }).toList();
    } else {
      _exercises = [
        WorkoutExercise(name: 'Warm-up', sets: [WorkoutSet(setNumber: 1, duration: 5, reps: 0)]),
        WorkoutExercise(name: 'Push-ups', sets: [
          WorkoutSet(setNumber: 1, duration: 1, reps: 12),
          WorkoutSet(setNumber: 2, duration: 1, reps: 12),
          WorkoutSet(setNumber: 3, duration: 1, reps: 12),
        ]),
        WorkoutExercise(name: 'Squats', sets: [
          WorkoutSet(setNumber: 1, duration: 2, reps: 15),
          WorkoutSet(setNumber: 2, duration: 2, reps: 15),
        ]),
      ];
    }
  }
  void _toggleSetComplete(int exerciseIdx, int setIdx) {
    setState(() {
      _exercises[exerciseIdx].sets[setIdx].completed =
          !_exercises[exerciseIdx].sets[setIdx].completed;
    });
  }
  void _addSet(int exerciseIdx) {
    setState(() {
      final exercise = _exercises[exerciseIdx];
      final lastSet = exercise.sets.last;
      exercise.sets.add(
        WorkoutSet(
          setNumber: exercise.sets.length + 1,
          duration: lastSet.duration,
          reps: lastSet.reps,
        ),
      );
    });
  }
  void _showSetTimer(WorkoutSet set) {
    showDialog(
      context: context,
      builder: (context) => _SetTimerDialog(set: set),
    );
  }
  @override
  Widget build(BuildContext context) {
    int totalCompleted = _exercises.fold(0, (sum, ex) => sum + ex.completedSets);
    int totalSets = _exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('End Workout?'),
                content: const Text('Are you sure you want to end this workout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('End'),
                  ),
                ],
              ),
            ) ??
            false;
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track Workout'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withAlpha(180),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.workoutTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$totalCompleted/$totalSets',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Sets Complete',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${_exercises.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Exercises',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalSets > 0 ? totalCompleted / totalSets : 0,
                      minHeight: 6,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _exercises.length,
                itemBuilder: (context, exIdx) {
                  final exercise = _exercises[exIdx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${exercise.completedSets}/${exercise.sets.length} sets',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () => _addSet(exIdx),
                                tooltip: 'Add set',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            children: List.generate(exercise.sets.length, (setIdx) {
                              final set = exercise.sets[setIdx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: set.completed,
                                      onChanged: (_) => _toggleSetComplete(exIdx, setIdx),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Set ${set.setNumber}: ${set.reps > 0 ? '${set.reps} reps' : '${set.duration} min'}',
                                        style: TextStyle(
                                          decoration: set.completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      height: 32,
                                      child: OutlinedButton(
                                        onPressed: () => _showSetTimer(set),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.timer,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: totalCompleted == totalSets && totalSets > 0
              ? ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Workout Complete! 🎉'),
                        content: Text(
                          'Great job! You completed $totalSets sets.\nTotal time: ${DateTime.now().difference(_startTime!).inMinutes} minutes',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('FINISH WORKOUT'),
                )
              : Text(
                  'Complete all sets to finish ($totalCompleted/$totalSets)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
class _SetTimerDialog extends StatefulWidget {
  final WorkoutSet set;
  const _SetTimerDialog({required this.set});
  @override
  State<_SetTimerDialog> createState() => _SetTimerDialogState();
}
class _SetTimerDialogState extends State<_SetTimerDialog> {
  late int _remainingSeconds;
  late Timer _timer;
  bool _isRunning = false;
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.set.duration * 60;
  }
  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isRunning = false;
          timer.cancel();
        }
      });
    });
  }
  void _pauseTimer() {
    _timer.cancel();
    setState(() => _isRunning = false);
  }
  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Timer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              _formatTime(_remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.small(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () => setState(() => _remainingSeconds = widget.set.duration * 60),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
