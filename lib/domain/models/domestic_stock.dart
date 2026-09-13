import '../../data/dto/stock_dtos.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum PriceDirection { up, down, flat }

class DomesticStock {
  final String canonicalId;
  final String symbol;
  final String name;
  final String market;

  final int? currentPrice;
  final int? changeAmount;
  final double? changeRate;
  final int? open, high, low, accumulatedVolume;
  final double? marketCap;

  const DomesticStock({
    required this.canonicalId,
    required this.symbol,
    required this.name,
    required this.market,
    this.currentPrice,
    this.changeAmount,
    this.changeRate,
    this.open,
    this.high,
    this.low,
    this.accumulatedVolume,
    this.marketCap,
  });

  bool get hasQuote => currentPrice != null;

  PriceDirection get direction {
    if (changeAmount == null || changeAmount == 0) return PriceDirection.flat;
    return changeAmount! > 0 ? PriceDirection.up : PriceDirection.down;
  }

  static String canonicalIdOf(String symbol) => 'domestic:$symbol';

  factory DomesticStock.fromSearchAndMeta({
    required SearchItemDto search,
    StockMetaDto? meta,
  }) => DomesticStock(
    canonicalId: canonicalIdOf(search.code),
    symbol: search.code,
    name: meta?.stockName ?? search.name,
    market: meta?.stockExchangeNameKor ?? '',
  );

  DomesticStock withQuote(RealtimeQuoteDto quote) => DomesticStock(
    canonicalId: canonicalId,
    symbol: symbol,
    name: name,
    market: market,
    currentPrice: quote.currentPrice,
    changeAmount: quote.changeAmount,
    changeRate: quote.changeRate,
    open: quote.open,
    high: quote.high,
    low: quote.low,
    accumulatedVolume: quote.accumulatedVolume,
    marketCap: quote.marketCap,
  );
}

// domestic_stock.dart 맨 아래에 추가
extension PriceDirectionColors on PriceDirection {
  Color textColor(AppColors colors) => switch (this) {
    PriceDirection.up => colors.priceUpText,
    PriceDirection.down => colors.priceDownText,
    PriceDirection.flat => colors.priceFlatText,
  };

  Color bgColor(AppColors colors) => switch (this) {
    PriceDirection.up => colors.priceUpBg,
    PriceDirection.down => colors.priceDownBg,
    PriceDirection.flat => colors.priceFlatBg,
  };
}
