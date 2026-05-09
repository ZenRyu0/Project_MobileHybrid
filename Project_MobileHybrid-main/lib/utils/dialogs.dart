import 'package:flutter/material.dart';

void showUserProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Name: Current User'),
              SizedBox(height: 4),
              Text('Username: @fitness_fanatic'),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text('Workouts Completed: 12'),
              SizedBox(height: 4),
              Text('Current Streak: 4 Days 🔥'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
  );
}
