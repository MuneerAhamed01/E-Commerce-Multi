import 'package:flutter/material.dart';

/// Root widget of the Storefront app.
///
/// This is a Phase 1 (Project Foundation) placeholder: it only proves the
/// flavor/bootstrap wiring works end to end. It is replaced by a real
/// `MaterialApp.router` (driven by `go_router` and `AppTheme`) in Phase 5
/// (Routing Foundation) and Phase 4 (Design System), respectively - see
/// docs/03_DEVELOPMENT_PHASES.md.
class AppWidget extends StatelessWidget {
  const AppWidget({required this.flavor, super.key});

  /// The active flavor/environment name (`dev`, `staging`, `prod`), as set
  /// by the corresponding `main_<flavor>.dart` entry point.
  final String flavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White Label Commerce Platform - Storefront',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'White Label Commerce Platform',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Storefront'),
              const SizedBox(height: 24),
              Text('Flavor: $flavor'),
              const SizedBox(height: 4),
              const Text(
                'Phase 1: Project Foundation placeholder.\n'
                'Real app shell arrives in later phases.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
