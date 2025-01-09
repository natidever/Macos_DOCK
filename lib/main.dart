import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:ui' as ui; // Add this line
import 'widgets/dock/dock.dart';
import 'widgets/dock/dock_theme.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Data class representing a dock item.
class DockItemData {
  /// Icon of the dock item.
  final IconData icon;

  /// Label of the dock item.
  final String label;

  /// Color of the dock item.
  final Color color;

  /// Image path of the dock item.
  final String imagePath;

  /// Creates a new [DockItemData] instance.
  const DockItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.imagePath,
  });
}

/// [Widget] building the home screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State of the [HomeScreen] used to manipulate the [_selectedIndex].
class _HomeScreenState extends State<HomeScreen> {
  /// Index of the selected dock item.
  int? _selectedIndex;

  /// List of dock items with their respective icons, labels, and colors.
  final List<DockItemData> _dockItems = const [
    DockItemData(
      icon: Icons.folder,
      label: 'Finder',
      color: Colors.blue,
      imagePath: 'assets/icons/happy_mac.png',
    ),
    DockItemData(
      icon: Icons.web,
      label: 'Safari',
      color: Colors.blue,
      imagePath: 'assets/icons/safari.png',
    ),
    DockItemData(
      icon: Icons.music_note,
      label: 'Music',
      color: Colors.pink,
      imagePath: 'assets/icons/apple_music.png',
    ),
    DockItemData(
      icon: Icons.calendar_today,
      label: 'Calendar',
      color: Colors.orange,
      imagePath: 'assets/icons/calander.png',
    ),
    DockItemData(
      icon: Icons.web,
      label: 'Chrome',
      color: Colors.blue,
      imagePath: 'assets/icons/chrome.png',
    ),
  ];

  /// Handles the selection of a dock item.
  void _handleItemSelected(int index) {
    setState(() => _selectedIndex = index);
    debugPrint('Selected dock item: ${_dockItems[index].label}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wallpaper
          Image.asset(
            'assets/images/wallapper.jpg',  // Matches pubspec.yaml
            fit: BoxFit.cover,
          ),
          
          Center(
            child: Text(
              _selectedIndex != null
                  ? 'Selected: ${_dockItems[_selectedIndex!].label}'
                  : 'Click a dock item!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Dock with glassmorphic effect
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60, // Increased container height
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Dock(
                        theme: const DockTheme(
                          baseIconSize: 54, // Increased from 48
                          maxIconScale: 1.6,
                          borderRadius: 20,
                          backgroundOpacity: 0,
                        ),
                        selectedIndex: _selectedIndex,
                        onItemSelected: _handleItemSelected,
                        children: _dockItems.map((item) => SizedBox(
                          height: 54, // Match new baseIconSize
                          width: 54,  // Square aspect ratio
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6.0), // Increased spacing
                            child: Image.asset(
                              item.imagePath,
                              width: 48, // Slightly smaller than container for proper spacing
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
