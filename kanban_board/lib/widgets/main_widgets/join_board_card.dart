// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kanban_board/constants/colors.dart';

class JoinBoardCard extends StatefulWidget {
  final void Function(String id) onJoin;

  const JoinBoardCard({super.key, required this.onJoin});

  @override
  State<JoinBoardCard> createState() => _JoinBoardCardState();
}

class _JoinBoardCardState extends State<JoinBoardCard> {
  final _controller = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final id = _controller.text.trim();
    setState(() => _invalid = id.isEmpty);
    if (id.isEmpty) return;

    widget.onJoin(id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.boardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.login_rounded, color: AppColors.doneText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Board’a Katıl",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Board ID’yi gir.",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: "Örn: 2x5cnjb2ab",
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.boardBackground,
              prefixIcon: Icon(
                Icons.tag_rounded,
                color: AppColors.textSecondary,
              ),

              helperText: _invalid ? null : " ",
              helperStyle: const TextStyle(height: 1.1),
              errorText: _invalid ? "Board ID boş olamaz" : null,
              errorMaxLines: 1,

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
                borderSide: BorderSide(color: AppColors.accent, width: 1.2),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _submit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.doneText,
                side: BorderSide(color: AppColors.doneText.withOpacity(0.35)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Katıl",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
