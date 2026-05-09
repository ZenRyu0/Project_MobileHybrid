import 'package:flutter/material.dart';
import 'caloriepage.dart';
import 'feedpage.dart';
import 'dashboardpage.dart';
import 'fitnesspage.dart';
import 'package:project_mobilehybrid/themenotifier.dart';
import '../utils/dialogs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    FitnessPage(),
    CaloriePage(),
    FeedPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Go-Fit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, __) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () {
                  themeNotifier.value =
                      mode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                showUserProfileDialog(context);
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),

      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apple), label: 'Calorie'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
