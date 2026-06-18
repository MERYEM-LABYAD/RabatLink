import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/screens/home/home_screen.dart';
import 'package:rabatlink/core/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final roleCtrl = TextEditingController(text: 'user');
  final photoCtrl = TextEditingController();

  bool obscurePass = true;
  bool isLoading = false;

  final List<String> villes = [
    'Rabat', 'Casablanca', 'Fès', 'Marrakech', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Tétouan', 'Salé',
  ];

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    villeCtrl.dispose();
    roleCtrl.dispose();
    photoCtrl.dispose();
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
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Contenu
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Logo
                        Hero(
                          tag: 'logo',
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Titre
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            "Créer un compte",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Rejoignez la communauté RabatLink",
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                        const SizedBox(height: 30),

                        // USERNAME
                        TextFormField(
                          controller: usernameCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.primary),
                            labelText: "Nom d'utilisateur",
                            hintText: "Entrez votre nom",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Nom d'utilisateur requis";
                            if (v.length < 3) return "Minimum 3 caractères";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // EMAIL
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.primary),
                            labelText: "Email",
                            hintText: "exemple@email.com",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Email requis";
                            if (!v.contains('@')) return "Email invalide";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // VILLE
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_city_outlined,
                                color: AppColors.primary),
                            labelText: "Ville",
                          ),
                          value: villeCtrl.text.isEmpty ? null : villeCtrl.text,
                          hint: const Text("Sélectionnez votre ville"),
                          items: villes.map((ville) {
                            return DropdownMenuItem(
                                value: ville, child: Text(ville));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => villeCtrl.text = value ?? ''),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Ville requise" : null,
                        ),
                        const SizedBox(height: 16),

                        // ROLE
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined,
                                color: AppColors.primary),
                            labelText: "Rôle",
                          ),
                          value: 'user',
                          items: ['user', 'vendeur'].map((role) {
                            return DropdownMenuItem(
                                value: role, child: Text(role));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => roleCtrl.text = value ?? 'user'),
                        ),
                        const SizedBox(height: 16),

                       

                        // PASSWORD
                        TextFormField(
                          controller: passCtrl,
                          obscureText: obscurePass,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.primary),
                            labelText: "Mot de passe",
                            hintText: "Minimum 6 caractères",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.primary,
                              ),
                              onPressed: () =>
                                  setState(() => obscurePass = !obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Mot de passe requis";
                            if (v.length < 6) return "Minimum 6 caractères";
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // BOUTON INSCRIPTION
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : register,
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("S'inscrire"),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Lien vers login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Vous avez déjà un compte ? ",
                                style: TextStyle(color: AppColors.grey)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Se connecter"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Créer l'utilisateur dans Firebase Auth
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        // Sauvegarder dans Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': usernameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'role': roleCtrl.text.trim(),
          'ville': villeCtrl.text.trim(),
          'photoUrl': photoCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        // Redirection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        String message = "Erreur d'inscription";
        if (e.code == 'weak-password') {
          message = "Le mot de passe est trop faible";
        } else if (e.code == 'email-already-in-use') {
          message = "Cet email est déjà utilisé";
        } else if (e.code == 'invalid-email') {
          message = "Email invalide";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Une erreur est survenue")),
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
