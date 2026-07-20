import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'medicine_list_screen.dart';
import 'category_list_screen.dart';
import 'medicine_form_screen.dart';
import 'category_form_screen.dart';
import 'import_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseHelper().getDashboardStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  void _navigate(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Locator'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Medicines by Category'),
                    _buildCategoryList(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Medicines by Cabinet'),
                    _buildCabinetList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigate(const MedicineFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Medicine'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              _loadStats();
              break;
            case 1:
              _navigate(const MedicineListScreen());
              break;
            case 2:
              _navigate(const CategoryListScreen());
              break;
            case 3:
              _navigate(const ImportScreen());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medicines'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Import'),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = [
      {'label': 'Medicines', 'value': _stats?['totalMedicines'] ?? 0},
      {'label': 'Categories', 'value': _stats?['totalCategories'] ?? 0},
      {'label': 'Quantity', 'value': _stats?['totalQuantity'] ?? 0},
      {'label': 'Manufacturers', 'value': _stats?['totalBrands'] ?? 0},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['value'].toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoryList() {
    final counts = (_stats?['categoryCounts'] as List<dynamic>?) ?? [];
    if (counts.isEmpty) {
      return const Card(
        child: ListTile(
          title: Text('No categories yet'),
          subtitle: Text('Add categories to organize your medicines'),
        ),
      );
    }
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: counts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final row = counts[index] as Map<String, dynamic>;
          return ListTile(
            title: Text(row['name'] as String? ?? ''),
            trailing: Text(
              '${row['medicine_count'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCabinetList() {
    final counts = (_stats?['cabinetCounts'] as List<dynamic>?) ?? [];
    if (counts.isEmpty) {
      return const Card(
        child: ListTile(
          title: Text('No cabinet data yet'),
        ),
      );
    }
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: counts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final row = counts[index] as Map<String, dynamic>;
          return ListTile(
            title: Text(row['cabinet'] as String? ?? ''),
            trailing: Text(
              '${row['count'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
