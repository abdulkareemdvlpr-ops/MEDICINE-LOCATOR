import 'dart:convert';
import 'package:csv/csv.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/medicine.dart';

class ImportResult {
  final int imported;
  final List<String> errors;
  ImportResult({required this.imported, required this.errors});
}

Future<ImportResult> importCsvFromString(String csvText) async {
  final helper = DatabaseHelper();
  final rows = const CsvToListConverter().convert(csvText, eol: '\n');

  if (rows.isEmpty) {
    return ImportResult(imported: 0, errors: ['File is empty']);
  }

  final rawHeaders = rows.first.map((h) => h.toString()).toList();
  final headers = rawHeaders.map((h) => h.toLowerCase().trim().replaceAll(' ', '_')).toList();

  final imported = <int>{};
  final errors = <String>[];

  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
      continue;
    }

    Map<String, String> getValue(String key) {
      final idx = headers.indexOf(key);
      if (idx == -1 || idx >= row.length) return '';
      return row[idx].toString().trim();
    }

    String firstPresent(List<String> keys) {
      for (final k in keys) {
        final v = getValue(k);
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    try {
      final categoryName = getValue('category').isNotEmpty
          ? getValue('category')
          : getValue('category_name');
      int? categoryId;
      if (categoryName.isNotEmpty) {
        final existing = (await helper.getCategories())
            .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
            .firstOrNull;
        if (existing != null) {
          categoryId = existing.id;
        } else {
          categoryId = await helper.insertCategory(
            Category(name: categoryName),
          );
        }
      }

      final brandName = firstPresent(['brand_name', 'brand']);
      final genericName = firstPresent(['generic_name', 'generic']);
      final formula = getValue('formula');
      final strength = getValue('strength');
      final manufacturer = firstPresent(['manufacturer', 'brand_name', 'brand']);
      final notes = getValue('notes');
      final quantityText = getValue('quantity');
      final quantity = int.tryParse(quantityText) ?? 0;

      final medicine = Medicine(
        brandName: brandName.isEmpty ? null : brandName,
        genericName: genericName.isEmpty ? null : genericName,
        formula: formula.isEmpty ? null : formula,
        strength: strength.isEmpty ? null : strength,
        manufacturer: manufacturer.isEmpty ? null : manufacturer,
        categoryId: categoryId,
        cabinet: getValue('cabinet').isEmpty ? null : getValue('cabinet'),
        rack: getValue('rack').isEmpty ? null : getValue('rack'),
        drawer: getValue('drawer').isEmpty ? null : getValue('drawer'),
        shelf: getValue('shelf').isEmpty ? null : getValue('shelf'),
        box: getValue('box').isEmpty ? null : getValue('box'),
        quantity: quantity,
        notes: notes.isEmpty ? null : notes,
      );

      await helper.insertMedicine(medicine);
      imported.add(i);
    } catch (e) {
      errors.add('Row ${i + 1}: $e');
    }
  }

  return ImportResult(imported: imported.length, errors: errors.take(5).toList());
}

Future<ImportResult> importCsvFromBytes(List<int> bytes) async {
  final text = utf8.decode(bytes, allowMalformed: true);
  return importCsvFromString(text);
}
