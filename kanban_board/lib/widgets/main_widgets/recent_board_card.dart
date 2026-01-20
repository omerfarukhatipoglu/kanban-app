import 'package:flutter/material.dart';
import 'package:kanban_board/constants/colors.dart';
import 'package:kanban_board/models/recent_board_item.dart';

class RecentBoardCard extends StatelessWidget {
  final RecentBoardItem item;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onEdit;

  const RecentBoardCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCopy,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.boardBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.view_kanban_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: ${item.id}",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              tooltip: "ID kopyala",
              icon: Icon(Icons.copy_rounded, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onEdit,
              tooltip: "Board adını değiştir",
              icon: Icon(Icons.edit_rounded, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
