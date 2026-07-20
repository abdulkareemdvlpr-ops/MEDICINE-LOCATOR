import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicine_locator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            cabinet TEXT,
            rack TEXT,
            drawer TEXT,
            shelf TEXT,
            box TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE medicines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand_name TEXT,
            generic_name TEXT,
            formula TEXT,
            strength TEXT,
            manufacturer TEXT,
            category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
            cabinet TEXT,
            rack TEXT,
            drawer TEXT,
            shelf TEXT,
            box TEXT,
            quantity INTEGER DEFAULT 0,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // Categories

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    await db.delete('medicines', where: 'category_id = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategories(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final db = await database;
    final placeholders = ids.map((_) => '?').join(', ');
    await db.delete('medicines', where: 'category_id IN ($placeholders)', whereArgs: ids);
    return await db.delete('categories', where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<Category?> getCategory(int id) async {
    final db = await database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<void> updateMedicinesLocationByCategory(int categoryId) async {
    final category = await getCategory(categoryId);
    if (category == null) return;
    final db = await database;
    await db.update(
      'medicines',
      {
        'cabinet': category.cabinet,
        'rack': category.rack,
        'drawer': category.drawer,
        'shelf': category.shelf,
        'box': category.box,
      },
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Medicines

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMedicines(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final db = await database;
    final placeholders = ids.map((_) => '?').join(', ');
    return await db.delete('medicines', where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<List<Medicine>> getMedicines({String? search, int? categoryId}) async {
    final db = await database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.trim().isNotEmpty) {
      where.add(
        '(brand_name LIKE ? OR generic_name LIKE ? OR formula LIKE ?)',
      );
      final like = '%${search.trim()}%';
      whereArgs.addAll([like, like, like]);
    }

    if (categoryId != null) {
      if (categoryId == 0) {
        where.add('category_id IS NULL');
      } else {
        where.add('category_id = ?');
        whereArgs.add(categoryId);
      }
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final maps = await db.rawQuery('''
      SELECT m.*, c.name AS category_name
      FROM medicines m
      LEFT JOIN categories c ON c.id = m.category_id
      $whereSql
      ORDER BY m.id DESC
    ''', whereArgs);

    return maps.map((m) => Medicine.fromMap(m)).toList();
  }

  Future<Medicine?> getMedicine(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT m.*, c.name AS category_name
      FROM medicines m
      LEFT JOIN categories c ON c.id = m.category_id
      WHERE m.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return Medicine.fromMap(maps.first);
  }

  // Dashboard stats

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final totalMedicines = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM medicines'),
    ) ?? 0;

    final totalCategories = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    ) ?? 0;

    final totalQuantity = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COALESCE(SUM(quantity), 0) FROM medicines'),
    ) ?? 0;

    final totalBrands = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(DISTINCT manufacturer)
        FROM medicines
        WHERE manufacturer IS NOT NULL AND manufacturer <> ''
      '''),
    ) ?? 0;

    final categoryCounts = await db.rawQuery('''
      SELECT c.id, c.name, COUNT(m.id) AS medicine_count
      FROM categories c
      LEFT JOIN medicines m ON m.category_id = c.id
      GROUP BY c.id, c.name
      ORDER BY c.name ASC
    ''');

    final cabinetCounts = await db.rawQuery('''
      SELECT cabinet, COUNT(*) AS count
      FROM medicines
      WHERE cabinet IS NOT NULL AND cabinet <> ''
      GROUP BY cabinet
      ORDER BY cabinet ASC
    ''');

    return {
      'totalMedicines': totalMedicines,
      'totalCategories': totalCategories,
      'totalQuantity': totalQuantity,
      'totalBrands': totalBrands,
      'categoryCounts': categoryCounts,
      'cabinetCounts': cabinetCounts,
    };
  }
}
