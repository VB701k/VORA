import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? '').trim();

    return Scaffold(
      backgroundColor: const Color(0xFF071A1F),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF071A1F),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person)),
            const SizedBox(height: 8),
            Text(name),
            const Text('you@example.com'),
            const Text('Age: 25'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
