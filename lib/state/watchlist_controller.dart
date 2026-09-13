import 'package:flutter/foundation.dart';
import '../data/remote/stock_api_client.dart';
import '../domain/models/domestic_stock.dart';
import '../domain/models/sort_option.dart';
import 'favorite_controller.dart';

class WatchlistController extends ChangeNotifier {
  final StockApiClient _api;
  final FavoriteController _favoriteController;

  WatchlistController(this._api, this._favoriteController) {
    // 관심 상태가 바뀔 때마다 자동으로 동기화 (어느 화면에 있든 상관없이)
    _favoriteController.addListener(_onFavoritesChanged);
    // 생성 시점에 이미 있는 관심종목 즉시 반영
    Future.microtask(() => syncWithFavorites(_favoriteController.favoriteIds));
  }

  void _onFavoritesChanged() {
    syncWithFavorites(_favoriteController.favoriteIds);
  }

  @override
  void dispose() {
    _favoriteController.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  final Map<String, DomesticStock> _stocksById = {};
  SortOption _sortOption = SortOption.nameAsc;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  SortOption get sortOption => _sortOption;
  bool get isEmpty => _stocksById.isEmpty;

  List<DomesticStock> get sortedStocks {
    final list = _stocksById.values.toList();

    // 시세 미수신 행은 정렬 기준과 무관하게 맨 아래 고정
    // (Figma에 정의 없는 부분 - 직접 판단)
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

  Future<void> syncWithFavorites(List<String> canonicalIds) async {
    final currentIds = _stocksById.keys.toSet();
    final newIds = canonicalIds.toSet();

    // 변화가 없으면 불필요한 재요청 방지
    if (currentIds.length == newIds.length && currentIds.containsAll(newIds)) {
      return;
    }

    _stocksById.removeWhere((id, _) => !newIds.contains(id));

    for (final id in canonicalIds) {
      if (!_stocksById.containsKey(id)) {
        final symbol = id.replaceFirst('domestic:', '');
        _stocksById[id] = DomesticStock(
          canonicalId: id,
          symbol: symbol,
          name: symbol,
          market: '',
        );
      }
    }
    notifyListeners();

    await refresh();
  }

  Future<void> refresh() async {
    if (_stocksById.isEmpty) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final symbols = _stocksById.values.map((s) => s.symbol).toList();

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
