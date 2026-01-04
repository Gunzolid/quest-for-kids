import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class ChildDashboardScreen extends ConsumerStatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  ConsumerState<ChildDashboardScreen> createState() =>
      _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends ConsumerState<ChildDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // We assume current user is logged in as child here, managed by our simplified auth state
    // But since Child login doesn't persist via Firebase Auth (it's local state in repo),
    // we need to be careful. Ideally we'd store child session.
    // However, for this demo, let's just grab the user from the provider if available,
    // or we might need to rely on passed data.
    // The current `authStateChangesProvider` might return null if we relying strictly on FA User.
    // Let's check: in AuthRepositoryImpl.getCurrentUser, we return null if not parent.
    // So `ref.watch(authStateChangesProvider)` might be null!
    // FIX: We should probably store the logged-in child in a separate provider or
    // making `authControllerProvider` hold the state is better.
    // BUT, the `LoginScreen` navigates based on `authControllerProvider` STATE.
    // Does that persist? `AsyncNotifier` state persists as long as the provider is alive.
    // So let's try reading `authControllerProvider` value.

    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    if (user == null) {
      // Fallback for reload/deep-link where state might be lost
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session expired or not found'),
              ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _selectedIndex == 0
          ? _buildMissionsTab(user.name, user.currentPoints ?? 0)
          : _buildRewardsTab(user.currentPoints ?? 0),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsTab(String name, int points) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello,', style: GoogleFonts.kanit(fontSize: 18)),
                        Text(
                          name,
                          style: GoogleFonts.kanit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.orange.withOpacity(0.2),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            '$points KP',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Today\'s Missions',
              style:
                  GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Mission List (Mock)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMissionCard(
                    'Homework', 'Math exercises pg 10-12', 50, Colors.blue),
                _buildMissionCard('Clean Room', 'Organize toys and make bed',
                    30, Colors.purple),
                _buildMissionCard(
                    'Read a Book', 'Read for 15 minutes', 20, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
      String title, String subtitle, int points, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.task_alt, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '+$points KP',
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {}, // TODO: Implement request approval
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 12)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab(int points) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.card_giftcard, size: 80, color: Colors.pink),
          const SizedBox(height: 16),
          Text(
            'Rewards Store',
            style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon!',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Text('Your Points: $points KP',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text('Logout (Test)'),
          )
        ],
      ),
    );
  }
}
