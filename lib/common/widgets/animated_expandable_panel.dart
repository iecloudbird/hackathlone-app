import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';

/// Reusable animated expandable panel widget that matches our app theme
/// Used for collapsible controls and form sections
class AnimatedExpandablePanel extends StatefulWidget {
  /// Header content (always visible)
  final Widget header;

  /// Expandable content (shown when expanded)
  final Widget content;

  /// Whether the panel is initially expanded
  final bool initiallyExpanded;

  /// Whether the panel is currently expanded (for external control)
  final bool? isExpanded;

  /// Callback when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Animation duration
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Background color
  final Color? backgroundColor;

  /// Border color
  final Color? borderColor;

  /// Border radius
  final double borderRadius;

  /// Padding around the entire panel
  final EdgeInsetsGeometry? margin;

  /// Padding inside the panel
  final EdgeInsetsGeometry? padding;

  /// Whether to show a divider between header and content
  final bool showDivider;

  /// Custom elevation/shadow
  final List<BoxShadow>? boxShadow;

  const AnimatedExpandablePanel({
    super.key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onExpansionChanged,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.margin,
    this.padding,
    this.showDivider = true,
    this.boxShadow,
  });

  @override
  State<AnimatedExpandablePanel> createState() =>
      _AnimatedExpandablePanelState();
}

class _AnimatedExpandablePanelState extends State<AnimatedExpandablePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded ?? widget.initiallyExpanded;

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedExpandablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external control of expansion state
    if (widget.isExpanded != null && widget.isExpanded != _isExpanded) {
      _isExpanded = widget.isExpanded!;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? AppColors.pineTree.withValues(alpha: 0.95);

    final borderColor =
        widget.borderColor ?? AppColors.brightYellow.withValues(alpha: 0.3);

    final boxShadow =
        widget.boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

    return Container(
      margin: widget.margin,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.6, // Limit height to prevent overflow
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (always visible)
            InkWell(
              onTap: _handleTap,
              child: Container(
                padding: widget.padding ?? AppDimensions.paddingAll16,
                child: widget.header,
              ),
            ),

            // Animated expandable content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  // Divider
                  if (widget.showDivider)
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: borderColor,
                    ),

                  // Content with scroll support for overflow
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.4, // Limit content height
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: widget.padding ?? AppDimensions.paddingAll16,
                        child: widget.content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-configured expandable panel for QR scanner controls
class QrScannerControlsPanel extends StatelessWidget {
  /// Current scan type selection
  final String selectedScanType;

  /// Available scan type options
  final Map<String, String> scanTypeOptions;

  /// Whether the panel is expanded
  final bool isExpanded;

  /// Callback when expansion state changes
  final ValueChanged<bool> onExpansionChanged;

  /// Callback when scan type changes
  final ValueChanged<String> onScanTypeChanged;

  /// Additional control widgets to show when expanded
  final List<Widget> additionalControls;

  /// Error message to display
  final String? errorMessage;

  const QrScannerControlsPanel({
    super.key,
    required this.selectedScanType,
    required this.scanTypeOptions,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onScanTypeChanged,
    this.additionalControls = const [],
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedExpandablePanel(
      isExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      header: _buildHeader(),
      content: _buildContent(),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.tune, color: AppColors.brightYellow, size: 20),
        AppDimensions.horizontalSpaceS,
        Expanded(
          child: Text(
            'Scan Controls',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          scanTypeOptions[selectedScanType] ?? selectedScanType,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.brightYellow,
          ),
        ),
        AppDimensions.horizontalSpaceS,
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scan Type Selection
        Text(
          'Scan Type',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        AppDimensions.verticalSpaceS,
        _buildScanTypeSelector(),

        // Additional controls
        if (additionalControls.isNotEmpty) ...[
          AppDimensions.verticalSpaceM,
          ...additionalControls,
        ],

        // Error Display
        if (errorMessage != null) ...[
          AppDimensions.verticalSpaceM,
          _buildErrorCard(errorMessage!),
        ],
      ],
    );
  }

  Widget _buildScanTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.brightYellow.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedScanType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dropdownColor: AppColors.maastrichtBlue,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        items: scanTypeOptions.entries
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onScanTypeChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          AppDimensions.horizontalSpaceS,
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
