import 'package:flutter/material.dart';
import '../../state/stock_detail_controller.dart';
import '../../theme/theme.dart';

class CandleChart extends StatelessWidget {
  final List<DailyPriceRow> rows; // 시간순(과거->현재)이어야 함
  const CandleChart({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (rows.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: TextStyle(color: colors.textTertiary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(
        painter: _CandleChartPainter(rows: rows, colors: colors),
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  final List<DailyPriceRow> rows;
  final AppColors colors;

  _CandleChartPainter({required this.rows, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final highs = rows.map((r) => r.highPrice);
    final lows = rows.map((r) => r.lowPrice);
    final maxPrice = highs.reduce((a, b) => a > b ? a : b);
    final minPrice = lows.reduce((a, b) => a < b ? a : b);
    final priceRange = (maxPrice - minPrice).toDouble();
    if (priceRange == 0) return;

    // 위아래 여백을 둬서 캔들이 꽉 차 보이지 않게
    const topPadding = 12.0;
    const bottomPadding = 12.0;
    final chartHeight = size.height - topPadding - bottomPadding;

    final candleSlotWidth = size.width / rows.length;
    final candleBodyWidth = (candleSlotWidth * 0.6).clamp(1.0, 12.0);

    double yFor(int price) {
      final ratio = (price - minPrice) / priceRange;
      return topPadding + chartHeight - (ratio * chartHeight);
    }

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final centerX = candleSlotWidth * i + candleSlotWidth / 2;

      // 등락(changeAmount)은 전일 종가 대비이지만, 캔들 색상은 관례상
      // 해당일 시가 대비 종가로 표현 (일별시세표의 등락 색상과는 별개 기준)
      final isUp = row.closePrice >= row.openPrice;
      final color = isUp ? colors.chartLineUp : colors.chartLineDown;

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1;
      final bodyPaint = Paint()..color = color;

      // 꼬리 (고가 - 저가)
      canvas.drawLine(
        Offset(centerX, yFor(row.highPrice)),
        Offset(centerX, yFor(row.lowPrice)),
        wickPaint,
      );

      // 몸통 (시가 - 종가)
      final bodyTop = yFor(
        row.openPrice > row.closePrice ? row.openPrice : row.closePrice,
      );
      final bodyBottom = yFor(
        row.openPrice > row.closePrice ? row.closePrice : row.openPrice,
      );
      final bodyHeight = (bodyBottom - bodyTop).clamp(1.0, double.infinity);

      canvas.drawRect(
        Rect.fromLTWH(
          centerX - candleBodyWidth / 2,
          bodyTop,
          candleBodyWidth,
          bodyHeight,
        ),
        bodyPaint,
      );
    }

    // 기준선 (첫 거래일 종가 기준 가로 baseline)
    final baselinePaint = Paint()
      ..color = colors.chartBaseline
      ..strokeWidth = 1;
    final baselineY = yFor(rows.first.closePrice);
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      baselinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return oldDelegate.rows != rows;
  }
}
