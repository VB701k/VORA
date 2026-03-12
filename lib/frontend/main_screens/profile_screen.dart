import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? '').trim();
    final email = (user?.email ?? '').trim();
    final ageFuture = user == null
        ? null
        : FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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
            Text(email),
            ageFuture == null
                ? const Text('Age: -')
                : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: ageFuture,
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final age = data?['age'];
                      return Text('Age: ${age ?? '-'}');
                    },
                  ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
