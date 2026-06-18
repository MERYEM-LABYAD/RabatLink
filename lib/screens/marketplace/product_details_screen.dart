import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:rabatlink/screens/chat/product_chat_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // ✅ CORRECTION: Vérifier sellerId dans productData
    final sellerId = productData['sellerId'] ?? productData['ownerId'] ?? '';
    final bool isOwner = sellerId == currentUserId;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        bool isAdmin = false;
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          isAdmin = (userSnapshot.data!.data() as Map)['role'] == 'admin';
        }
        
        return _buildContent(context, isOwner, isAdmin, currentUserId, sellerId);
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isOwner, bool isAdmin, String? currentUserId, String sellerId) {
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
                  // Image du produit
                  Image.network(
                    productData['imageUrl'] ?? 'https://via.placeholder.com/600x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.lightGreen.withValues(alpha: 0.3),
                      child: const Icon(Icons.shopping_bag, size: 80, color: AppColors.primary),
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
                        productData['category'] ?? 'Général',
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
                  // Prix et Titre
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                productData['name'] ?? productData['title'] ?? 'Sans titre',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${productData['price'] ?? '0'} DH',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Informations vendeur
                        FutureBuilder<DocumentSnapshot>(
                          future: sellerId.isNotEmpty 
                              ? FirebaseFirestore.instance.collection('users').doc(sellerId).get()
                              : null,
                          builder: (context, snapshot) {
                            String sellerName = 'Vendeur';
                            String sellerQuartier = productData['quartier'] ?? 'Rabat';
                            
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final sellerData = snapshot.data!.data() as Map<String, dynamic>;
                              sellerName = sellerData['username'] ?? sellerData['name'] ?? 'Vendeur';
                            }

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      sellerName.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Vendu par',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        Text(
                                          sellerName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              sellerQuartier,
                                              style: const TextStyle(fontSize: 13, color: AppColors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        const Divider(height: 40),

                        // Description
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          productData['description'] ?? 'Aucune description disponible.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Boutons d'action
      bottomNavigationBar: isAdmin && !isOwner
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
          : !isOwner && currentUserId != null && sellerId.isNotEmpty
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
                      onPressed: () {
                        // ✅ DEBUG: Afficher les valeurs
                        print('🔍 currentUserId: $currentUserId');
                        print('🔍 sellerId: $sellerId');
                        print('🔍 productId: $productId');
                        print('🔍 productName: ${productData['name'] ?? productData['title']}');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductChatScreen(
                              currentUserId: currentUserId,
                              sellerId: sellerId,
                              productId: productId,
                              productName: productData['name'] ?? productData['title'] ?? 'Produit',
                              productImage: productData['imageUrl'] ?? '',
                              productPrice: (productData['price'] ?? 0).toDouble(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        "CONTACTER LE VENDEUR",
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
              : sellerId.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vendeur inconnu - Produit corrompu',
                                  style: TextStyle(color: Colors.orange.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
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
          "En tant qu'administrateur, vous allez supprimer ce produit de manière permanente.\n\nCette action est irréversible.",
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
              await FirebaseFirestore.instance.collection('products').doc(productId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produit supprimé par l'admin")),
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