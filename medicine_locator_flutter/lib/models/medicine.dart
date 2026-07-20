class Medicine {
  final int? id;
  final String? brandName;
  final String? genericName;
  final String? formula;
  final String? strength;
  final String? manufacturer;
  final int? categoryId;
  final String? categoryName;
  final String? cabinet;
  final String? rack;
  final String? drawer;
  final String? shelf;
  final String? box;
  final int quantity;
  final String? notes;

  Medicine({
    this.id,
    this.brandName,
    this.genericName,
    this.formula,
    this.strength,
    this.manufacturer,
    this.categoryId,
    this.categoryName,
    this.cabinet,
    this.rack,
    this.drawer,
    this.shelf,
    this.box,
    this.quantity = 0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand_name': brandName,
      'generic_name': genericName,
      'formula': formula,
      'strength': strength,
      'manufacturer': manufacturer,
      'category_id': categoryId,
      'cabinet': cabinet,
      'rack': rack,
      'drawer': drawer,
      'shelf': shelf,
      'box': box,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as int?,
      brandName: map['brand_name'] as String?,
      genericName: map['generic_name'] as String?,
      formula: map['formula'] as String?,
      strength: map['strength'] as String?,
      manufacturer: map['manufacturer'] as String?,
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String?,
      cabinet: map['cabinet'] as String?,
      rack: map['rack'] as String?,
      drawer: map['drawer'] as String?,
      shelf: map['shelf'] as String?,
      box: map['box'] as String?,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
    );
  }

  Medicine copyWith({
    int? id,
    String? brandName,
    String? genericName,
    String? formula,
    String? strength,
    String? manufacturer,
    int? categoryId,
    String? categoryName,
    String? cabinet,
    String? rack,
    String? drawer,
    String? shelf,
    String? box,
    int? quantity,
    String? notes,
  }) {
    return Medicine(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      genericName: genericName ?? this.genericName,
      formula: formula ?? this.formula,
      strength: strength ?? this.strength,
      manufacturer: manufacturer ?? this.manufacturer,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      cabinet: cabinet ?? this.cabinet,
      rack: rack ?? this.rack,
      drawer: drawer ?? this.drawer,
      shelf: shelf ?? this.shelf,
      box: box ?? this.box,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  String displayName() {
    return brandName ?? genericName ?? formula ?? 'Unnamed Medicine';
  }

  String locationSummary() {
    final parts = [cabinet, rack, drawer, shelf, box].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? 'No location' : parts.join(' → ');
  }
}
