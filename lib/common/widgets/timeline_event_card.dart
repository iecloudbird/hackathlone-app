import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event/timeline_event.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';

class TimelineEventCard extends StatefulWidget {
  final TimelineEvent event;
  final bool showDate;
  final bool showTime;
  final bool showTimeLeft;
  final bool isExpandable;
  final VoidCallback? onTap;

  const TimelineEventCard({
    super.key,
    required this.event,
    this.showDate = true,
    this.showTime = false,
    this.showTimeLeft = true,
    this.isExpandable = false,
    this.onTap,
  });

  @override
  State<TimelineEventCard> createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<TimelineEventCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.isExpandable ? _handleTap : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main row with time, title, and notification (fixed position)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time column (left side) - only for events screen
                    if (widget.showTime) ...[_buildTimeColumn()],

                    // Date and time column (left side) - for home screen
                    if (widget.showDate) ...[_buildDateTimeColumn()],

                    // Event title (middle - expanded)
                    Expanded(child: _buildEventTitle()),

                    const SizedBox(width: 12),

                    // Notification bell (right side - fixed position)
                    _buildNotificationBell(context),
                  ],
                ),

                // Time left badge (if shown)
                if (widget.showTimeLeft && widget.event.isUpcoming) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: widget.showTime ? 86 : (widget.showDate ? 86 : 0),
                      ),
                      child: _buildTimeLeftBadge(),
                    ),
                  ),
                ],

                // Expandable description (separate row)
                if (widget.isExpandable &&
                    widget.event.description != null) ...[
                  const SizedBox(height: 8),
                  _buildExpandableDescription(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onTap?.call();
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 80, // Increased from 64
      child: Text(
        widget.event.formattedTime.toUpperCase(), // Match "9:00 A.M." format
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Overpass',
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEventTitle() {
    return Text(
      widget.event.name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Overpass',
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildExpandableDescription() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox(),
      secondChild: Padding(
        padding: EdgeInsets.only(
          left: widget.showTime ? 80 : (widget.showDate ? 80 : 0),
        ), // Updated for new column widths
        child: Text(
          widget.event.description!,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontFamily: 'Overpass',
          ),
          maxLines: null,
        ),
      ),
    );
  }

  Widget _buildDateTimeColumn() {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.formattedDate.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Overpass',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.event.formattedTime.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontFamily: 'Overpass',
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLeftBadge() {
    // Match the Figma design colors and styling
    Color badgeColor;
    if (widget.event.badgeColor == AppColors.rocketRed) {
      badgeColor = AppColors.rocketRed; // Red for urgent (< 3 hours)
    } else {
      badgeColor = const Color(0xFFFF8C00); // Dark orange for normal
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.event.timeLeftText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Overpass',
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return Consumer2<TimelineProvider, AuthProvider>(
      builder: (context, timelineProvider, authProvider, child) {
        // Hide notification bell for anonymous users
        if (authProvider.isAnonymous) {
          return const SizedBox(
            width: 48,
          ); // Maintain spacing for bigger button
        }

        final isEnabled = timelineProvider.isNotificationEnabled(
          widget.event.id,
        );

        return GestureDetector(
          onTap: () {
            timelineProvider.toggleEventNotification(
              widget.event.id,
              !isEnabled,
            );
          },
          child: Container(
            width: 48, // Increased from 40
            height: 48, // Increased from 40
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.brightYellow
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              color: isEnabled
                  ? Colors.black
                  : Colors.white.withValues(alpha: 0.7),
              size: 24, // Increased from 20
            ),
          ),
        );
      },
    );
  }
}
