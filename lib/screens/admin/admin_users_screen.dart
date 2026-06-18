import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final users = snapshot.data!.docs;

            return Column(
              children: [
                // Stats en haut
                _buildStatsHeader(users),
                
                // Liste des utilisateurs
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;
                      return _buildUserCard(context, user, userId);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<QueryDocumentSnapshot> users) {
    final adminCount = users.where((u) => (u.data() as Map)['role'] == 'admin').length;
    final vendorCount = users.where((u) => (u.data() as Map)['role'] == 'vendeur').length;
    final userCount = users.where((u) => (u.data() as Map)['role'] == 'user' || (u.data() as Map)['role'] == null).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', users.length.toString(), AppColors.primary),
          _buildStatItem('Admins', adminCount.toString(), Colors.red),
          _buildStatItem('vendeur', vendorCount.toString(), AppColors.secondary),
          _buildStatItem('Utilisateurs', userCount.toString(), AppColors.lightGreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, String userId) {
    final String username = user['username'] ?? user['name'] ?? 'Utilisateur';
    final String email = user['email'] ?? 'Non renseigné';
    final String role = user['role'] ?? 'user';
    final String ville = user['ville'] ?? 'Non définie';
    
    DateTime? createdAt = (user['createdAt'] as Timestamp?)?.toDate();
    String formattedDate = createdAt != null
        ? DateFormat('dd/MM/yyyy').format(createdAt)
        : 'Récemment';

    Color roleColor = role == 'admin' 
        ? Colors.red 
        : role == 'vendeur' 
            ? AppColors.secondary 
            : AppColors.lightGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec infos principales
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role == 'admin' ? 'Admin' : role == 'vendeur' ? 'vendeur' : 'User',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: roleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_city, size: 14, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(
                            ville,
                            style: const TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.admin_panel_settings,
                    label: 'Changer rôle',
                    color: AppColors.primary,
                    onTap: () => _showChangeRoleDialog(context, userId, username, role),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.grey.withValues(alpha: 0.1)),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.delete_outline,
                    label: 'Supprimer',
                    color: Colors.red,
                    onTap: () => _showDeleteDialog(context, userId, username),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, String userId, String username, String currentRole) {
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Modifier le rôle de $username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Utilisateur'),
                value: 'user',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
                activeColor: AppColors.lightGreen,
              ),
              RadioListTile<String>(
                title: const Text('vendeur'),
                value: 'vendeur',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
                activeColor: AppColors.secondary,
              ),
              RadioListTile<String>(
                title: const Text('Administrateur'),
                value: 'admin',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
                activeColor: Colors.red,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'role': selectedRole});
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rôle modifié avec succès')),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "$username" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(userId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur supprimé')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Aucun utilisateur', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}