import 'daily_sise_parser.dart';
import 'stock_api_client.dart';

class DailyPriceRepository {
  final StockApiClient _api;
  DailyPriceRepository(this._api);

  // symbol -> page -> rows (한번 받은 페이지는 재사용)
  final Map<String, Map<int, List<DailyPriceRawRow>>> _cache = {};
  final Map<String, int> _lastPageCache = {};

  static const _pagesByPeriod = {'1M': 2, '3M': 6, '6M': 12, '1Y': 25};

  Future<List<DailyPriceRawRow>> fetchForPeriod({
    required String symbol,
    required String period, // '1M' | '3M' | '6M' | '1Y'
  }) async {
    final requiredPages = _pagesByPeriod[period]!;
    final symbolCache = _cache.putIfAbsent(symbol, () => {});

    // lastPage를 모르면 1페이지 먼저 받아서 확인
    var lastPage = _lastPageCache[symbol];
    if (lastPage == null) {
      final first = await _api.fetchDailyPricePage(symbol: symbol, page: 1);
      symbolCache[1] = first.rows;
      lastPage = first.lastPage;
      _lastPageCache[symbol] = lastPage;
    }

    // lastPage보다 많이 요청하지 않도록 제한
    final targetPages = requiredPages > lastPage ? lastPage : requiredPages;

    for (var page = 1; page <= targetPages; page++) {
      if (symbolCache.containsKey(page)) continue; // 이미 받은 페이지 재사용
      final result = await _api.fetchDailyPricePage(symbol: symbol, page: page);
      symbolCache[page] = result.rows;
    }

    final rows = <DailyPriceRawRow>[];
    for (var page = 1; page <= targetPages; page++) {
      rows.addAll(symbolCache[page] ?? []);
    }
    return rows;
  }
}
