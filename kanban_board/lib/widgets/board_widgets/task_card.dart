import 'package:flutter/material.dart';
import 'package:kanban_board/constants/colors.dart';
import 'package:kanban_board/models/card_item.dart';

class TaskCard extends StatelessWidget {
  final CardItem card;
  final bool isDragging;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.card,
    this.isDragging = false,
    this.onTap,
  });

  Color _bgColor() {
    final hex = card.colorHex;
    if (hex == null || hex.trim().isEmpty) return AppColors.cardBackground;

    var h = hex.trim().replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return AppColors.cardBackground;

    try {
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return AppColors.cardBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              if (!isDragging)
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if ((card.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  card.description!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
