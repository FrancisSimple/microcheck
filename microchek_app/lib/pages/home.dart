// pages/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:microchek_app/pages/dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home), label: "Background Check"),
        NavigationDestination(icon: Icon(Icons.groups_rounded), label: "Persons"),
        NavigationDestination(icon: Icon(Icons.settings), label: "My Institution"),
        NavigationDestination(icon: Icon(Icons.logout), label: "Log Out"),

      ],
      smallBody: (context) => const GhanaCardValidationPage(),
    );
  }
}
