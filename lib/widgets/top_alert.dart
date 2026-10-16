import 'dart:async';
import 'package:flutter/material.dart';

enum TopAlertType { success, error, warning, info }

/// A modern, uniformly-styled floating alert notification displayed in the top right corner.
class TopAlert {
  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    TopAlertType type = TopAlertType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    dismiss();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => _TopAlertWidget(
        title: title,
        message: message,
        type: type,
        onDismiss: dismiss,
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    _activeTimer = Timer(duration, () {
      dismiss();
    });
  }

  static void dismiss() {
    _activeTimer?.cancel();
    _activeTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _TopAlertWidget extends StatefulWidget {
  final String? title;
  final String message;
  final TopAlertType type;
  final VoidCallback onDismiss;

  const _TopAlertWidget({
    this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_TopAlertWidget> createState() => _TopAlertWidgetState();
}

class _TopAlertWidgetState extends State<_TopAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.35, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color bgColor;
    IconData icon;
    String defaultTitle;

    switch (widget.type) {
      case TopAlertType.success:
        primaryColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        icon = Icons.check_circle_rounded;
        defaultTitle = 'Success';
        break;
      case TopAlertType.error:
        primaryColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEF2F2);
        icon = Icons.error_rounded;
        defaultTitle = 'Action Required';
        break;
      case TopAlertType.warning:
        primaryColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFFFBEB);
        icon = Icons.warning_amber_rounded;
        defaultTitle = 'Attention';
        break;
      case TopAlertType.info:
        primaryColor = const Color(0xFF0F5B9E);
        bgColor = const Color(0xFFF0F7FF);
        icon = Icons.info_outline_rounded;
        defaultTitle = 'Information';
        break;
    }

    final displayTitle = widget.title ?? defaultTitle;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 360,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _handleDismiss,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
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
    );
  }
}
