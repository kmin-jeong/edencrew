import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../theme/theme.dart';

class SummaryCard extends StatelessWidget {
  final int open;
  final int high;
  final int low;
  final int volume;
  final double marketCap;

  const SummaryCard({
    super.key,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.marketCap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;

    final items = [
      ('시가', AppFormatters.comma(open)),
      ('고가', AppFormatters.comma(high)),
      ('저가', AppFormatters.comma(low)),
      ('거래량', AppFormatters.abbreviate(volume)),
      ('시가총액', AppFormatters.abbreviate(marketCap)),
    ];

    return Container(
      padding: EdgeInsets.all(dimens.space4),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(dimens.radiusLg),
        border: Border.all(
          color: colors.borderSubtle,
          width: dimens.borderHairline,
        ),
      ),
      child: Wrap(
        runSpacing: dimens.space3,
        children: items.map((item) {
          return SizedBox(
            width:
                (MediaQuery.of(context).size.width -
                    dimens.space4 * 2 -
                    dimens.space4 * 2) /
                2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
                SizedBox(height: dimens.space1),
                Text(
                  item.$2,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
