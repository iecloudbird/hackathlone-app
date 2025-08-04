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

  // Targeting options
  String _targetingMode = 'all'; // 'all', 'role', 'specific'
  String? _selectedRole;
  List<String> _selectedUserIds = [];
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoadingUsers = false;

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

          // Targeting Options
          Text(
            'Send To',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.spiroDiscoBall,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),

          // Targeting Mode Selector
          Column(
            children: [
              RadioListTile<String>(
                value: 'all',
                groupValue: _targetingMode,
                onChanged: (value) {
                  setState(() {
                    _targetingMode = value!;
                    _selectedUserIds.clear();
                  });
                },
                title: const Text(
                  'All Users',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Send to all registered users',
                  style: TextStyle(color: Colors.white70),
                ),
                activeColor: AppColors.spiroDiscoBall,
              ),
              RadioListTile<String>(
                value: 'role',
                groupValue: _targetingMode,
                onChanged: (value) {
                  setState(() {
                    _targetingMode = value!;
                    _selectedUserIds.clear();
                  });
                },
                title: const Text(
                  'By Role',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Send to users with specific role',
                  style: TextStyle(color: Colors.white70),
                ),
                activeColor: AppColors.spiroDiscoBall,
              ),
              RadioListTile<String>(
                value: 'specific',
                groupValue: _targetingMode,
                onChanged: (value) {
                  setState(() {
                    _targetingMode = value!;
                    _selectedUserIds.clear();
                    if (_availableUsers.isEmpty) {
                      _loadUsers();
                    }
                  });
                },
                title: const Text(
                  'Specific Users',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Choose individual users',
                  style: TextStyle(color: Colors.white70),
                ),
                activeColor: AppColors.spiroDiscoBall,
              ),
            ],
          ),

          // Role Selector (shown when 'role' is selected)
          if (_targetingMode == 'role') ...[
            const SizedBox(height: AppDimensions.paddingS),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Select Role',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.deepBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
              dropdownColor: AppColors.deepBlue,
              style: const TextStyle(color: Colors.white),
              items: ['participant', 'mentor', 'admin'].map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          ],

          // User Selector (shown when 'specific' is selected)
          if (_targetingMode == 'specific') ...[
            const SizedBox(height: AppDimensions.paddingS),
            if (_isLoadingUsers)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.spiroDiscoBall,
                ),
              )
            else ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.deepBlue,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      child: Text(
                        'Select Users (${_selectedUserIds.length} selected)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _availableUsers.length,
                        itemBuilder: (context, index) {
                          final user = _availableUsers[index];
                          final isSelected = _selectedUserIds.contains(
                            user['id'],
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedUserIds.add(user['id']);
                                } else {
                                  _selectedUserIds.remove(user['id']);
                                }
                              });
                            },
                            title: Text(
                              user['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${user['email']} • ${user['role']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            activeColor: AppColors.spiroDiscoBall,
                            checkColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_availableUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'No users available. Try refreshing.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],

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

  /// Load available users for selection
  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await context
          .read<NotificationProvider>()
          .fetchUsersForSelection();
      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: AppColors.rocketRed,
          ),
        );
      }
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

      // Validate targeting mode
      if (_targetingMode == 'role' && _selectedRole == null) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role'),
            backgroundColor: AppColors.rocketRed,
          ),
        );
        return;
      }

      if (_targetingMode == 'specific' && _selectedUserIds.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one user'),
            backgroundColor: AppColors.rocketRed,
          ),
        );
        return;
      }

      final notificationProvider = context.read<NotificationProvider>();
      final title = _titleController.text.trim();
      final message = _messageController.text.trim();
      final type = _selectedType.name;

      // Send notification based on targeting mode
      switch (_targetingMode) {
        case 'all':
          await notificationProvider.broadcastNotification(
            title: title,
            message: message,
            type: type,
          );
          break;

        case 'role':
          await notificationProvider.broadcastNotification(
            title: title,
            message: message,
            type: type,
            userRole: _selectedRole,
          );
          break;

        case 'specific':
          await notificationProvider.sendTargetedNotifications(
            userIds: _selectedUserIds,
            title: title,
            message: message,
            type: type,
          );
          break;
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Prepare success message before clearing form
      String successMessage;
      switch (_targetingMode) {
        case 'all':
          successMessage = '📢 Broadcast notification sent to all users!';
          break;
        case 'role':
          successMessage = '🎯 Notification sent to all ${_selectedRole}s!';
          break;
        case 'specific':
          successMessage =
              '👥 Notification sent to ${_selectedUserIds.length} selected users!';
          break;
        default:
          successMessage = '✅ Notification sent successfully!';
      }

      // Clear form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedType = NotificationType.announcement;
        _selectedPriority = NotificationPriority.normal;
        _targetingMode = 'all';
        _selectedRole = null;
        _selectedUserIds.clear();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
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
