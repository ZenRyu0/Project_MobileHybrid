import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../themenotifier.dart';
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dark Mode',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            ValueListenableBuilder<ThemeMode>(
                              valueListenable: themeNotifier,
                              builder: (context, mode, _) {
                                return Switch(
                                  value: mode == ThemeMode.dark,
                                  onChanged: (value) {
                                    themeNotifier.value =
                                        value
                                            ? ThemeMode.dark
                                            : ThemeMode.light;
                                    settingsProvider.setDarkMode(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calorie Unit',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'kcal',
                                  label: Text('Kilocalories'),
                                ),
                                ButtonSegment<String>(
                                  value: 'kJ',
                                  label: Text('Kilojoules'),
                                ),
                              ],
                              selected: {settingsProvider.calorieUnit},
                              onSelectionChanged: (Set<String> newSelection) async {
                                settingsProvider.setCalorieUnit(
                                  newSelection.first,
                                );
                                final userId = context.read<AuthProvider>().userId;
                                if (userId != null) {
                                  await settingsProvider.saveSettings(userId);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance Unit',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'km',
                                  label: Text('Kilometers'),
                                ),
                                ButtonSegment<String>(
                                  value: 'mi',
                                  label: Text('Miles'),
                                ),
                              ],
                              selected: {settingsProvider.distanceUnit},
                              onSelectionChanged: (Set<String> newSelection) async {
                                settingsProvider.setDistanceUnit(
                                  newSelection.first,
                                );
                                final userId = context.read<AuthProvider>().userId;
                                if (userId != null) {
                                  await settingsProvider.saveSettings(userId);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Notifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Notifications',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Switch(
                          value: settingsProvider.notificationsEnabled,
                          onChanged: (value) async {
                            settingsProvider.setNotifications(value);
                            final userId = context.read<AuthProvider>().userId;
                            if (userId != null) {
                              await settingsProvider.saveSettings(userId);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed:
                      settingsProvider.isLoading
                          ? null
                          : () async {
                            final userId = context.read<AuthProvider>().userId;
                            final messenger = ScaffoldMessenger.of(context);
                            if (userId != null) {
                              final success = await settingsProvider
                                  .saveSettings(userId);
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Settings saved successfully'
                                          : 'Failed to save settings',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                  icon:
                      settingsProvider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check),
                  label: Text(
                    settingsProvider.isLoading ? 'Saving...' : 'Save Settings',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                if (settingsProvider.errorMessage.isNotEmpty) ...[
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
                            settingsProvider.errorMessage,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  'Account',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
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
}
