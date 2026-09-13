import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/domestic_stock.dart';
import '../../theme/theme.dart';
import 'skeleton_box.dart';

class WatchlistItem extends StatelessWidget {
  final DomesticStock stock;
  const WatchlistItem({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;

    if (!stock.hasQuote) {
      return Container(
        constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: dimens.space4,
          vertical: dimens.space2,
        ),
        child: Row(
          children: [
            SkeletonBox(width: 80, height: 14),
            const Spacer(),
            SkeletonBox(width: 60, height: 14),
          ],
        ),
      );
    }

    final direction = stock.direction;

    return Container(
      constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
      padding: EdgeInsets.symmetric(
        horizontal: dimens.space4,
        vertical: dimens.space2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stock.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: AppTypography.medium,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: dimens.space1),
                Text(
                  '${stock.symbol} · ${stock.market}',
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppFormatters.comma(stock.currentPrice!),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: AppTypography.medium,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: dimens.space1),
              Text(
                '${AppFormatters.changeAmount(stock.changeAmount!)} '
                '${AppFormatters.changeRate(stock.changeRate!)}',
                style: TextStyle(
                  color: direction.textColor(colors),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
