import 'package:flutter/material.dart';

class Dropdown<ItemType> extends StatelessWidget {
  final String labelText;
  final List<ItemType> items;
  final ItemType value;
  final ValueChanged<ItemType?> onChanged;
  final String Function(ItemType) formatLabel;

  const Dropdown({
    super.key,
    required this.labelText,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.formatLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<ItemType>(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        initialValue: value,
        items: items
            .map(
              (item) => DropdownMenuItem<ItemType>(
                value: item,
                child: Text(formatLabel(item)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
