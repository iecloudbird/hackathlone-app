import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
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
      leading: Transform.translate(
        offset: const Offset(16.0, 0.0),
        child: IconButton(
          icon: const Icon(IconsaxPlusBold.element_2, color: Colors.white),
          onPressed:
              onMenuPressed ??
              () {
                Scaffold.of(context).openDrawer();
              },
        ),
      ),
      actions: [
        Transform.translate(
          offset: const Offset(-16.0, 0.0),
          child: IconButton(
            icon: const Icon(IconsaxPlusLinear.map, color: Colors.white),
            onPressed: () {
              // TODO: Implement map functionality
            },
          ),
        ),
        Transform.translate(
          offset: const Offset(-16.0, 0.0),
          child: IconButton(
            icon: const Icon(
              IconsaxPlusLinear.scan_barcode,
              color: Colors.white,
            ),
            onPressed: () {
              context.go(AppRoutes.qrDisplay);
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
