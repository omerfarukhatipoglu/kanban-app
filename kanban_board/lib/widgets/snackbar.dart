// ignore_for_file: unused_element, non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

enum SnackKind { info, success, warning, error }

OverlayEntry? _SnackEntry;
AnimationController? _SnackController;
bool _SnackShowing = false;

void showSnack(
  BuildContext context,
  String msg, {
  SnackKind kind = SnackKind.info,
}) {
  if (_SnackShowing) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  final overlay = navigator.overlay ?? Overlay.of(context, rootOverlay: true);

  IconData icon;
  Color bg;
  switch (kind) {
    case SnackKind.success:
      icon = Icons.check_circle_rounded;
      bg = const Color(0xFF1B5E20);
      break;
    case SnackKind.warning:
      icon = Icons.warning_amber_rounded;
      bg = const Color(0xFF7B5E00);
      break;
    case SnackKind.error:
      icon = Icons.error_rounded;
      bg = const Color(0xFF8B0000);
      break;
    case SnackKind.info:
      icon = Icons.info_rounded;
      bg = const Color(0xFF263238);
      break;
  }

  final controller = AnimationController(
    vsync: navigator,
    duration: const Duration(milliseconds: 350),
  );
  final animation = Tween<Offset>(
    begin: const Offset(0, -1),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

  final entry = OverlayEntry(
    builder: (ctx) => SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: animation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: AutoSizeText(
                        msg,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  _SnackShowing = true;
  _SnackEntry = entry;
  _SnackController = controller;

  overlay.insert(entry);
  controller.forward();

  Future.delayed(const Duration(seconds: 3), () async {
    try {
      await controller.reverse();
    } finally {
      entry.remove();
      controller.dispose();
      _SnackEntry = null;
      _SnackController = null;
      _SnackShowing = false;
    }
  });
}
