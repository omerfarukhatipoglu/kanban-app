import 'package:get/get.dart';
import 'package:kanban_board/bindings/board_binding.dart';
import 'package:kanban_board/bindings/main_binding.dart';
import 'package:kanban_board/pages/board_page.dart';
import 'package:kanban_board/pages/main_page.dart';
import 'package:kanban_board/routes/routes.dart';

abstract class Pages {
  static List<GetPage> pages = [
    GetPage(
      name: Routes.MAIN_PAGE,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.BOARD_PAGE,
      page: () => const BoardPage(),
      binding: BoardBinding(),
    ),
  ];
}
