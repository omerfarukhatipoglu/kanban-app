import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/constants/colors.dart';
import 'package:kanban_board/models/card_item.dart';
import 'package:kanban_board/widgets/board_widgets/edit_card_dialog.dart';
import 'package:kanban_board/widgets/board_widgets/task_card.dart';

class DragPayload {
  final String fromListKey;
  final int fromIndex;
  final CardItem card;

  DragPayload({
    required this.fromListKey,
    required this.fromIndex,
    required this.card,
  });
}

class BoardColumn extends StatelessWidget {
  final String listKey;
  final RxList<CardItem> itemsRx;

  final VoidCallback onAdd;

  final void Function(String fromListKey, int fromIndex, int toIndex) onDrop;

  final Future<void> Function(
    String cardId,
    String newTitle,
    String? description,
    String? colorHex,
  )
  onEditCard;

  final Future<void> Function(String cardId) onDeleteCard;

  const BoardColumn({
    super.key,
    required this.listKey,
    required this.itemsRx,
    required this.onAdd,
    required this.onDrop,
    required this.onEditCard,
    required this.onDeleteCard,
  });

  String get _title {
    switch (listKey) {
      case "backlog":
        return "Backlog";
      case "todo":
        return "To Do";
      case "inprogress":
        return "In Progress";
      case "done":
        return "Done";
      default:
        return listKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Obx(() {
                final len = itemsRx.length;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.boardBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "$len",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onAdd,
                icon: Icon(Icons.add_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          Expanded(
            child: Obx(() {
              final count = itemsRx.length;
              final items = List<CardItem>.from(itemsRx);

              return DragTarget<DragPayload>(
                onWillAcceptWithDetails: (_) => true,

                onAcceptWithDetails: (details) {
                  final payload = details.data;
                  onDrop(payload.fromListKey, payload.fromIndex, count);
                },
                builder: (context, cand, _) {
                  final active = cand.isNotEmpty;

                  if (count == 0) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.boardBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        "Boş",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final card = items[i];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DragTarget<DragPayload>(
                          onWillAcceptWithDetails: (_) => true,
                          onAcceptWithDetails: (details) {
                            final payload = details.data;
                            onDrop(payload.fromListKey, payload.fromIndex, i);
                          },
                          builder: (context, cand2, _) {
                            final activeItem = cand2.isNotEmpty;

                            return Draggable<DragPayload>(
                              data: DragPayload(
                                fromListKey: listKey,
                                fromIndex: i,
                                card: card,
                              ),
                              feedback: SizedBox(
                                width: 300,
                                child: Material(
                                  color: Colors.transparent,
                                  child: TaskCard(card: card, isDragging: true),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: TaskCard(card: card),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: activeItem
                                      ? Border.all(
                                          color: AppColors.accent,
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: TaskCard(
                                  card: card,
                                  onTap: () async {
                                    final result =
                                        await Get.dialog<EditCardResult>(
                                          EditCardDialog(
                                            initialTitle: card.title,
                                            initialDescription:
                                                card.description,
                                            initialColorHex: card.colorHex,
                                          ),
                                        );
                                    if (result == null) return;

                                    if (result.delete) {
                                      await onDeleteCard(card.id);
                                      return;
                                    }

                                    await onEditCard(
                                      card.id,
                                      result.title,
                                      result.description,
                                      result.colorHex,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
