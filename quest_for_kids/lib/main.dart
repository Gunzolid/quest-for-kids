import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue running app even if Firebase fails in dev (optional)
  }

  runApp(const ProviderScope(child: QuestForKidsApp()));
}

class QuestForKidsApp extends StatelessWidget {
  const QuestForKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuestForKids',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
