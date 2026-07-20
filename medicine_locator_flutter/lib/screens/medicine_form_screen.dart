import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/medicine.dart';

class MedicineFormScreen extends StatefulWidget {
  final Medicine? medicine;
  const MedicineFormScreen({super.key, this.medicine});

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _genericController = TextEditingController();
  final _formulaController = TextEditingController();
  final _strengthController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _cabinetController = TextEditingController();
  final _rackController = TextEditingController();
  final _drawerController = TextEditingController();
  final _shelfController = TextEditingController();
  final _boxController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<Category> _categories = [];
  int? _categoryId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper().getCategories();
    setState(() {
      _categories = categories;
      _loading = false;
    });

    if (widget.medicine != null) {
      final m = widget.medicine!;
      _brandController.text = m.brandName ?? '';
      _genericController.text = m.genericName ?? '';
      _formulaController.text = m.formula ?? '';
      _strengthController.text = m.strength ?? '';
      _manufacturerController.text = m.manufacturer ?? '';
      _cabinetController.text = m.cabinet ?? '';
      _rackController.text = m.rack ?? '';
      _drawerController.text = m.drawer ?? '';
      _shelfController.text = m.shelf ?? '';
      _boxController.text = m.box ?? '';
      _quantityController.text = m.quantity.toString();
      _notesController.text = m.notes ?? '';
      _categoryId = m.categoryId;
    } else {
      _quantityController.text = '0';
    }
  }

  Future<void> _applyCategoryDefaults() async {
    if (_categoryId == null) return;
    final category = _categories.where((c) => c.id == _categoryId).firstOrNull;
    if (category == null) return;

    final controllers = {
      'cabinet': _cabinetController,
      'rack': _rackController,
      'drawer': _drawerController,
      'shelf': _shelfController,
      'box': _boxController,
    };

    setState(() {
      if (_cabinetController.text.isEmpty && category.cabinet != null) {
        _cabinetController.text = category.cabinet!;
      }
      if (_rackController.text.isEmpty && category.rack != null) {
        _rackController.text = category.rack!;
      }
      if (_drawerController.text.isEmpty && category.drawer != null) {
        _drawerController.text = category.drawer!;
      }
      if (_shelfController.text.isEmpty && category.shelf != null) {
        _shelfController.text = category.shelf!;
      }
      if (_boxController.text.isEmpty && category.box != null) {
        _boxController.text = category.box!;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final medicine = Medicine(
      id: widget.medicine?.id,
      brandName: _brandController.text.isEmpty ? null : _brandController.text,
      genericName: _genericController.text.isEmpty ? null : _genericController.text,
      formula: _formulaController.text.isEmpty ? null : _formulaController.text,
      strength: _strengthController.text.isEmpty ? null : _strengthController.text,
      manufacturer: _manufacturerController.text.isEmpty ? null : _manufacturerController.text,
      categoryId: _categoryId,
      cabinet: _cabinetController.text.isEmpty ? null : _cabinetController.text,
      rack: _rackController.text.isEmpty ? null : _rackController.text,
      drawer: _drawerController.text.isEmpty ? null : _drawerController.text,
      shelf: _shelfController.text.isEmpty ? null : _shelfController.text,
      box: _boxController.text.isEmpty ? null : _boxController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (widget.medicine == null) {
      await DatabaseHelper().insertMedicine(medicine);
    } else {
      await DatabaseHelper().updateMedicine(medicine);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Brand Name', _brandController),
                    _buildTextField('Generic Name', _genericController),
                    _buildTextField('Formula', _formulaController),
                    _buildTextField('Strength', _strengthController),
                    _buildTextField('Manufacturer', _manufacturerController),
                    DropdownButtonFormField<int?>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Uncategorized')),
                        ..._categories.map(
                          (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _categoryId = value);
                        _applyCategoryDefaults();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Storage Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text('Leave blank to inherit from category', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField('Cabinet', _cabinetController),
                    _buildTextField('Rack', _rackController),
                    _buildTextField('Drawer', _drawerController),
                    _buildTextField('Shelf', _shelfController),
                    _buildTextField('Box', _boxController),
                    _buildTextField('Quantity', _quantityController, hint: '0'),
                    _buildTextField('Notes', _notesController, maxLines: 4),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save Medicine'),
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
    _brandController.dispose();
    _genericController.dispose();
    _formulaController.dispose();
    _strengthController.dispose();
    _manufacturerController.dispose();
    _cabinetController.dispose();
    _rackController.dispose();
    _drawerController.dispose();
    _shelfController.dispose();
    _boxController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
