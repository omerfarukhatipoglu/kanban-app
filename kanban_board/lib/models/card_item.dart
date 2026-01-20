class CardItem {
  final String id;
  final String title;
  final String list;
  final int order;
  final String? description;
  final String? colorHex;

  const CardItem({
    required this.id,
    required this.title,
    required this.list,
    required this.order,
    this.description,
    this.colorHex,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      list: (json['list'] as String?) ?? 'todo',
      order: (json['order'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      colorHex: json['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'list': list,
    'order': order,
    'description': description,
    'colorHex': colorHex,
  };

  CardItem copyWith({
    String? id,
    String? title,
    String? list,
    int? order,
    String? description,
    String? colorHex,

    bool clearDescription = false,
    bool clearColorHex = false,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      list: list ?? this.list,
      order: order ?? this.order,
      description: clearDescription ? null : (description ?? this.description),
      colorHex: clearColorHex ? null : (colorHex ?? this.colorHex),
    );
  }
}
