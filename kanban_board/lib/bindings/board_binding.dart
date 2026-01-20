import 'package:get/get.dart';
import 'package:kanban_board/controllers/board_controller.dart';

class BoardBinding extends Bindings {
  @override
  void dependencies() {
    final id = Get.parameters['id'];

    if (id == null || id.trim().isEmpty) {
      throw Exception("Board id is required for /board/:id route");
    }

    Get.lazyPut<BoardController>(() => BoardController(id));
  }
}
