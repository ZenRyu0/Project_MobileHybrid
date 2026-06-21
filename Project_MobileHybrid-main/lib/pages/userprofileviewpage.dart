import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
class UserProfileViewPage extends StatefulWidget {
  final String userId;
  const UserProfileViewPage({super.key, required this.userId});
  @override
  State<UserProfileViewPage> createState() => _UserProfileViewPageState();
}
class _UserProfileViewPageState extends State<UserProfileViewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserProfile(widget.userId);
    });
  }
  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().userId;
    final isOwnProfile = currentUserId == widget.userId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = userProvider.userProfile ?? {};
          final name = profile['name'] ?? 'User';
          final email = profile['email'] ?? 'Unknown';
          final bio = profile['bio'] ?? 'No bio added yet';
          final totalWorkouts = profile['totalWorkouts'] as int? ?? 0;
          final totalMinutes = profile['totalMinutes'] as int? ?? 0;
          final caloriesBurned = profile['totalCaloriesBurned'] as int? ?? 0;
          final followersCount = profile['followersCount'] as int? ?? 0;
          final followingCount = profile['followingCount'] as int? ?? 0;
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
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isOwnProfile) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          userProvider.getFollowers(widget.userId);
                          _showFollowersList(context, userProvider, 'Followers');
                        },
                        child: Column(
                          children: [
                            Text(
                              followersCount.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          userProvider.getFollowing(widget.userId);
                          _showFollowersList(context, userProvider, 'Following');
                        },
                        child: Column(
                          children: [
                            Text(
                              followingCount.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: userProvider.isLoading
                        ? null
                        : () async {
                          final unfollow = userProvider.isFollowing;
                          if (unfollow) {
                            await userProvider.unfollowUser(widget.userId);
                          } else {
                            await userProvider.followUser(widget.userId);
                          }
                          if (mounted) {
                            context.read<UserProvider>()
                                .fetchUserProfile(widget.userId);
                          }
                        },
                    icon: Icon(
                      userProvider.isFollowing
                          ? Icons.person_remove
                          : Icons.person_add,
                    ),
                    label: Text(
                      userProvider.isFollowing ? 'Unfollow' : 'Follow',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userProvider.isFollowing
                          ? Colors.grey.shade600
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                          'Fitness Stats',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
  void _showFollowersList(BuildContext context, UserProvider provider, String title) {
    final list = title == 'Followers' ? provider.followers : provider.following;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: list.isEmpty
                  ? Center(
                    child: Text('No $title yet'),
                  )
                  : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final user = list[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(user['name'] ?? 'User'),
                        subtitle: Text(user['email'] ?? ''),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/user-profile',
                            arguments: user['id'],
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
