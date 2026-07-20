class Category {
  final int? id;
  final String name;
  final String? description;
  final String? cabinet;
  final String? rack;
  final String? drawer;
  final String? shelf;
  final String? box;

  Category({
    this.id,
    required this.name,
    this.description,
    this.cabinet,
    this.rack,
    this.drawer,
    this.shelf,
    this.box,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cabinet': cabinet,
      'rack': rack,
      'drawer': drawer,
      'shelf': shelf,
      'box': box,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      cabinet: map['cabinet'] as String?,
      rack: map['rack'] as String?,
      drawer: map['drawer'] as String?,
      shelf: map['shelf'] as String?,
      box: map['box'] as String?,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? cabinet,
    String? rack,
    String? drawer,
    String? shelf,
    String? box,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cabinet: cabinet ?? this.cabinet,
      rack: rack ?? this.rack,
      drawer: drawer ?? this.drawer,
      shelf: shelf ?? this.shelf,
      box: box ?? this.box,
    );
  }
}
