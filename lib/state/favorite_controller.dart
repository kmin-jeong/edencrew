import 'package:flutter/foundation.dart';

class FavoriteController extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  bool isFavorite(String canonicalId) => _favoriteIds.contains(canonicalId);

  void toggle(String canonicalId) {
    if (_favoriteIds.contains(canonicalId)) {
      _favoriteIds.remove(canonicalId);
    } else {
      _favoriteIds.add(canonicalId);
    }
    notifyListeners();
  }

  List<String> get favoriteIds => List.unmodifiable(_favoriteIds);
}
