import 'package:flutter/material.dart';
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

  /// Creates a new [DockItemData] instance.
  const DockItemData({
    required this.icon,
    required this.label,
    required this.color,
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
      icon: Icons.home,
      label: 'Home',
      color: Colors.blue,
    ),
    DockItemData(
      icon: Icons.search,
      label: 'Search',
      color: Colors.green,
    ),
    DockItemData(
      icon: Icons.favorite,
      label: 'Favorites',
      color: Colors.red,
    ),
    DockItemData(
      icon: Icons.settings,
      label: 'Settings',
      color: Colors.purple,
    ),
    DockItemData(
      icon: Icons.person,
      label: 'Profile',
      color: Colors.orange,
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
        children: [
          Center(
            child: Text(
              _selectedIndex != null
                  ? 'Selected: ${_dockItems[_selectedIndex!].label}'
                  : 'Click a dock item!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Dock(
            theme: const DockTheme(
              baseIconSize: 56,
              maxIconScale: 1.8,
              borderRadius: 24,
              backgroundOpacity: 0.25,
            ),
            selectedIndex: _selectedIndex,
            onItemSelected: _handleItemSelected,
            children: _dockItems.map((item) => Container(
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: Colors.white, size: 32),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
