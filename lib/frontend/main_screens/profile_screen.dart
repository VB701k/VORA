import 'package:flutter/material.dart';
import 'package:vora/backend/services/profilePage_services.dart';
import 'package:vora/frontend/pages/login_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = ProfilePageServices.instance;
    final email = profileService.getUserEmail();

    return Scaffold(
      backgroundColor: const Color(0xFF071A1F),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF071A1F),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10232C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF243E4B)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 36, child: Icon(Icons.person)),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: profileService.getUserName(),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? '');
                },
              ),
              Text(email),
              FutureBuilder<String>(
                future: profileService.getUserAge(),
                builder: (context, snapshot) {
                  return Text('Age: ${snapshot.data ?? '-'}');
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await profileService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
