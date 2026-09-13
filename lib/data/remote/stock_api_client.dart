import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dto/stock_dtos.dart';

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

  void dispose() => _client.close();
}
