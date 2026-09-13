import 'dart:convert';
import 'package:charset/charset.dart';
import 'package:http/http.dart' as http;
import '../dto/stock_dtos.dart';
import 'daily_sise_parser.dart';

class StockApiClient {
  final http.Client _client;
  StockApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    'Referer': 'https://finance.naver.com/',
  };

  // 1. 검색 자동완성 (UTF-8)
  Future<List<SearchItemDto>> searchStocks(String query) async {
    final uri = Uri.parse('https://ac.stock.naver.com/ac').replace(
      queryParameters: {
        'q': query,
        'target': 'stock,ipo,index,marketindicator',
      },
    );

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('검색 요청 실패: ${res.statusCode}');
    }

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => SearchItemDto.fromJson(e as Map<String, dynamic>))
        .where((item) => item.isValidDomesticStock)
        .toList();
  }

  // 2. 실시간 시세 (여러 종목 한 번에)
  // 이 endpoint는 EUC-KR로 응답을 줌. 우리가 쓰는 필드는 전부 숫자/영문이라
  // latin1로 디코딩해도 JSON 구조는 안 깨짐. 한글 필드(nm 등)는 안 씀.
  Future<Map<String, RealtimeQuoteDto>> fetchRealtimeQuotes(
    List<String> symbols,
  ) async {
    if (symbols.isEmpty) return {};

    final query = symbols.map((s) => 'SERVICE_ITEM:$s').join(',');
    final uri = Uri.parse(
      'https://polling.finance.naver.com/api/realtime',
    ).replace(queryParameters: {'query': query});

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('시세 요청 실패: ${res.statusCode}');
    }

    final body =
        jsonDecode(latin1.decode(res.bodyBytes)) as Map<String, dynamic>;
    final areas = body['result']?['areas'] as List<dynamic>? ?? [];
    final list = areas.isNotEmpty
        ? (areas[0] as Map<String, dynamic>)['datas'] as List<dynamic>? ?? []
        : <dynamic>[];

    final map = <String, RealtimeQuoteDto>{};
    for (final e in list) {
      final dto = RealtimeQuoteDto.fromJson(e as Map<String, dynamic>);
      map[dto.symbol] = dto;
    }
    return map;
  }

  // 3. 종목 메타데이터 (UTF-8)
  Future<StockMetaDto?> fetchStockMeta(String symbol) async {
    final uri = Uri.parse(
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/$symbol',
    );

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) return null;

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return StockMetaDto.fromJson(body);
  }

  // 4. 일별 시세 (HTML, 페이지 단위)
  // 이 endpoint는 EUC-KR 인코딩. euc 패키지로 정확히 디코딩해야 날짜/숫자
  // 텍스트가 안 깨짐 (한글은 안 쓰지만 표 구조 자체가 깨질 수 있음).
  Future<({List<DailyPriceRawRow> rows, int lastPage})> fetchDailyPricePage({
    required String symbol,
    required int page,
  }) async {
    final uri = Uri.parse(
      'https://finance.naver.com/item/sise_day.naver',
    ).replace(queryParameters: {'code': symbol, 'page': '$page'});

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('일별시세 요청 실패: ${res.statusCode}');
    }

    final htmlBody = eucKr.decode(res.bodyBytes);

    return (
      rows: DailySisePageParser.parseRows(htmlBody),
      lastPage: DailySisePageParser.parseLastPage(htmlBody),
    );
  }

  void dispose() => _client.close();
}
