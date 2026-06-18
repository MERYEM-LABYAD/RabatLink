import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabatlink/core/app_colors.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventScreen({
    super.key, 
    required this.eventId, 
    required this.eventData
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  
  DateTime? _selectedDate;
  String _selectedCategory = 'Loisirs';
  bool _isLoading = false;

  final List<String> _categories = ['Loisirs', 'Sport', 'Culture', 'Formation', 'Social'];

  @override
  void initState() {
    super.initState();
    // Pré-remplissage des champs avec les données reçues
    _titleController = TextEditingController(text: widget.eventData['title']);
    _descriptionController = TextEditingController(text: widget.eventData['description']);
    _locationController = TextEditingController(text: widget.eventData['location']);
    _imageUrlController = TextEditingController(text: widget.eventData['imageUrl']);
    _selectedCategory = widget.eventData['category'] ?? 'Loisirs';
    _selectedDate = (widget.eventData['date'] as Timestamp).toDate();
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'date': Timestamp.fromDate(_selectedDate!),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement mis à jour !")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier l'événement")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Titre"),
                  TextFormField(controller: _titleController, decoration: const InputDecoration()),
                  const SizedBox(height: 20),
                  
                  _buildLabel("Catégorie"),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Lieu"),
                  TextFormField(controller: _locationController, decoration: const InputDecoration()),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateEvent,
                      child: const Text("ENREGISTRER LES MODIFICATIONS"),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary));
  }
}