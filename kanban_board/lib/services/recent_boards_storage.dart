import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanban_board/models/recent_board_item.dart';

class RecentBoardsStorage {
  static const String _key = "recent_boards";
  static const int _max = 10;

  static Future<List<RecentBoardItem>> getBoards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return RecentBoardItem.fromJson(map);
    }).toList();
  }

  static Future<void> addBoard(RecentBoardItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBoards();

    current.removeWhere((b) => b.id == item.id);
    current.insert(0, item);

    if (current.length > _max) {
      current.removeRange(_max, current.length);
    }

    await _save(prefs, current);
  }

  static Future<void> upsertBoard(RecentBoardItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBoards();

    final idx = current.indexWhere((b) => b.id == item.id);
    if (idx != -1) {
      current[idx] = item;
    } else {
      current.insert(0, item);
    }

    if (current.length > _max) {
      current.removeRange(_max, current.length);
    }

    await _save(prefs, current);
  }

  static Future<void> removeById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getBoards();

    current.removeWhere((b) => b.id == id);
    await _save(prefs, current);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(
    SharedPreferences prefs,
    List<RecentBoardItem> list,
  ) async {
    final encoded = list.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
