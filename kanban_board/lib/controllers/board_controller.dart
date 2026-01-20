// ignore_for_file: empty_catches

import 'package:get/get.dart';
import 'package:kanban_board/models/card_item.dart';
import 'package:kanban_board/services/api_service.dart';
import 'package:kanban_board/widgets/snackbar.dart';

class BoardController extends GetxController {
  final ApiService _api = ApiService();
  final String boardId;

  BoardController(this.boardId);

  final RxBool loading = false.obs;
  final RxString boardTitle = "Board".obs;

  final RxList<CardItem> backlog = <CardItem>[].obs;
  final RxList<CardItem> todo = <CardItem>[].obs;
  final RxList<CardItem> inprogress = <CardItem>[].obs;
  final RxList<CardItem> done = <CardItem>[].obs;

  RxList<CardItem> listByKey(String key) {
    switch (key) {
      case "backlog":
        return backlog;
      case "todo":
        return todo;
      case "inprogress":
        return inprogress;
      case "done":
        return done;
      default:
        return backlog;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadBoard();
  }

  Future<void> loadBoard() async {
    if (loading.value) return;
    loading.value = true;
    try {
      final data = await _api.getBoard(boardId);
      boardTitle.value = (data["title"] as String?) ?? "Board";
      final columns = (data["columns"] as Map).cast<String, dynamic>();

      backlog.assignAll(_parseCards(columns["backlog"]));
      todo.assignAll(_parseCards(columns["todo"]));
      inprogress.assignAll(_parseCards(columns["inprogress"]));
      done.assignAll(_parseCards(columns["done"]));
    } catch (e) {
      showSnack(Get.context!, "Tablolar Yüklenemedi.", kind: SnackKind.error);
    } finally {
      loading.value = false;
    }
  }

  List<CardItem> _parseCards(dynamic arr) {
    if (arr is! List) return [];
    final list = arr
        .map((e) => CardItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<void> addCard(String listKey, String title) async {
    try {
      final res = await _api.createCard(
        boardId: boardId,
        list: listKey,
        title: title,
      );

      final created = CardItem.fromJson(res);

      final list = listByKey(listKey);
      list.add(created);

      _normalizeOrdersOnly(listKey);
      await _syncOrdersOnly(listKey);
    } catch (e) {
      showSnack(Get.context!, "Kart Eklenemedi.", kind: SnackKind.error);
    }
  }

  Future<void> reorderWithin(String listKey, int oldIndex, int newIndex) async {
    final list = listByKey(listKey);
    if (list.isEmpty) return;

    final from = oldIndex.clamp(0, list.length - 1);
    final to = newIndex.clamp(0, list.length);

    final item = list.removeAt(from);
    final insertIndex = to.clamp(0, list.length);
    list.insert(insertIndex, item);

    _normalizeOrdersOnly(listKey);
    await _syncOrdersOnly(listKey);
  }

  Future<void> moveCard({
    required String fromKey,
    required int fromIndex,
    required String toKey,
    required int toIndex,
  }) async {
    final from = listByKey(fromKey);
    final to = listByKey(toKey);

    if (fromIndex < 0 || fromIndex >= from.length) return;

    if (fromKey == toKey) {
      final safeTo = toIndex.clamp(0, from.length);
      await reorderWithin(fromKey, fromIndex, safeTo);
      return;
    }

    final item = from.removeAt(fromIndex);

    final insertIndex = toIndex.clamp(0, to.length);
    to.insert(insertIndex, item.copyWith(list: toKey));

    _normalizeOrdersOnly(fromKey);
    _normalizeOrdersOnly(toKey);

    try {
      await _api.updateCard(
        boardId: boardId,
        cardId: item.id,
        list: toKey,
        order: insertIndex,
      );

      await _syncOrdersOnly(fromKey);
      await _syncOrdersOnly(toKey);
    } catch (e) {}
  }

  Future<void> updateCardMeta({
    required String listKey,
    required String cardId,
    required String newTitle,
    String? description,
    String? colorHex,
  }) async {
    final list = listByKey(listKey);
    final idx = list.indexWhere((c) => c.id == cardId);
    if (idx == -1) return;

    final title = newTitle.trim();
    if (title.isEmpty) {
      showSnack(Get.context!, "Kart adı boş olamaz.", kind: SnackKind.warning);

      return;
    }

    try {
      await _api.updateCard(
        boardId: boardId,
        cardId: cardId,
        title: title,
        description: description,
        clearDescription: description == null,
        colorHex: colorHex,
      );

      final old = list[idx];
      list[idx] = old.copyWith(
        title: title,
        description: description,
        colorHex: colorHex,
      );
    } catch (e) {}
  }

  Future<void> deleteCard({
    required String listKey,
    required String cardId,
  }) async {
    final list = listByKey(listKey);
    final idx = list.indexWhere((c) => c.id == cardId);
    if (idx == -1) return;

    try {
      await _api.deleteCard(boardId: boardId, cardId: cardId);

      list.removeAt(idx);

      _normalizeOrdersOnly(listKey);
      await _syncOrdersOnly(listKey);
    } catch (e) {}
  }

  void _normalizeOrdersOnly(String listKey) {
    final list = listByKey(listKey);
    final normalized = <CardItem>[];

    for (var i = 0; i < list.length; i++) {
      final c = list[i];

      normalized.add(c.copyWith(order: i, list: listKey));
    }

    list.assignAll(normalized);
  }

  Future<void> _syncOrdersOnly(String listKey) async {
    final list = listByKey(listKey);

    for (var i = 0; i < list.length; i++) {
      final c = list[i];

      await _api.updateCard(boardId: boardId, cardId: c.id, order: i);
    }
  }
}
