import 'package:flutter/material.dart';
import 'dart:async';

class WorkoutTimerPage extends StatefulWidget {
  final String workoutTitle;
  final String workoutDuration;

  const WorkoutTimerPage({
    super.key,
    required this.workoutTitle,
    required this.workoutDuration,
  });

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
  late int _totalSeconds;
  late int _remainingSeconds;
  late int _sets;
  late int _currentSet;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Parse duration from string like "30 mins"
    final durationMatch = RegExp(r'(\d+)').firstMatch(widget.workoutDuration);
    int minutes =
        durationMatch != null ? int.parse(durationMatch.group(1)!) : 30;
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    _sets = 3;
    _currentSet = 1;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _currentSet = 1;
    });
  }

  void _nextSet() {
    if (_currentSet < _sets) {
      _timer?.cancel();
      setState(() {
        _currentSet++;
        _remainingSeconds = _totalSeconds;
        _isRunning = false;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Complete!'),
            content: Text('You completed set $_currentSet of $_sets'),
            actions: [
              if (_currentSet < _sets)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nextSet();
                  },
                  child: const Text('Next Set'),
                ),
              if (_currentSet == _sets)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Complete Workout'),
                ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Timer'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withAlpha(200),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.workoutTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set $_currentSet of $_sets',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Timer Display
            Text(
              _formatTime(_remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 48),
            // Control Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    label: Text(_isRunning ? 'PAUSE' : 'START'),
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton.extended(
                    onPressed: _resetTimer,
                    label: const Text('RESET'),
                    icon: const Icon(Icons.refresh),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adjust Sets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed:
                              _sets > 1 ? () => setState(() => _sets--) : null,
                          icon: const Icon(Icons.remove_circle),
                          iconSize: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          '$_sets Sets',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _sets++),
                          icon: const Icon(Icons.add_circle),
                          iconSize: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: _currentSet / _sets,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed: ${_currentSet - 1}/$_sets sets',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
