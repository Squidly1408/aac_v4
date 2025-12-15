class Category {
  final String id;
  String name;
  int sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sortOrder': sortOrder,
      };

  static Category fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        sortOrder: (json['sortOrder'] as num).toInt(),
      );
}
