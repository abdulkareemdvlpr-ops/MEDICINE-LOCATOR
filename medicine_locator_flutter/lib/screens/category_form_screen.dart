import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cabinetController = TextEditingController();
  final _rackController = TextEditingController();
  final _drawerController = TextEditingController();
  final _shelfController = TextEditingController();
  final _boxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      final c = widget.category!;
      _nameController.text = c.name;
      _descriptionController.text = c.description ?? '';
      _cabinetController.text = c.cabinet ?? '';
      _rackController.text = c.rack ?? '';
      _drawerController.text = c.drawer ?? '';
      _shelfController.text = c.shelf ?? '';
      _boxController.text = c.box ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text.trim(),
      cabinet: _cabinetController.text.isEmpty ? null : _cabinetController.text.trim(),
      rack: _rackController.text.isEmpty ? null : _rackController.text.trim(),
      drawer: _drawerController.text.isEmpty ? null : _drawerController.text.trim(),
      shelf: _shelfController.text.isEmpty ? null : _shelfController.text.trim(),
      box: _boxController.text.isEmpty ? null : _boxController.text.trim(),
    );

    final helper = DatabaseHelper();
    if (widget.category == null) {
      await helper.insertCategory(category);
    } else {
      await helper.updateCategory(category);
      await helper.updateMedicinesLocationByCategory(category.id!);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField('Description', _descriptionController, maxLines: 3),
              const SizedBox(height: 8),
              Text(
                'Default Storage Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Text('Medicines in this category inherit these when left blank.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              _buildTextField('Cabinet', _cabinetController),
              _buildTextField('Rack', _rackController),
              _buildTextField('Drawer', _drawerController),
              _buildTextField('Shelf', _shelfController),
              _buildTextField('Box', _boxController),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cabinetController.dispose();
    _rackController.dispose();
    _drawerController.dispose();
    _shelfController.dispose();
    _boxController.dispose();
    super.dispose();
  }
}
