import 'package:flutter/foundation.dart';
import '../data/remote/daily_price_repository.dart';
import '../data/remote/daily_sise_parser.dart';
import '../data/remote/stock_api_client.dart';
import '../domain/models/domestic_stock.dart';

class DailyPriceRow {
  final DateTime date;
  final int closePrice;
  final int changeAmount; // 인접 거래일 종가 차이로 직접 계산 (API에 없는 값)
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  DailyPriceRow({
    required this.date,
    required this.closePrice,
    required this.changeAmount,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });
}

class StockDetailController extends ChangeNotifier {
  final StockApiClient _api;
  final DailyPriceRepository _dailyRepo;
  final String symbol;

  StockDetailController({required StockApiClient api, required this.symbol})
    : _api = api,
      _dailyRepo = DailyPriceRepository(api);

  DomesticStock? stock;
  String period = '1M'; // '1M' | '3M' | '6M' | '1Y'
  List<DailyPriceRow> dailyRows = []; // 최신순 (표에 그대로 사용)
  bool isLoading = false;
  bool isLoadingPeriod = false;

  String get canonicalId => DomesticStock.canonicalIdOf(symbol);

  // 차트는 보통 시간순(과거->현재)으로 그리므로 뒤집어서 제공
  List<DailyPriceRow> get chronologicalRows => dailyRows.reversed.toList();

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    try {
      final meta = await _api.fetchStockMeta(symbol);
      stock = DomesticStock(
        canonicalId: canonicalId,
        symbol: symbol,
        name: meta?.stockName ?? symbol,
        market: meta?.stockExchangeNameKor ?? '',
      );
      notifyListeners();

      final quotes = await _api.fetchRealtimeQuotes([symbol]);
      final quote = quotes[symbol];
      if (quote != null) {
        stock = stock!.withQuote(quote);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }

    await changePeriod(period);
  }

  Future<void> changePeriod(String newPeriod) async {
    period = newPeriod;
    isLoadingPeriod = true;
    notifyListeners();

    try {
      final rawRows = await _dailyRepo.fetchForPeriod(
        symbol: symbol,
        period: newPeriod,
      );
      dailyRows = _toDailyPriceRows(rawRows);
    } finally {
      isLoadingPeriod = false;
      notifyListeners();
    }
  }

  // rawRows는 최신순으로 정렬되어 있음 (네이버 응답 특성)
  List<DailyPriceRow> _toDailyPriceRows(List<DailyPriceRawRow> rawRows) {
    final result = <DailyPriceRow>[];
    for (var i = 0; i < rawRows.length; i++) {
      final current = rawRows[i];
      final prevClose = (i + 1 < rawRows.length)
          ? rawRows[i + 1].closePrice
          : null;
      final d = current.normalizedDate; // yyyyMMdd

      result.add(
        DailyPriceRow(
          date: DateTime(
            int.parse(d.substring(0, 4)),
            int.parse(d.substring(4, 6)),
            int.parse(d.substring(6, 8)),
          ),
          closePrice: current.closePrice,
          changeAmount: prevClose == null ? 0 : current.closePrice - prevClose,
          openPrice: current.openPrice,
          highPrice: current.highPrice,
          lowPrice: current.lowPrice,
          volume: current.volume,
        ),
      );
    }
    return result;
  }
}
