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
      debugShowCheckedModeBanner: false,
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
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
// class _HomeScreenState extends State<HomeScreen> {
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
            'assets/images/wallapper.jpg', // Matches pubspec.yaml
            fit: BoxFit.cover,
          ),

          // Center(
          //   child: Text(
          //     _selectedIndex != null
          //         ? 'Selected: ${_dockItems[_selectedIndex!].label}'
          //         : 'Click a dock item!',
          //     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          //       color: Colors.white,
          //       shadows: [
          //         Shadow(
          //           color: Colors.black.withOpacity(0.5),
          //           blurRadius: 4,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Dock with glassmorphic effect
          Column(
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.8),
              Expanded(
                child: Align(
                  // alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background container with glass effect
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 60, // Smaller container height
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
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
                          ),
                        ),
                      ),
                      // Dock with unconstrained height
                      ClipRect(
                        child: OverflowBox(
                          maxHeight:
                              90, // Allow icons to be larger than container
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Center(
                              child: Dock(
                                theme: const DockTheme(
                                  baseIconSize: 100, // Keep large icon size
                                  maxIconScale: 1.2,
                                  borderRadius: 20,
                                  backgroundOpacity: 0,
                                  spacing: 2,
                                  padding: EdgeInsets.only(
                                      top: 4, left: 8, right: 8),
                                ),
                                selectedIndex: _selectedIndex,
                                onItemSelected: _handleItemSelected,
                                children: _dockItems
                                    .map((item) => Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset(
                                            item.imagePath,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.contain,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
