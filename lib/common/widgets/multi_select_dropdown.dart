import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> selectedItems;
  final List<String> availableItems;
  final int maxSelections;
  final String? hintText;
  final ValueChanged<List<String>> onChanged;
  final String? Function(List<String>?)? validator;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.selectedItems,
    required this.availableItems,
    required this.maxSelections,
    required this.onChanged,
    this.hintText,
    this.validator,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isExpanded = false;

  void _removeItem(String item) {
    List<String> newSelection = List.from(widget.selectedItems);
    newSelection.remove(item);
    widget.onChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: widget.selectedItems,
      validator: widget.validator,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.label.isNotEmpty) ...[
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Header Container with selected chips
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF131212),
                border: Border.all(
                  color: state.hasError
                      ? Colors.red
                      : (_isExpanded ? AppColors.electricBlue : Colors.grey),
                  width: _isExpanded ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with hint/count and arrow
                  Row(
                    children: [
                      Expanded(
                        child: widget.selectedItems.isEmpty
                            ? Text(
                                widget.hintText ?? 'Select items...',
                                style: const TextStyle(color: Colors.white54),
                              )
                            : Text(
                                '${widget.selectedItems.length}/${widget.maxSelections} selected',
                                style: const TextStyle(color: Colors.white70),
                              ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Icon(
                          _isExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  // Selected items as chips
                  if (widget.selectedItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 6.0,
                      children: widget.selectedItems.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: AppColors.electricBlue),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeItem(item),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Dropdown list (appears below when expanded)
            if (_isExpanded) ...[
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 150), // ~3 items
                decoration: BoxDecoration(
                  color: const Color(0xFF131212),
                  border: Border.all(color: AppColors.electricBlue),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.availableItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.availableItems[index];
                    final isSelected = widget.selectedItems.contains(item);
                    final canSelect =
                        widget.selectedItems.length < widget.maxSelections;

                    return CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          color: (!canSelect && !isSelected)
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (!canSelect && !isSelected)
                          ? null
                          : (bool? value) {
                              List<String> newSelection = List.from(
                                widget.selectedItems,
                              );
                              if (value == true) {
                                if (!newSelection.contains(item)) {
                                  newSelection.add(item);
                                }
                              } else {
                                newSelection.remove(item);
                              }
                              widget.onChanged(newSelection);
                              state.didChange(newSelection);
                            },
                      checkColor: Colors.white,
                      activeColor: AppColors.electricBlue,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
            ],

            // Error message
            if (state.hasError) ...[
              const SizedBox(height: 8),
              Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}
