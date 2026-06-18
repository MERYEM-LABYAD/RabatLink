import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/screens/home/home_screen.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:rabatlink/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.white,
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            "Bienvenue",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Connectez-vous à votre compte",
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                            labelText: "Email",
                          ),
                          validator: (v) => v!.isEmpty ? "Email requis" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passCtrl,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                            labelText: "Mot de passe",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.primary,
                              ),
                              onPressed: () => setState(() => obscure = !obscure),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? "Mot de passe requis" : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("Se connecter"),
                          ),
                        ),
                        const SizedBox(height: 20),
                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Pas encore de compte ? ", style: TextStyle(color: AppColors.grey)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: const Text("S'inscrire"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Erreur de connexion")),
              ],
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }
}