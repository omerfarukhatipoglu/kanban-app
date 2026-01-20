// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/constants/colors.dart';
import 'package:kanban_board/widgets/snackbar.dart';

class EditBoardDialog extends StatefulWidget {
  final String initialTitle;
  final Future<void> Function(String newTitle) onSave;

  const EditBoardDialog({
    super.key,
    required this.initialTitle,
    required this.onSave,
  });

  @override
  State<EditBoardDialog> createState() => _EditBoardDialogState();
}

class _EditBoardDialogState extends State<EditBoardDialog> {
  late final TextEditingController _title;
  bool _invalid = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = _title.text.trim();
    setState(() => _invalid = t.isEmpty);
    if (t.isEmpty) return;

    setState(() => _saving = true);
    try {
      await widget.onSave(t);
      Get.back();
      showSnack(context, "Board adı güncellendi", kind: SnackKind.success);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Board Düzenle",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Board adını değiştir",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _title,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: "Board adı",
              errorText: _invalid ? "Boş olamaz" : null,
              filled: true,
              fillColor: AppColors.boardBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.accent, width: 1.3),
              ),
              prefixIcon: Icon(
                Icons.dashboard_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Get.back(),
          child: Text(
            "İptal",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textOnDark,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            _saving ? "Kaydediliyor" : "Kaydet",
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
