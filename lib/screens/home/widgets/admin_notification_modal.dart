import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:hackathlone_app/core/notice.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AdminNotificationModal extends StatefulWidget {
  const AdminNotificationModal({super.key});

  @override
  State<AdminNotificationModal> createState() => _AdminNotificationModalState();

  /// Show the notification modal with smooth animation
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: Navigator.of(context),
      ),
      builder: (context) => const AdminNotificationModal(),
    );
  }
}

class _AdminNotificationModalState extends State<AdminNotificationModal>
    with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start the animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.maastrichtBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: AppDimensions.paddingS),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.brightYellow.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          IconsaxPlusLinear.notification,
                          color: AppColors.brightYellow,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        const Expanded(
                          child: Text(
                            'Push Notification',
                            style: AppTextStyles.headingSmall,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            IconsaxPlusLinear.close_circle,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content - Now with proper keyboard handling and draggable scroll
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: AppDimensions.paddingM,
                        right: AppDimensions.paddingM,
                        top: AppDimensions.paddingM,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom +
                            AppDimensions.paddingM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notification Type Selector
                          Text(
                            'Type',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.brightYellow,
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
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
                                selectedColor: AppColors.brightYellow,
                                checkmarkColor: Colors.white,
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Priority Selector
                          Text(
                            'Priority',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.brightYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          Wrap(
                            spacing: AppDimensions.paddingS,
                            children: NotificationPriority.values.map((
                              priority,
                            ) {
                              final isSelected = _selectedPriority == priority;
                              return FilterChip(
                                label: Text(
                                  priority.displayName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
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
                              color: AppColors.brightYellow,
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
                                activeColor: AppColors.brightYellow,
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
                                activeColor: AppColors.brightYellow,
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
                                activeColor: AppColors.brightYellow,
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
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: AppColors.deepBlue,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusS,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusS,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                              dropdownColor: AppColors.deepBlue,
                              style: const TextStyle(color: Colors.white),
                              items: ['participant', 'mentor', 'admin'].map((
                                role,
                              ) {
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
                                  color: AppColors.brightYellow,
                                ),
                              )
                            else ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlue,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusS,
                                  ),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppDimensions.paddingS,
                                      ),
                                      child: Text(
                                        'Select Users (${_selectedUserIds.length} selected)',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: _availableUsers.length,
                                        itemBuilder: (context, index) {
                                          final user = _availableUsers[index];
                                          final isSelected = _selectedUserIds
                                              .contains(user['id']);

                                          return CheckboxListTile(
                                            value: isSelected,
                                            onChanged: (selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  _selectedUserIds.add(
                                                    user['id'],
                                                  );
                                                } else {
                                                  _selectedUserIds.remove(
                                                    user['id'],
                                                  );
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
                                            activeColor: AppColors.brightYellow,
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
                                  padding: const EdgeInsets.all(
                                    AppDimensions.paddingM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.deepBlue,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusS,
                                    ),
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
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              hintText: 'Enter notification title...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: AppColors.deepBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.brightYellow,
                                ),
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
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              hintText: 'Enter your message...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: AppColors.deepBlue,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.brightYellow,
                                ),
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
                                backgroundColor: AppColors.brightYellow,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.paddingM,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusS,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    IconsaxPlusLinear.send_2,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Text(
                                    _getButtonText(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Add bottom padding for safe area
                          SizedBox(
                            height:
                                MediaQuery.of(context).padding.bottom +
                                AppDimensions.paddingS,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getButtonText() {
    switch (_targetingMode) {
      case 'all':
        return 'Send to All Users';
      case 'role':
        return 'Send to ${_selectedRole?.toUpperCase() ?? 'Role'}';
      case 'specific':
        return 'Send to ${_selectedUserIds.length} Selected Users';
      default:
        return 'Send Notification';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.normal:
        return AppColors.brightYellow;
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
        OverlaySnackbar.showError(context, 'Failed to load users: $e');
      }
    }
  }

  void _sendNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      OverlaySnackbar.showError(
        context,
        'Please fill in both title and message',
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.brightYellow),
        ),
      );

      // Validate targeting mode
      if (_targetingMode == 'role' && _selectedRole == null) {
        if (mounted) Navigator.of(context).pop();
        OverlaySnackbar.showError(context, 'Please select a role');
        return;
      }

      if (_targetingMode == 'specific' && _selectedUserIds.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        OverlaySnackbar.showError(context, 'Please select at least one user');
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

        case 'role':
          await notificationProvider.broadcastNotification(
            title: title,
            message: message,
            type: type,
            userRole: _selectedRole,
          );

        case 'specific':
          await notificationProvider.sendTargetedNotifications(
            userIds: _selectedUserIds,
            title: title,
            message: message,
            type: type,
          );
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Prepare success message before clearing form
      String successMessage;
      switch (_targetingMode) {
        case 'all':
          successMessage = '📢 Broadcast notification sent to all users!';
        case 'role':
          successMessage = '🎯 Notification sent to all ${_selectedRole}s!';
        case 'specific':
          successMessage =
              '👥 Notification sent to ${_selectedUserIds.length} selected users!';
        default:
          successMessage = '✅ Notification sent successfully!';
      }

      // Close modal and show success message
      if (mounted) {
        Navigator.of(context).pop(); // Close modal

        // Small delay to ensure modal is closed before showing snackbar
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        OverlaySnackbar.showError(
          context,
          'Failed to send notification: ${e.toString()}',
        );
      }
    }
  }
}
