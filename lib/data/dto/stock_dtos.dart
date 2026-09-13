// 1. 검색 자동완성
class SearchItemDto {
  final String code;
  final String name;
  final String typeCode;
  final String typeName; // 추가: "코스피" 같은 표시용 시장명
  final String nationCode;

  SearchItemDto({
    required this.code,
    required this.name,
    required this.typeCode,
    required this.typeName,
    required this.nationCode,
  });

  factory SearchItemDto.fromJson(Map<String, dynamic> json) => SearchItemDto(
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    typeCode: json['typeCode'] as String? ?? '',
    typeName: json['typeName'] as String? ?? '',
    nationCode: json['nationCode'] as String? ?? '',
  );

  bool get isValidDomesticStock =>
      nationCode == 'KOR' && RegExp(r'^\d{6}$').hasMatch(code);
}

// 2. 실시간 시세
class RealtimeQuoteDto {
  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int open;
  final int high;
  final int low;
  final int accumulatedVolume;
  final int listedStockCount;

  RealtimeQuoteDto({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.accumulatedVolume,
    required this.listedStockCount,
  });

  factory RealtimeQuoteDto.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return RealtimeQuoteDto(
      symbol: json['cd'] as String? ?? '',
      currentPrice: _toInt(json['nv']),
      previousClose: _toInt(json['pcv']),
      open: _toInt(json['ov']),
      high: _toInt(json['hv']),
      low: _toInt(json['lv']),
      accumulatedVolume: _toInt(json['aq']),
      listedStockCount: _toInt(json['countOfListedStock']),
    );
  }

  int get changeAmount => currentPrice - previousClose;
  double get changeRate =>
      previousClose == 0 ? 0 : changeAmount / previousClose;
  double get marketCap => currentPrice.toDouble() * listedStockCount;
}

// 3. 종목 메타데이터
class StockMetaDto {
  final String symbolCode;
  final String stockName;
  final String stockExchangeNameKor;

  StockMetaDto({
    required this.symbolCode,
    required this.stockName,
    required this.stockExchangeNameKor,
  });

  factory StockMetaDto.fromJson(Map<String, dynamic> json) => StockMetaDto(
    symbolCode: json['symbolCode'] as String? ?? '',
    stockName: json['stockName'] as String? ?? '',
    stockExchangeNameKor: json['stockExchangeNameKor'] as String? ?? '',
  );
}

// 4. 일별 시세 (HTML 파싱 결과를 담을 그릇 - 파싱 로직은 다음 단계에서)
class DailyPriceDto {
  final DateTime date;
  final int closePrice;
  final int changeAmount; // 전일 대비, 표에서 부호+색상 표시용
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  DailyPriceDto({
    required this.date,
    required this.closePrice,
    required this.changeAmount,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });
}
