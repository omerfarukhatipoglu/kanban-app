import 'package:flutter/material.dart';
import 'package:kanban_board/constants/colors.dart';

class EmptyRecentCard extends StatelessWidget {
  const EmptyRecentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Henüz kayıtlı board yok. Bir tane oluşturup başlayabilirsin.",
              style: TextStyle(color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
