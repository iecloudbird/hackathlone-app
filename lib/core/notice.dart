import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';

void showSnackBar(BuildContext context, String message, {Color? color}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color ?? Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, color: Colors.green);
}

/// Custom overlay snackbar that appears on top of modals and other widgets
class OverlaySnackbar {
  static OverlayEntry? _overlayEntry;

  /// Show custom snackbar on top of all widgets
  static void show(
    BuildContext context,
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 4),
  }) {
    hide(); // Remove any existing overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => _OverlaySnackbarWidget(
        message: message,
        backgroundColor: backgroundColor,
        onClose: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-remove after specified duration
    Future.delayed(duration, () {
      hide();
    });
  }

  /// Show success overlay snackbar
  static void showSuccess(BuildContext context, String message) {
    show(context, message, Colors.green);
  }

  /// Show error overlay snackbar
  static void showError(BuildContext context, String message) {
    show(context, message, AppColors.rocketRed);
  }

  /// Remove overlay snackbar
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _OverlaySnackbarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onClose;

  const _OverlaySnackbarWidget({
    required this.message,
    required this.backgroundColor,
    required this.onClose,
  });

  @override
  State<_OverlaySnackbarWidget> createState() => _OverlaySnackbarWidgetState();
}

class _OverlaySnackbarWidgetState extends State<_OverlaySnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
