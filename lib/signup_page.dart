// signup_page.dart
import 'package:flutter/material.dart';
import 'home_screen.dart'; // ← if you want to go to Home after signup

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  String message = '';

  void signUp() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => message = "Please fill all fields ❌");
      return;
    }

    if (pass != confirm) {
      setState(() => message = "Passwords do not match ❌");
      return;
    }

    if (pass.length < 6) {
      setState(() => message = "Password must be at least 6 characters ❌");
      return;
    }

    // Demo: Accept all inputs
    setState(() => message = "Account created! (demo mode) ✅");

    // Auto login → HomeScreen
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      Flexible(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.timer,
                            size: 80,
                            color: Color(0xFFC77DFF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Sign up to get started",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 40),

                      inputField(
                        controller: nameController,
                        hint: "Full Name",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      inputField(
                        controller: emailController,
                        hint: "Email or Username",
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      inputField(
                        controller: passwordController,
                        hint: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        hidePassword: hidePassword,
                        toggle: () =>
                            setState(() => hidePassword = !hidePassword),
                      ),

                      const SizedBox(height: 16),

                      inputField(
                        controller: confirmPasswordController,
                        hint: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        hidePassword: hideConfirmPassword,
                        toggle: () => setState(
                          () => hideConfirmPassword = !hideConfirmPassword,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool hidePassword = true,
    VoidCallback? toggle,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        obscureText: isPassword ? hidePassword : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: toggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
