import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/calorie_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/app_routes.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _dailyTargetController;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _dailyTargetController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<UserProvider>().fetchUserProfile(userId);
      }
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _dailyTargetController.dispose();
    super.dispose();
  }
  void _populateFields(Map<String, dynamic> profile) {
    _nameController.text = profile['name'] ?? 'User';
    _bioController.text = profile['bio'] ?? '';
    _dailyTargetController.text = profile['dailyCalorieTarget']?.toString() ?? '2000';
  }
  Future<void> _saveProfile() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final userProvider = context.read<UserProvider>();
    final calorieProvider = context.read<CalorieProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await userProvider.updateProfile(
      userId: userId,
      name: _nameController.text.isNotEmpty ? _nameController.text : 'User',
      bio: _bioController.text,
    );
    if (!mounted) return;
    if (success) {
      final target = int.tryParse(_dailyTargetController.text) ?? 2000;
      await calorieProvider.setDailyTarget(
        userId: userId,
        dailyTarget: target,
      );
      setState(() => _isEditing = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = userProvider.userProfile ?? {};
          if (!_isEditing &&
              _nameController.text.isEmpty &&
              userProvider.userProfile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFields(profile);
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.read<AuthProvider>().userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dailyTargetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Daily Calorie Target',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: 'kcal',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditing = false),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ] else ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : profile['name'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bio',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            profile['bio'] ?? 'No bio added yet',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Daily Calorie Target',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            '${_dailyTargetController.text} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, _) {
                    final stats = workoutProvider.workoutStats ?? {};
                    final totalWorkouts = stats['totalWorkouts'] as int? ?? 0;
                    final caloriesBurned =
                        stats['caloriesBurned'] as int? ?? 0;
                    final totalMinutes = stats['totalMinutes'] as int? ?? 0;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fitness Stats',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn(
                                  context,
                                  totalWorkouts.toString(),
                                  'Workouts',
                                ),
                                _buildStatColumn(
                                  context,
                                  totalMinutes.toString(),
                                  'Minutes',
                                ),
                                _buildStatColumn(
                                  context,
                                  caloriesBurned.toString(),
                                  'Kcal Burned',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildStatColumn(
    BuildContext context,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
