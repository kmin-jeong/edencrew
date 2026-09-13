import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../state/stock_detail_controller.dart';
import '../../theme/theme.dart';

class DailyPriceTable extends StatelessWidget {
  final List<DailyPriceRow> rows;
  const DailyPriceTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;

    return Column(
      children: [
        // 헤더
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dimens.space4,
            vertical: dimens.space2,
          ),
          child: Row(
            children: [
              _headerCell('날짜', colors, flex: 2),
              _headerCell('종가', colors, flex: 2),
              _headerCell('등락', colors, flex: 2),
              _headerCell('거래량', colors, flex: 3),
            ],
          ),
        ),
        Divider(height: 1, color: colors.borderSubtle),
        ...rows.map((row) => _DailyPriceRowItem(row: row)),
      ],
    );
  }

  Widget _headerCell(String label, AppColors colors, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(color: colors.textTertiary, fontSize: 12),
      ),
    );
  }
}

class _DailyPriceRowItem extends StatelessWidget {
  final DailyPriceRow row;
  const _DailyPriceRowItem({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;

    final isUp = row.changeAmount > 0;
    final isDown = row.changeAmount < 0;
    final changeColor = isUp
        ? colors.priceUpText
        : isDown
        ? colors.priceDownText
        : colors.priceFlatText;
    final arrow = isUp ? '▲' : (isDown ? '▼' : '');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dimens.space4,
        vertical: dimens.space2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.monthDay(row.date),
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.comma(row.closePrice),
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$arrow ${AppFormatters.comma(row.changeAmount.abs())}',
              style: TextStyle(color: changeColor, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppFormatters.comma(row.volume),
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
