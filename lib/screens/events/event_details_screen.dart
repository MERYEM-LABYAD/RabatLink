import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = eventData['createdBy'] == currentUserId;
    

    
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        bool isAdmin = false;
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          isAdmin = (userSnapshot.data!.data() as Map)['role'] == 'admin';
        }
        
        return _buildContent(context, isOwner, isAdmin);
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isOwner, bool isAdmin) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Gestion de la date
    DateTime? eventDate = (eventData['date'] as Timestamp?)?.toDate();
    String formattedDate = eventDate != null
        ? DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(eventDate)
        : "Date à venir";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de l'événement
                  Image.network(
                    eventData['imageUrl'] ?? 'https://via.placeholder.com/600x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.lightGreen.withValues(alpha: 0.3),
                      child: const Icon(Icons.event, size: 80, color: AppColors.primary),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Badge catégorie
                  Positioned(
                    top: 60,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        eventData['category'] ?? 'Général',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventData['title'] ?? 'Sans titre',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Informations principales
                        _buildInfoRow(
                          Icons.calendar_today,
                          "Date",
                          formattedDate,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          "Lieu",
                          eventData['location'] ?? 'Rabat',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.person_outline,
                          "Organisateur",
                          "Membre RabatLink",
                        ),
                        
                        const Divider(height: 40),

                        // Description
                        const Text(
                          "À propos de cet événement",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          eventData['description'] ?? 'Aucune description disponible.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100), // Espace pour le bouton flottant
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bouton d'action en bas
      bottomNavigationBar: !isOwner && !isAdmin
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () => _showInterestDialog(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    "JE SUIS INTÉRESSÉ(E)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : isAdmin && !isOwner
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAdminDeleteDialog(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text(
                        "SUPPRIMER (ADMIN)",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInterestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.thumb_up, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text("Super !", style: TextStyle(fontSize: 20)),
          ],
        ),
        content: const Text(
          "Votre intérêt a été enregistré ! L'organisateur sera notifié.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showAdminDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text("Suppression Admin", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          "En tant qu'administrateur, vous allez supprimer cet événement de manière permanente.\n\nCette action est irréversible.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
              if (context.mounted) {
                Navigator.pop(context); // Ferme le dialog
                Navigator.pop(context); // Retourne à la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Événement supprimé par l'admin")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}