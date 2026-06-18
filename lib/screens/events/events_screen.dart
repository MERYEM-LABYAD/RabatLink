import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';
import 'add_event_screen.dart';
import 'edit_event_screen.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header stylisé
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Événements',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Découvrez Rabat ensemble',
                          style: TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Liste temps réel
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .orderBy('date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var event = doc.data() as Map<String, dynamic>;
                        return _buildEventCard(context, event, doc.id, currentUserId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEventScreen()),
        ),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event, String eventId, String? currentUserId) {
    // Vérification de propriété
    final bool isOwner = event['createdBy'] == currentUserId;

    // Gestion de la date
    DateTime? eventDate = (event['date'] as Timestamp?)?.toDate();
    String formattedDate = eventDate != null 
        ? DateFormat('dd MMM yyyy').format(eventDate) 
        : "À venir";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventId: eventId,
              eventData: event,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image et Badge Catégorie
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    event['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160, 
                      color: AppColors.lightGreen.withValues(alpha: 0.2),
                      child: const Icon(Icons.image, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['category'] ?? 'Général',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Détails et Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['title'] ?? 'Sans titre',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      if (isOwner)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEventScreen(
                                      eventId: eventId,
                                      eventData: event,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(context, eventId),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                      const SizedBox(width: 8),
                      Text(formattedDate, style: const TextStyle(color: AppColors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(event['location'] ?? 'Rabat', style: const TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Supprimer ?"),
        content: const Text("Voulez-vous vraiment retirer cet événement de RabatLink ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Supprimer"),
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
          Icon(Icons.event_note, size: 64, color: AppColors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("Aucun événement à afficher", style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}