class RecentBoardItem {
  final String id;
  final String title;

  const RecentBoardItem({required this.id, required this.title});

  Map<String, dynamic> toJson() => {"id": id, "title": title};

  factory RecentBoardItem.fromJson(Map<String, dynamic> json) {
    return RecentBoardItem(
      id: json["id"] as String,
      title: (json["title"] as String?) ?? "Untitled Board",
    );
  }
}
