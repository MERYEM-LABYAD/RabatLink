import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;
  final user = FirebaseAuth.instance.currentUser;

  final List<String> villes = [
    'Rabat','Casablanca','Fès','Marrakech','Tanger',
    'Agadir','Meknès','Oujda','Tétouan','Salé',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (mounted && doc.exists) {
          final data = doc.data();
          setState(() {
            usernameCtrl.text = data?['username'] ?? '';
            villeCtrl.text = data?['ville'] ?? '';
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
      }
    }
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
              AppColors.primary.withOpacity(0.1),
              AppColors.white,
              AppColors.primary.withOpacity(0.05),
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
                    const Expanded(
                      child: Text(
                        'Modifier le profil',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Contenu
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildAvatar(),
                              const SizedBox(height: 40),
                              _buildEmailCard(),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: usernameCtrl,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person_outline,
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
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: isSaving ? null : _saveProfile,
                                  icon: isSaving
                                      ? const SizedBox()
                                      : const Icon(Icons.save_outlined),
                                  label: isSaving
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              color: AppColors.white,
                                              strokeWidth: 2.5))
                                      : const Text("Enregistrer"),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                  label: const Text("Annuler"),
                                ),
                              ),
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

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.lightGreen,
            child: Text(
              (usernameCtrl.text.isNotEmpty
                      ? usernameCtrl.text
                      : user?.email ?? 'U')
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppColors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email',
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'username': usernameCtrl.text.trim(),
          'ville': villeCtrl.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Profil mis à jour avec succès !")),
              ],
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Erreur lors de la mise à jour")),
              ],
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      } finally {
        if (mounted) setState(() => isSaving = false);
      }
      
    }
  }
}