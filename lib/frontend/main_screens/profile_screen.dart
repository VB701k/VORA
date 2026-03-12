import 'package:flutter/material.dart';
import 'package:vora/backend/services/profilePage_services.dart';
import 'package:vora/frontend/pages/login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _background = Color(0xFF071A1F);
  static const Color _card = Color(0xFF172B35);
  static const Color _accent = Color(0xFF2EC4F1);
  static const Color _text = Color(0xFFEAF6FB);
  static const Color _textDim = Color(0xFF9FB4C4);
  static const Color _stroke = Color(0xFF243E4B);

  final ProfilePageServices _profileService = ProfilePageServices.instance;

  late Future<Map<String, dynamic>> _profileFuture;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.fetchMyProfile();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    try {
      await _profileService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out right now.')),
      );
    }
  }

  void _reloadProfile() {
    setState(() {
      _profileFuture = _profileService.fetchMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: _background,
        foregroundColor: _text,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: _textDim,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load your profile.',
                        style: TextStyle(color: _text, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reloadProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _accent,
                          side: const BorderSide(color: _stroke),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = snapshot.data!;
            final name = profile['name'].toString();
            final email = profile['email'].toString();
            final age = profile['age'].toString();

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _stroke),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: _accent.withValues(alpha: 0.18),
                          child: Text(
                            _buildInitials(name),
                            style: const TextStyle(
                              color: _accent,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _ProfileField(label: 'Name', value: name),
                        const SizedBox(height: 12),
                        _ProfileField(label: 'Email', value: email),
                        const SizedBox(height: 12),
                        _ProfileField(label: 'Age', value: age),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSigningOut ? null : _signOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _background,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isSigningOut
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: _background,
                                    ),
                                  )
                                : const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildInitials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final value = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return value.isNotEmpty ? value : 'V';
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF10232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243E4B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9FB4C4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAF6FB),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
