import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/workout_timer.dart';

class WorkoutDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;

  const WorkoutDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              child: Column(
                children: [
                  Icon(headerIcon, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Tutorials',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildVideoExerciseTile(
                    context,
                    'Warm-up Stretches',
                    '5:00 mins',
                    'https://picsum.photos/seed/warmup/400/300',
                  ),
                  _buildVideoExerciseTile(
                    context,
                    'Jumping Jacks',
                    '3 sets x 30 secs',
                    'https://picsum.photos/seed/jacks/400/300',
                  ),
                  _buildVideoExerciseTile(
                    context,
                    'Push-ups',
                    '3 sets x 12 reps',
                    'https://picsum.photos/seed/pushups/400/300',
                  ),
                  _buildVideoExerciseTile(
                    context,
                    'Bodyweight Squats',
                    '3 sets x 15 reps',
                    'https://picsum.photos/seed/squats/400/300',
                  ),
                  _buildVideoExerciseTile(
                    context,
                    'Cool-down',
                    '5:00 mins',
                    'https://picsum.photos/seed/cooldown/400/300',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutTimerPage(
                    workoutTitle: title,
                    workoutDuration: subtitle,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'START FULL WORKOUT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoExerciseTile(
    BuildContext context,
    String name,
    String duration,
    String imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final youtubeUrl = _getYoutubeUrl(name);
          if (await canLaunchUrl(Uri.parse(youtubeUrl))) {
            await launchUrl(
              Uri.parse(youtubeUrl),
              mode: LaunchMode.externalApplication,
            );
          } else {
            debugPrint('Could not launch $youtubeUrl');
          }
        },
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  imageUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 120,
                  height: 90,
                  color: Colors.black.withAlpha(80),
                ),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(duration, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _getYoutubeUrl(String exerciseName) {
    // Map exercise names to relevant YouTube search queries
    final Map<String, String> youtubeLinks = {
      'Warm-up Stretches': 'https://www.youtube.com/results?search_query=full+body+warm+up+stretches',
      'Jumping Jacks': 'https://www.youtube.com/results?search_query=how+to+do+jumping+jacks+proper+form',
      'Push-ups': 'https://www.youtube.com/results?search_query=perfect+push+up+form+beginner',
      'Bodyweight Squats': 'https://www.youtube.com/results?search_query=proper+bodyweight+squat+form',
      'Cool-down': 'https://www.youtube.com/results?search_query=cool+down+stretching+routine',
    };
    return youtubeLinks[exerciseName] ?? 'https://www.youtube.com/results?search_query=exercise+tutorial';
  }
}

