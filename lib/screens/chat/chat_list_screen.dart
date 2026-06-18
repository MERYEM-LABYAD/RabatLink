import 'package:flutter/material.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'chat_room_screen.dart';
import 'chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final List<String> quartiers;

  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.quartiers,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();
      
      if (mounted) {
        setState(() {
          isAdmin = doc.data()?['role'] == 'admin';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.red, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'MODE ADMIN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAdmin 
                          ? 'Chats publics uniquement'
                          : 'Restez connecté avec votre quartier',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des chats
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Section Chat Public
                    _buildSectionHeader(
                      'Chats de quartier',
                      Icons.public,
                      AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    
                    // LES 4 QUARTIERS
                    _buildPublicChatCard(context, 'Agdal'),
                    _buildPublicChatCard(context, 'Hay Riad'),
                    _buildPublicChatCard(context, 'Souissi'),
                    _buildPublicChatCard(context, 'Hassan'),
                    
                    const SizedBox(height: 24),

                    // Section Chat Privé (SEULEMENT SI PAS ADMIN)
                    if (!isAdmin) ...[
                      _buildSectionHeader(
                        'Messages privés',
                        Icons.lock_outline,
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: ChatService().getUserProductChats(widget.currentUserId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Aucune conversation',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          final chats = snapshot.data!.docs;
                          return Column(
                            children: chats.map((doc) {
                              final chat = doc.data() as Map<String, dynamic>;
                              
                              // ✅ CORRECTION: Vérifier que participants existe et n'est pas vide
                              final participants = chat['participants'] as List?;
                              if (participants == null || participants.isEmpty) {
                                return const SizedBox.shrink(); // Ignore ce chat
                              }

                              // ✅ Trouver l'autre utilisateur en toute sécurité
                              String? otherUserId;
                              try {
                                otherUserId = participants.firstWhere(
                                  (id) => id != widget.currentUserId,
                                  orElse: () => null,
                                );
                              } catch (e) {
                                return const SizedBox.shrink();
                              }

                              // ✅ Si otherUserId est null ou vide, ignorer
                              if (otherUserId == null || otherUserId.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return _buildProductChatCard(
                                context,
                                chat['productName'] ?? 'Produit',
                                otherUserId,
                                chat['productId'] ?? '',
                                chat['lastMessage'] ?? '',
                                chat['productImage'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductChatCard(
    BuildContext context,
    String productName,
    String otherUserId,
    String productId,
    String lastMessage,
    String? productImage,
  ) {
    // ✅ Double vérification de sécurité
    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        String displayName = 'Utilisateur';
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            displayName = userData['username'] ?? userData['name'] ?? 'Utilisateur';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      currentUserId: widget.currentUserId,
                      isPublic: false,
                      targetId: otherUserId,
                      productId: productId,
                      productName: productName,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: productImage != null && productImage.isNotEmpty
                          ? Image.network(
                              productImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                                  child: const Icon(Icons.shopping_bag, size: 24, color: AppColors.primary),
                                );
                              },
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: AppColors.lightGreen.withValues(alpha: 0.3),
                              child: const Icon(Icons.shopping_bag, size: 24, color: AppColors.primary),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage.isNotEmpty ? lastMessage : 'Concernant: $productName',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicChatCard(BuildContext context, String quartier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  currentUserId: widget.currentUserId,
                  isPublic: true,
                  targetId: quartier,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quartier,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat de quartier',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}