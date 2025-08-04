import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final Color? accentColor;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppColors.electricBlue;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: accentColor != null ? effectiveAccentColor : Colors.white70,
        ),
        filled: true,
        fillColor: const Color(0xFF131212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: accentColor != null
                ? effectiveAccentColor.withValues(alpha: 0.3)
                : Colors.white24,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: accentColor != null
                ? effectiveAccentColor.withValues(alpha: 0.3)
                : Colors.white24,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: effectiveAccentColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
      ),
      dropdownColor: const Color(0xFF131212),
      style: TextStyle(
        color: accentColor != null ? effectiveAccentColor : Colors.white,
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: accentColor != null ? effectiveAccentColor : Colors.white70,
      ),
      value: value,
      validator: validator,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: accentColor != null ? effectiveAccentColor : Colors.white,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class CustomMultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> selectedItems;
  final List<String> availableItems;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;
  final String? Function(List<String>?)? validator;

  const CustomMultiSelectDropdown({
    super.key,
    required this.label,
    required this.selectedItems,
    required this.availableItems,
    required this.maxSelections,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomMultiSelectDropdown> createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: widget.selectedItems,
      validator: widget.validator,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
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
                child: Row(
                  children: [
                    Expanded(
                      child: widget.selectedItems.isEmpty
                          ? Text(
                              widget.label,
                              style: const TextStyle(color: Colors.white70),
                            )
                          : Wrap(
                              spacing: 4.0,
                              runSpacing: 4.0,
                              children: widget.selectedItems.map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricBlue,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    Icon(
                      _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFF131212),
                  border: Border.all(color: Colors.grey),
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
