import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/constants/colors.dart';
import 'package:kanban_board/controllers/main_controller.dart';
import 'package:kanban_board/widgets/main_widgets/create_board_dialog.dart';
import 'package:kanban_board/widgets/main_widgets/empty_recent_card.dart';
import 'package:kanban_board/widgets/main_widgets/header_card.dart';
import 'package:kanban_board/widgets/main_widgets/join_board_card.dart';
import 'package:kanban_board/widgets/main_widgets/primary_action_card.dart';
import 'package:kanban_board/widgets/main_widgets/recent_board_card.dart';
import 'package:kanban_board/widgets/snackbar.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  void _openCreateBoardDialog() {
    Get.dialog(
      CreateBoardDialog(
        onCreate: (title) => controller.createBoardWithTitle(title),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            "Kanban Board",
            style: TextStyle(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              HeaderCard(
                title: "Hadi başlayalım",
                subtitle:
                    "Yeni bir board oluşturabilir veya ID ile mevcut bir board’a katılabilirsin.",
                icon: Icons.dashboard_customize_rounded,
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.backendAlive.value) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Sunucu bağlantısı kurulamadı.",
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => controller.checkingBackend.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TextButton(
                                onPressed: controller.checkBackend,
                                child: const Text(
                                  "Tekrar Dene",
                                  style: TextStyle(
                                    color: AppColors.blockedText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }),
              Obx(
                () => PrimaryActionCard(
                  title: "Yeni Board Oluştur",
                  subtitle: "Sana özel bir ID üretelim ve paylaş.",
                  icon: Icons.add_circle_outline_rounded,
                  buttonText: controller.loading.value ? "..." : "Oluştur",
                  onPressed: controller.loading.value
                      ? () {}
                      : _openCreateBoardDialog,
                ),
              ),
              const SizedBox(height: 12),

              JoinBoardCard(onJoin: (id) => controller.joinBoard(id)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Son Boardlar",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clearRecent,
                    child: Text(
                      "Temizle",
                      style: TextStyle(color: AppColors.blockedText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Obx(() {
                final recentBoards = controller.recentBoards;

                if (recentBoards.isEmpty) {
                  return EmptyRecentCard();
                }

                return Column(
                  children: recentBoards
                      .map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RecentBoardCard(
                            item: b,
                            onTap: () => Get.toNamed('/board/${b.id}'),
                            onCopy: () {
                              showSnack(
                                context,
                                "Kopyalama Başarılı",
                                kind: SnackKind.success,
                              );
                            },
                            onEdit: () => controller.openEditBoardDialog(b.id),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
