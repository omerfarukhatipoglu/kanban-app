import 'package:get/get.dart';
import 'package:kanban_board/models/recent_board_item.dart';
import 'package:kanban_board/services/api_service.dart';
import 'package:kanban_board/services/recent_boards_storage.dart';
import 'package:kanban_board/widgets/main_widgets/edit_board_dialog.dart';
import 'package:kanban_board/widgets/snackbar.dart';

class MainController extends GetxController {
  final ApiService _api = ApiService();

  final RxBool loading = false.obs;
  final RxList<RecentBoardItem> recentBoards = <RecentBoardItem>[].obs;
  final RxBool backendAlive = true.obs;
  final RxBool checkingBackend = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentBoards();
    checkBackend();
  }

  Future<void> checkBackend() async {
    if (checkingBackend.value) return;

    checkingBackend.value = true;
    try {
      final ok = await _api.health();
      backendAlive.value = ok;
    } catch (_) {
      backendAlive.value = false;
    } finally {
      checkingBackend.value = false;
    }
  }

  Future<void> loadRecentBoards() async {
    final list = await RecentBoardsStorage.getBoards();
    recentBoards.assignAll(list);
  }

  Future<void> createBoardWithTitle(String title) async {
    final t = title.trim();
    if (t.isEmpty) {
      showSnack(Get.context!, "Board adı boş olamaz", kind: SnackKind.warning);

      return;
    }

    if (loading.value) return;
    loading.value = true;

    try {
      final created = await _api.createBoard(title: t);
      final id = created["id"] as String;
      final boardTitle = created["title"] as String? ?? t;

      final item = RecentBoardItem(id: id, title: boardTitle);
      await RecentBoardsStorage.addBoard(item);
      await loadRecentBoards();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.toNamed('/board/$id');
    } finally {
      loading.value = false;
    }
  }

  Future<void> joinBoard(String boardId) async {
    final id = boardId.trim();
    if (id.isEmpty) {
      showSnack(Get.context!, "Board ID boş olamaz", kind: SnackKind.warning);
      return;
    }

    if (loading.value) return;
    loading.value = true;

    try {
      final board = await _api.getBoard(id);
      final title = board["title"] as String? ?? "Untitled Board";

      final item = RecentBoardItem(id: id, title: title);
      await RecentBoardsStorage.addBoard(item);
      await loadRecentBoards();

      Get.toNamed('/board/$id');
    } catch (e) {
      showSnack(
        Get.context!,
        "Bu ID ile bir board bulunamadı",
        kind: SnackKind.warning,
      );
    } finally {
      loading.value = false;
    }
  }

  void openEditBoardDialog(String boardId) {
    final idx = recentBoards.indexWhere((b) => b.id == boardId);
    if (idx == -1) return;

    final current = recentBoards[idx];

    Get.dialog(
      EditBoardDialog(
        initialTitle: current.title,
        onSave: (newTitle) => renameBoard(boardId, newTitle),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> renameBoard(String boardId, String newTitle) async {
    final t = newTitle.trim();
    if (t.isEmpty) {
      showSnack(Get.context!, "Board adı boş olamaz.", kind: SnackKind.warning);
      return;
    }

    await _api.updateBoard(boardId: boardId, title: t);

    final idx = recentBoards.indexWhere((b) => b.id == boardId);
    if (idx != -1) {
      final updated = RecentBoardItem(id: boardId, title: t);
      recentBoards[idx] = updated;
      await RecentBoardsStorage.upsertBoard(updated);
    }
  }

  Future<void> clearRecent() async {
    await RecentBoardsStorage.clear();
    recentBoards.clear();
  }
}
