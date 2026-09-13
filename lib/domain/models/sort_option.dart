enum SortOption { priceDesc, changeRateDesc, nameAsc }

extension SortOptionLabel on SortOption {
  String get label => switch (this) {
    SortOption.priceDesc => '현재가순',
    SortOption.changeRateDesc => '등락률순',
    SortOption.nameAsc => '가나다순',
  };
}
