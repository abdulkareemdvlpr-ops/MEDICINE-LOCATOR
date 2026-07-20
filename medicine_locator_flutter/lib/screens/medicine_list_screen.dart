import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/medicine.dart';
import 'medicine_form_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<Medicine> _medicines = [];
  List<Category> _categories = [];
  final Set<int> _selectedIds = {};
  String _search = '';
  int? _categoryFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final medicines = await DatabaseHelper().getMedicines(
      search: _search.isEmpty ? null : _search,
      categoryId: _categoryFilter,
    );
    final categories = await DatabaseHelper().getCategories();
    setState(() {
      _medicines = medicines;
      _categories = categories;
      _loading = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected?'),
        content: Text('Delete ${_selectedIds.length} medicines?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper().deleteMedicines(_selectedIds.toList());
      _loadData();
    }
  }

  void _openForm([Medicine? medicine]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicineFormScreen(medicine: medicine)),
    );
    _loadData();
  }

  void _openDetail(Medicine medicine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicine: medicine)),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
              tooltip: 'Delete selected',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
            tooltip: 'Add medicine',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search brand, generic, formula...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _search = value;
                    _loadData();
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  value: _categoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All categories')),
                    const DropdownMenuItem(value: 0, child: Text('Uncategorized')),
                    ..._categories.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (value) {
                    _categoryFilter = value;
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _medicines.isEmpty
                    ? const Center(child: Text('No medicines found'))
                    : ListView.builder(
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final m = _medicines[index];
                          final selected = _selectedIds.contains(m.id);
                          return ListTile(
                            leading: Checkbox(
                              value: selected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedIds.add(m.id!);
                                  } else {
                                    _selectedIds.remove(m.id);
                                  }
                                });
                              },
                            ),
                            title: Text(m.displayName()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.genericName != null && m.genericName!.isNotEmpty)
                                  Text('Generic: ${m.genericName}'),
                                if (m.categoryName != null)
                                  Text('Category: ${m.categoryName}'),
                                Text('Qty: ${m.quantity}  •  ${m.locationSummary()}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openDetail(m),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
