import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/remote/stock_api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/domestic_stock.dart';
import '../../../state/favorite_controller.dart';
import '../../../state/stock_detail_controller.dart';
import '../../../theme/theme.dart';
import '../../widgets/daily_price_table.dart';
import '../../widgets/period_tabs.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/candle_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final String canonicalId;
  const StockDetailScreen({super.key, required this.canonicalId});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final StockDetailController _controller;

  @override
  void initState() {
    super.initState();
    final symbol = widget.canonicalId.replaceFirst('domestic:', '');
    _controller = StockDetailController(
      api: context.read<StockApiClient>(),
      symbol: symbol,
    )..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<StockDetailController>(
        builder: (context, controller, _) {
          final colors = context.colors;
          final dimens = context.dimens;
          final stock = controller.stock;

          if (controller.isLoading || stock == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: colors.accentDefault),
              ),
            );
          }

          final direction = stock.direction;
          final isFavorite = context.watch<FavoriteController>().isFavorite(
            stock.canonicalId,
          );

          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stock.name,
                    style: TextStyle(fontSize: 16, color: colors.textPrimary),
                  ),
                  Text(
                    '${stock.symbol} · ${stock.market}',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite
                        ? colors.favoriteActive
                        : colors.favoriteInactive,
                  ),
                  onPressed: () => context.read<FavoriteController>().toggle(
                    stock.canonicalId,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.all(dimens.space4),
              children: [
                // 현재가 + 등락
                if (stock.hasQuote) ...[
                  Text(
                    AppFormatters.comma(stock.currentPrice!),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: AppTypography.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: dimens.space1),
                  Row(
                    children: [
                      if (direction.name != 'flat')
                        Icon(
                          direction.name == 'up'
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: direction.textColor(colors),
                        ),
                      Text(
                        '${AppFormatters.changeAmount(stock.changeAmount!)} '
                        '${AppFormatters.changeRate(stock.changeRate!)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: direction.textColor(colors),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: dimens.space5),

                // 기간 탭
                PeriodTabs(
                  selected: controller.period,
                  onChanged: (p) => controller.changePeriod(p),
                ),
                SizedBox(height: dimens.space4),

                // 차트 자리 (다음 단계)
                if (controller.isLoadingPeriod)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: dimens.space6),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.accentDefault,
                      ),
                    ),
                  )
                else
                  CandleChart(rows: controller.chronologicalRows),
                SizedBox(height: dimens.space4),

                // 요약 카드
                if (stock.hasQuote)
                  SummaryCard(
                    open: stock.open ?? 0,
                    high: stock.high ?? 0,
                    low: stock.low ?? 0,
                    volume: stock.accumulatedVolume ?? 0,
                    marketCap: stock.marketCap ?? 0,
                  ),
                SizedBox(height: dimens.space5),

                // 일별 시세 표
                if (!controller.isLoadingPeriod)
                  DailyPriceTable(rows: controller.dailyRows),
              ],
            ),
          );
        },
      ),
    );
  }
}
