import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanban_board/constants/colors.dart';

class EditCardResult {
  final String title;
  final String? description;
  final String? colorHex;
  final bool delete;

  EditCardResult({
    required this.title,
    required this.description,
    required this.colorHex,
    required this.delete,
  });
}

class EditCardDialog extends StatefulWidget {
  final String initialTitle;
  final String? initialDescription;
  final String? initialColorHex;

  const EditCardDialog({
    super.key,
    required this.initialTitle,
    this.initialDescription,
    this.initialColorHex,
  });

  @override
  State<EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  String? _colorHex;
  bool _invalid = false;

  final _preset = const [
    "#BAE6FD",
    "#DDD6FE",
    "#FED7AA",
    "#FECACA",
    "#BBF7D0",
    "#FBCFE8",
    "#E9D5FF",
    "#FEF08A",
  ];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle);
    _desc = TextEditingController(text: widget.initialDescription ?? "");
    _colorHex = widget.initialColorHex;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    var h = hex.replaceAll("#", "");
    if (h.length == 6) h = "FF$h";
    return Color(int.parse(h, radix: 16));
  }

  void _submit() {
    final t = _title.text.trim();
    setState(() => _invalid = t.isEmpty);
    if (t.isEmpty) return;

    final d = _desc.text.trim();

    Get.back(
      result: EditCardResult(
        title: t,
        description: d.isEmpty ? null : d,
        colorHex: _colorHex,
        delete: false,
      ),
    );
  }

  void _deleteDirect() {
    Get.back(
      result: EditCardResult(
        title: widget.initialTitle,
        description: widget.initialDescription,
        colorHex: widget.initialColorHex,
        delete: true,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    String? errorText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.boardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: radius),
      titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

      title: Row(
        children: [
          Expanded(
            child: Text(
              "Kartı Düzenle",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: "Kapat",
            onPressed: () => Get.back(),
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                hint: "Kart adı",
                errorText: _invalid ? "Boş olamaz" : null,
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _desc,
              minLines: 3,
              maxLines: 6,
              decoration: _fieldDecoration(
                hint: "Açıklama (opsiyonel)",
                prefixIcon: Icon(
                  Icons.subject_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  "Renk",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ColorDot(
                  color: AppColors.cardBackground,
                  selected: _colorHex == null,
                  icon: Icons.layers_clear_rounded,
                  onTap: () => setState(() => _colorHex = null),
                ),
                ..._preset.map((hex) {
                  final selected = _colorHex == hex;
                  return _ColorDot(
                    color: _hexToColor(hex),
                    selected: selected,
                    onTap: () => setState(() => _colorHex = hex),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),

      actions: [
        TextButton.icon(
          onPressed: _deleteDirect,
          icon: const Icon(Icons.delete_rounded),
          label: const Text("Sil"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "İptal",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded),
          label: const Text(
            "Kaydet",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnDark,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.cardBorder,
            width: selected ? 2.2 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Center(
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                )
              : (icon == null
                    ? const SizedBox.shrink()
                    : Icon(icon, size: 18, color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}
