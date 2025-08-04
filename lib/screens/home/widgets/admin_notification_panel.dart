import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AdminNotificationPanel extends StatefulWidget {
  const AdminNotificationPanel({super.key});

  @override
  State<AdminNotificationPanel> createState() => _AdminNotificationPanelState();
}

class _AdminNotificationPanelState extends State<AdminNotificationPanel> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  NotificationType _selectedType = NotificationType.announcement;
  NotificationPriority _selectedPriority = NotificationPriority.normal;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Only show for admins
    if (authProvider.userProfile?.role != 'admin') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.spiroDiscoBall.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                IconsaxPlusLinear.speaker,
                color: AppColors.spiroDiscoBall,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Text(
                'Send Broadcast Notification',
                style: AppTextStyles.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // Notification Type Selector
          Text(
            'Type',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.spiroDiscoBall,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Wrap(
            spacing: AppDimensions.paddingS,
            children: NotificationType.values.map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                },
                backgroundColor: AppColors.deepBlue,
                selectedColor: AppColors.spiroDiscoBall,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Priority Selector
          Text(
            'Priority',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.spiroDiscoBall,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Wrap(
            spacing: AppDimensions.paddingS,
            children: NotificationPriority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              return FilterChip(
                label: Text(
                  priority.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                backgroundColor: AppColors.deepBlue,
                selectedColor: _getPriorityColor(priority),
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Title Input
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Notification Title',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Enter notification title...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.deepBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: const BorderSide(color: AppColors.spiroDiscoBall),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Message Input
          TextFormField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Message',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Enter your message...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.deepBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: const BorderSide(color: AppColors.spiroDiscoBall),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Send Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spiroDiscoBall,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconsaxPlusLinear.send_2),
                  SizedBox(width: AppDimensions.paddingS),
                  Text('Send to All Users', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.normal:
        return AppColors.spiroDiscoBall;
      case NotificationPriority.high:
        return AppColors.brightYellow;
      case NotificationPriority.urgent:
        return AppColors.rocketRed;
    }
  }

  void _sendNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and message'),
          backgroundColor: AppColors.rocketRed,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.spiroDiscoBall),
        ),
      );

      // For now, send to current user as a demo
      // In a real implementation, you would broadcast to all users
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        await context.read<NotificationProvider>().sendNotification(
          userId: authProvider.user!.id,
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          type: _selectedType.name,
        );
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Clear form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedType = NotificationType.announcement;
        _selectedPriority = NotificationPriority.normal;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification sent successfully! (Demo: sent to yourself)',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification: ${e.toString()}'),
          backgroundColor: AppColors.rocketRed,
        ),
      );
    }
  }
}
