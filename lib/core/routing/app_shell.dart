import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Returning just the child to remove the developer RoleSwitcherBar 
    // and make the app look like a real production app.
    return child;
  }
}
