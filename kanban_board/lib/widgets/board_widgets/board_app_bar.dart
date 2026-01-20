import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/constants/colors.dart';

class BoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RxString titleRx;
  final VoidCallback onRefresh;

  const BoardAppBar({
    super.key,
    required this.titleRx,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,

      iconTheme: IconThemeData(color: AppColors.textOnDark),

      title: Obx(
        () => Text(
          titleRx.value,
          style: TextStyle(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: "Yenile",
          onPressed: onRefresh,
          icon: Icon(Icons.refresh_rounded, color: AppColors.textOnDark),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
