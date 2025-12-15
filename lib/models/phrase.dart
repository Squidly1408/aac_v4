class Phrase {
  final String id;
  String text;
  bool pinned;
  int sortOrder;

  Phrase({
    required this.id,
    required this.text,
    required this.pinned,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'pinned': pinned,
        'sortOrder': sortOrder,
      };

  static Phrase fromJson(Map<String, dynamic> json) => Phrase(
        id: json['id'] as String,
        text: json['text'] as String,
        pinned: (json['pinned'] as bool?) ?? false,
        sortOrder: (json['sortOrder'] as num).toInt(),
      );
}
