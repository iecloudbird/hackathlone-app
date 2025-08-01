import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/common/appbar_config.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<AppBarActionItem>? customActions;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.customActions,
  });

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
      leading: onMenuPressed != null
          ? AppBarConfig.menuButton.toIconButton(context)
          : Transform.translate(
              offset: const Offset(16.0, 0.0),
              child: IconButton(
                icon: const Icon(
                  IconsaxPlusBold.element_2,
                  color: Colors.white,
                ),
                tooltip: 'Menu',
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
      actions: (customActions ?? AppBarConfig.homeActions)
          .map((action) => action.toIconButton(context))
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
