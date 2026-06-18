import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String selectedCategory = 'Tous';
  String userRole = 'user';
  bool isLoadingRole = true;

  final List<String> categories = [
    'Tous',
    'Électronique',
    'Vêtements',
    'Maison',
    'Sport',
    'Livres',
    'Autres'
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted && doc.exists) {
          setState(() {
            userRole = doc.data()?['role'] ?? 'user';
            isLoadingRole = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoadingRole = false);
      }
    } else {
      if (mounted) setState(() => isLoadingRole = false);
    }
  }

  Stream<QuerySnapshot> _getProductsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (userRole == 'vendeur') {
      if (selectedCategory == 'Tous') {
        return FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: user?.uid)
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: user?.uid)
            .where('category', isEqualTo: selectedCategory)
            .snapshots();
      }
    } else {
      if (selectedCategory == 'Tous') {
        return FirebaseFirestore.instance.collection('products').snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: selectedCategory)
            .snapshots();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadingRole
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Container(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Marketplace',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Découvrez les produits locaux',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (userRole == 'vendeur')
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondary,
                                    AppColors.secondary.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add,
                                    color: AppColors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddProductScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Catégories
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == selectedCategory;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedCategory = category),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary
                                              .withValues(alpha: 0.8),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : AppColors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Liste des produits
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _getProductsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 60,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun produit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final products = snapshot.data!.docs;

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index].data()
                                  as Map<String, dynamic>;
                              final productId = products[index].id;

                              return _buildProductCard(
                                context,
                                productId,
                                product,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productId,
    Map<String, dynamic> product,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              productId: productId,
              productData: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: product['imageUrl'] != null &&
                      product['imageUrl'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        product['imageUrl'],
                        width: double.infinity,
fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.grey.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
            ),

            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Sans nom',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['description'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product['price'] ?? 0} DH',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product['category'] ?? '',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}