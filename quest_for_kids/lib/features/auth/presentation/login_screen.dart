import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/parent-dashboard'),
              child: const Text('Login as Parent'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/child-dashboard'),
              child: const Text('Login as Child'),
            ),
          ],
        ),
      ),
    );
  }
}
