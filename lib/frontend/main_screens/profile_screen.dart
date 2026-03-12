import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 36, child: Icon(Icons.person)),
            SizedBox(height: 8),
            Text('Your Name'),
            Text('you@example.com'),
            Text('Age: 25'),
          ],
        ),
      ),
    );
  }
}
