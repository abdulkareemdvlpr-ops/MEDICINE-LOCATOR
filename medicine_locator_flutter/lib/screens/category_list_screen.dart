import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> _categories = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final categories = await DatabaseHelper().getCategories();
    setState(() {
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
        content: Text('Delete ${_selectedIds.length} categories and their medicines?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper().deleteCategories(_selectedIds.toList());
      _loadData();
    }
  }

  void _openForm([Category? category]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormScreen(category: category)),
    );
    _loadData();
  }

  String _locationSummary(Category c) {
    final parts = [c.cabinet, c.rack, c.drawer, c.shelf, c.box]
        .where((p) => p != null && p!.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'No default location' : parts.join(' → ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
            tooltip: 'Add category',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories yet'))
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final c = _categories[index];
                    final selected = _selectedIds.contains(c.id);
                    return ListTile(
                      leading: Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(c.id!);
                            } else {
                              _selectedIds.remove(c.id);
                            }
                          });
                        },
                      ),
                      title: Text(c.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c.description != null && c.description!.isNotEmpty)
                            Text(c.description!),
                          Text(_locationSummary(c)),
                        ],
                      ),
                      isThreeLine: c.description != null && c.description!.isNotEmpty,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openForm(c),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
