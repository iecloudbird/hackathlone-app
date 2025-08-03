import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/config/appbar_config.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed; // callback for menu button

  const HomeAppBar({super.key, required this.title, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
      elevation: 0,
      toolbarHeight:
          kToolbarHeight + 20, // Add extra height for relaxed spacing
      leading: Padding(
        padding: const EdgeInsets.only(
          top: 10,
        ), // Add top padding for better spacing
        child: onMenuPressed != null
            ? Transform.translate(
                offset: const Offset(16.0, 0.0),
                child: IconButton(
                  icon: const Icon(
                    IconsaxPlusBold.element_2,
                    color: Colors.white,
                  ),
                  onPressed: onMenuPressed,
                ),
              )
            : AppBarConfig.menuButton.toIconButton(context),
      ),
      actions: [
        ...AppBarConfig.homeActions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ), // Match other elements padding
                child: action.toIconButton(context),
              ),
            )
            .toList(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
