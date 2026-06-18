import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Vérifier la connexion après 2.5 secondes
    Future.delayed(const Duration(milliseconds: 2500), _checkLogin);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkLogin() {
    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
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
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Cercles animés en arrière-plan
            Positioned(
              top: -100,
              right: -100,
              child: _AnimatedCircle(
                size: 300,
                delay: 0,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: _AnimatedCircle(
                size: 400,
                delay: 500,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              top: 200,
              left: -50,
              child: _AnimatedCircle(
                size: 200,
                delay: 1000,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),

            // Contenu principal
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 140,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Nom de l'app
                    const Text(
                      'RabatLink',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Slogan
                    Text(
                      'Connectez-vous à Rabat',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Indicateur de chargement
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Version en bas
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les cercles animés
class _AnimatedCircle extends StatefulWidget {
  final double size;
  final int delay;
  final Color color;

  const _AnimatedCircle({
    required this.size,
    required this.delay,
    required this.color,
  });

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
