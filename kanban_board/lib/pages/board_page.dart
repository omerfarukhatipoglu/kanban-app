import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/controllers/board_controller.dart';
import 'package:kanban_board/widgets/board_widgets/add_card_sheet.dart';
import 'package:kanban_board/widgets/board_widgets/board_app_bar.dart';
import 'package:kanban_board/widgets/board_widgets/board_column.dart';

class BoardPage extends GetView<BoardController> {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoardAppBar(
        titleRx: controller.boardTitle,
        onRefresh: controller.loadBoard,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            if (isLandscape) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _col("backlog"),
                    const SizedBox(width: 12),
                    _col("todo"),
                    const SizedBox(width: 12),
                    _col("inprogress"),
                    const SizedBox(width: 12),
                    _col("done"),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _col("backlog")),
                        const SizedBox(width: 12),
                        Expanded(child: _col("todo")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _col("inprogress")),
                        const SizedBox(width: 12),
                        Expanded(child: _col("done")),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _col(String listKey) {
    return BoardColumn(
      listKey: listKey,
      itemsRx: controller.listByKey(listKey),
      onAdd: () {
        Get.bottomSheet(
          AddCardSheet(
            listKey: listKey,
            onCreate: (title) => controller.addCard(listKey, title),
          ),
        );
      },
      onDrop: (fromKey, fromIndex, toIndex) => controller.moveCard(
        fromKey: fromKey,
        fromIndex: fromIndex,
        toKey: listKey,
        toIndex: toIndex,
      ),
      onEditCard: (cardId, title, desc, colorHex) => controller.updateCardMeta(
        listKey: listKey,
        cardId: cardId,
        newTitle: title,
        description: desc,
        colorHex: colorHex,
      ),
      onDeleteCard: (cardId) =>
          controller.deleteCard(listKey: listKey, cardId: cardId),
    );
  }
}
