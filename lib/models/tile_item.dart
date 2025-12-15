class TileItem {
  final String id;
  final String categoryId;

  String label;
  String speakText;
  bool isFavourite;
  int sortOrder;

  TileItem({
    required this.id,
    required this.categoryId,
    required this.label,
    required this.speakText,
    required this.isFavourite,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'label': label,
        'speakText': speakText,
        'isFavourite': isFavourite,
        'sortOrder': sortOrder,
      };

  static TileItem fromJson(Map<String, dynamic> json) => TileItem(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        label: json['label'] as String,
        speakText: json['speakText'] as String,
        isFavourite: (json['isFavourite'] as bool?) ?? false,
        sortOrder: (json['sortOrder'] as num).toInt(),
      );
}
