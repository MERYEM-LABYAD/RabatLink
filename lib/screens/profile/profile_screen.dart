import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:rabatlink/screens/profile/edit_profile_screen.dart';
import 'package:rabatlink/screens/admin/admin_users_screen.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (mounted) {
          setState(() {
            userData = doc.data();
            isAdmin = userData?['role'] == 'admin';
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
      backgroundColor: AppColors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header avec dégradé et Avatar
                _buildHeader(),

                // Corps de la page
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informations personnelles",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Liste des infos
                        _buildInfoCard(
                          icon: Icons.location_city_rounded,
                          title: "Ville de résidence",
                          value: userData?['ville'] ?? 'Non définie',
                          color: AppColors.primary,
                        ),
                      
                        const SizedBox(height: 10),
                        _buildInfoCard(
                          icon: Icons.calendar_month_rounded,
                          title: "Membre depuis",
                          value: _formatDate(userData?['createdAt']),
                          color: Colors.blueAccent,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Boutons d'actions
                        _buildActionButton(
                          icon: Icons.edit_note_rounded,
                          label: "Modifier mon profil",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          ).then((_) => _loadUserData()),
                        ),
                      
                        // BOUTON ADMIN (visible uniquement pour les admins)
                        if (isAdmin) ...[
                          const SizedBox(height: 10),
                          _buildAdminButton(),
                        ],
                        
                        const SizedBox(height: 20),

                        // Déconnexion
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                              ),
                            ),
                            onPressed: () => _showLogoutDialog(context),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text("Se déconnecter de RabatLink", 
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 60),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.red : AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: (isAdmin ? Colors.red : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userData?['username'] ?? 'Utilisateur',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: isAdmin ? Colors.red.shade300 : AppColors.lightGreen,
        child: Text(
          (userData?['username'] ?? user?.email ?? 'U')
              .substring(0, 1)
              .toUpperCase(),
          style: const TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.red.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 14),
              const Text(
                'Gérer les utilisateurs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Récemment';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return 'Récemment';
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, a1, a2) => Container(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Déconnexion"),
              content: const Text("Voulez-vous vraiment quitter votre session sur RabatLink ?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler", style: TextStyle(color: AppColors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}