import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/core/theme.dart';

class SettingsActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? titleColor;
  final bool isDestructive;

  const SettingsActionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.titleColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = isDestructive 
        ? AppColors.martianRed 
        : titleColor ?? (enabled ? Colors.white : Colors.white54);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive 
                ? AppColors.martianRed.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
          color: isDestructive 
              ? AppColors.martianRed.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: effectiveTitleColor,
                  size: 20,
                ),
                child: leading!,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: effectiveTitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: enabled ? Colors.white60 : Colors.white38,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              IconTheme(
                data: IconThemeData(
                  color: enabled ? Colors.white70 : Colors.white38,
                  size: 18,
                ),
                child: trailing!,
              ),
            ] else if (onTap != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: enabled ? Colors.white70 : Colors.white38,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
