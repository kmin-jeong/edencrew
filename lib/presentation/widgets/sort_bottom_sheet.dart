import 'package:flutter/material.dart';
import '../../domain/models/sort_option.dart';
import '../../theme/theme.dart';

Future<SortOption?> showSortBottomSheet(
  BuildContext context, {
  required SortOption current,
}) {
  final colors = context.colors;
  final dimens = context.dimens;

  return showModalBottomSheet<SortOption>(
    context: context,
    backgroundColor: colors.surfaceRaised,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(dimens.radiusLg),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) {
            final selected = option == current;
            return ListTile(
              title: Text(
                option.label,
                style: TextStyle(
                  color: selected ? colors.accentDefault : colors.textPrimary,
                ),
              ),
              trailing: selected
                  ? Icon(Icons.check, color: colors.accentDefault)
                  : null,
              onTap: () => Navigator.pop(context, option),
            );
          }).toList(),
        ),
      );
    },
  );
}
