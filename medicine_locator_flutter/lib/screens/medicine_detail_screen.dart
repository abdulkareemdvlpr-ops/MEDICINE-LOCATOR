import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicine.dart';
import 'medicine_form_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  Medicine? _medicine;

  @override
  void initState() {
    super.initState();
    _loadMedicine();
  }

  Future<void> _loadMedicine() async {
    final m = await DatabaseHelper().getMedicine(widget.medicine.id!);
    if (m != null) setState(() => _medicine = m);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete medicine?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper().deleteMedicine(widget.medicine.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicineFormScreen(medicine: _medicine ?? widget.medicine)),
    );
    _loadMedicine();
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _medicine ?? widget.medicine;
    return Scaffold(
      appBar: AppBar(
        title: Text(m.displayName()),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile('Brand Name', m.brandName ?? '-'),
                    _buildInfoTile('Generic Name', m.genericName ?? '-'),
                    _buildInfoTile('Formula', m.formula ?? '-'),
                    _buildInfoTile('Strength', m.strength ?? '-'),
                    _buildInfoTile('Manufacturer', m.manufacturer ?? '-'),
                    _buildInfoTile('Category', m.categoryName ?? 'Uncategorized'),
                    _buildInfoTile('Quantity', m.quantity.toString()),
                    _buildInfoTile('Storage Location', m.locationSummary()),
                    _buildInfoTile('Notes', m.notes ?? '-'),
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
