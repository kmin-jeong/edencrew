import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class PeriodTabs extends StatelessWidget {
  static const _periods = [
    ('1M', '1개월'),
    ('3M', '3개월'),
    ('6M', '6개월'),
    ('1Y', '1년'),
  ];

  final String selected;
  final ValueChanged<String> onChanged;

  const PeriodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;

    return Row(
      children: _periods.map((p) {
        final isSelected = p.$1 == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p.$1),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: dimens.space1),
              padding: EdgeInsets.symmetric(vertical: dimens.space2),
              decoration: BoxDecoration(
                color: isSelected ? colors.accentBg : Colors.transparent,
                borderRadius: BorderRadius.circular(dimens.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(
                p.$2,
                style: TextStyle(
                  color: isSelected
                      ? colors.accentDefault
                      : colors.textSecondary,
                  fontWeight: isSelected
                      ? AppTypography.medium
                      : AppTypography.regular,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
