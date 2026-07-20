import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../utils/csv_import.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _importing = false;
  String _status = '';

  Future<void> _pickAndImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        setState(() => _status = 'Could not read file data.');
        return;
      }

      setState(() {
        _importing = true;
        _status = 'Importing...';
      });

      final importResult = await importCsvFromBytes(Uint8List.fromList(bytes));

      setState(() {
        _importing = false;
        if (importResult.errors.isEmpty) {
          _status = 'Imported ${importResult.imported} medicines successfully.';
        } else {
          _status = 'Imported ${importResult.imported}. Errors:\n${importResult.errors.join('\n')}';
        }
      });
    } catch (e) {
      setState(() {
        _importing = false;
        _status = 'Import failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Medicines')),
      body: Padding(
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
                    const Text(
                      'Import CSV / TXT file',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'First row must contain headers. Supported columns: brand_name, generic_name, formula, strength, manufacturer, category, cabinet, rack, drawer, shelf, box, quantity, notes.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _importing ? null : _pickAndImport,
                        icon: _importing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_importing ? 'Importing...' : 'Select File'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_status.isNotEmpty)
              Card(
                color: _status.contains('failed') || _status.contains('Errors')
                    ? Colors.red[50]
                    : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_status),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
