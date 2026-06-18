import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedCategory = 'Loisirs';
  bool _isLoading = false;

  final List<String> _categories = ['Loisirs', 'Sport', 'Culture', 'Formation', 'Social'];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs et choisir une date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'date': Timestamp.fromDate(_selectedDate!),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement publié avec succès !")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un événement")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Titre de l'événement"),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: "Ex: Match de Foot à l'Agdal"),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Catégorie"),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Date"),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedDate == null 
                            ? "Choisir une date" 
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Lieu"),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: "Ex: Café France, Rabat"),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Lien de l'image (URL)"),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(hintText: "https://..."),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Description"),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: "Détails de l'événement..."),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      child: const Text("PUBLIER L'ÉVÉNEMENT"),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }
}