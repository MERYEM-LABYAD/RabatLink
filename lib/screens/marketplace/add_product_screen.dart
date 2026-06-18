import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');

  String selectedCategory = 'Électronique';
  bool isLoading = false;

  final List<String> categories = [
    'Électronique',
    'Vêtements',
    'Maison',
    'Sport',
    'Livres',
    'Autres'
  ];

  @override
  void dispose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    imageUrlCtrl.dispose();
    quantityCtrl.dispose();
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
                    const Expanded(
                      child: Text(
                        'Ajouter un produit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.secondary.withValues(alpha: 0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 50,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Nom du produit
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.shopping_bag_outlined,
                                color: AppColors.primary),
                            labelText: "Nom du produit",
                            hintText: "Ex: iPhone 13",
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Nom requis" : null,
                        ),
                        const SizedBox(height: 16),

                        // Quantité
                        TextFormField(
                          controller: quantityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.inventory_2_outlined,
                                color: AppColors.primary),
                            labelText: "Quantité en stock",
                            hintText: "Ex: 10",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Quantité requise";
                            if (int.tryParse(v) == null) return "Quantité invalide";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descriptionCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.description_outlined,
                                color: AppColors.primary),
                            labelText: "Description",
                            hintText: "Décrivez votre produit...",
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? "Description requise"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Prix
                        TextFormField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.attach_money,
                                color: AppColors.primary),
                            labelText: "Prix (DH)",
                            hintText: "Ex: 5000",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Prix requis";
                            if (double.tryParse(v) == null) {
                              return "Prix invalide";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Catégorie
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category_outlined,
                                color: AppColors.primary),
                            labelText: "Catégorie",
                          ),
                          value: selectedCategory,
                          items: categories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedCategory = value!),
                        ),
                        const SizedBox(height: 16),

                        // URL de l'image
                        TextFormField(
                          controller: imageUrlCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.image_outlined,
                                color: AppColors.primary),
                            hintText: "Image",
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Bouton Ajouter
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _addProduct,
                            icon: isLoading
                                ? const SizedBox()
                                : const Icon(Icons.add),
                            label: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("Ajouter le produit"),
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

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("Non connecté");

        await FirebaseFirestore.instance.collection('products').add({
          'name': nameCtrl.text.trim(),
          'description': descriptionCtrl.text.trim(),
          'price': double.parse(priceCtrl.text.trim()),
          'quantity': int.parse(quantityCtrl.text.trim()),
          'category': selectedCategory,
          'imageUrl': imageUrlCtrl.text.trim(),
          'sellerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Produit ajouté avec succès !")),
              ],
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Erreur: ${e.toString()}")),
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