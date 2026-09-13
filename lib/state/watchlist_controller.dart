import 'package:flutter/foundation.dart';
import '../data/remote/stock_api_client.dart';
import '../domain/models/domestic_stock.dart';
import '../domain/models/sort_option.dart';

class WatchlistController extends ChangeNotifier {
  final StockApiClient _api;
  WatchlistController(this._api);

  final Map<String, DomesticStock> _stocksById = {};
  SortOption _sortOption = SortOption.nameAsc;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  SortOption get sortOption => _sortOption;
  bool get isEmpty => _stocksById.isEmpty;

  List<DomesticStock> get sortedStocks {
    final list = _stocksById.values.toList();

    // 시세 미수신 행(hasQuote == false)은 정렬 기준과 무관하게 맨 아래 고정
    // (Figma에 정의 없는 부분 - 직접 판단: 데이터 없는 행이 위쪽에 섞이면
    // 사용자 혼란을 줄 수 있어 항상 리스트 맨 아래로 고정)
    final withQuote = list.where((s) => s.hasQuote).toList();
    final withoutQuote = list.where((s) => !s.hasQuote).toList();

    withQuote.sort((a, b) {
      switch (_sortOption) {
        case SortOption.priceDesc:
          return (b.currentPrice ?? 0).compareTo(a.currentPrice ?? 0);
        case SortOption.changeRateDesc:
          return (b.changeRate ?? 0).compareTo(a.changeRate ?? 0);
        case SortOption.nameAsc:
          return a.name.compareTo(b.name);
      }
    });

    return [...withQuote, ...withoutQuote];
  }

  void changeSort(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // 관심종목 id 목록(FavoriteController에서 옴)을 받아 메타+시세를 채움
  Future<void> syncWithFavorites(List<String> canonicalIds) async {
    // 관심 해제된 종목은 목록에서 제거
    _stocksById.removeWhere((id, _) => !canonicalIds.contains(id));

    // 새로 추가된 종목은 스켈레톤 상태로 우선 등록
    for (final id in canonicalIds) {
      if (!_stocksById.containsKey(id)) {
        final symbol = id.replaceFirst('domestic:', '');
        _stocksById[id] = DomesticStock(
          canonicalId: id,
          symbol: symbol,
          name: symbol, // 메타 오기 전 임시 표시
          market: '',
        );
      }
    }
    notifyListeners(); // 스켈레톤 먼저 보여주기

    await refresh();
  }

  Future<void> refresh() async {
    if (_stocksById.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final symbols = _stocksById.values.map((s) => s.symbol).toList();

      // 메타데이터는 종목별 개별 호출 (API 자체가 단건 조회만 지원)
      final metaResults = await Future.wait(
        symbols.map((s) => _api.fetchStockMeta(s)),
      );

      for (var i = 0; i < symbols.length; i++) {
        final meta = metaResults[i];
        if (meta == null) continue;
        final id = DomesticStock.canonicalIdOf(symbols[i]);
        final current = _stocksById[id];
        if (current == null) continue;
        _stocksById[id] = DomesticStock(
          canonicalId: current.canonicalId,
          symbol: current.symbol,
          name: meta.stockName,
          market: meta.stockExchangeNameKor,
          currentPrice: current.currentPrice,
          changeAmount: current.changeAmount,
          changeRate: current.changeRate,
          open: current.open,
          high: current.high,
          low: current.low,
          accumulatedVolume: current.accumulatedVolume,
          marketCap: current.marketCap,
        );
      }

      // 실시간 시세는 한 번의 요청으로 전체 조회
      final quotes = await _api.fetchRealtimeQuotes(symbols);
      for (final entry in quotes.entries) {
        final id = DomesticStock.canonicalIdOf(entry.key);
        final current = _stocksById[id];
        if (current == null) continue;
        _stocksById[id] = current.withQuote(entry.value);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
