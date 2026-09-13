import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/dto/stock_dtos.dart';
import '../data/remote/stock_api_client.dart';

class SearchController extends ChangeNotifier {
  final StockApiClient _api;
  SearchController(this._api);

  String query = '';
  List<SearchItemDto> results = [];
  bool isLoading = false;
  Timer? _debounce;

  void onQueryChanged(String value) {
    query = value;
    notifyListeners();

    _debounce?.cancel();
    if (value.trim().isEmpty) {
      results = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String value) async {
    isLoading = true;
    notifyListeners();
    try {
      results = await _api.searchStocks(value);
    } catch (_) {
      results = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    query = '';
    results = [];
    _debounce?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
