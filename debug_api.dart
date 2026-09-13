import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/data/remote/stock_api_client.dart';

const _headers = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
  'Referer': 'https://finance.naver.com/',
};

Future<void> main() async {
  // 1. 검색 자동완성
  final searchUri = Uri.parse('https://ac.stock.naver.com/ac').replace(
    queryParameters: {'q': '삼성전자', 'target': 'stock,ipo,index,marketindicator'},
  );
  final searchRes = await http.get(searchUri, headers: _headers);
  print('=== SEARCH ===');
  print('status: ${searchRes.statusCode}');
  print(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonDecode(utf8.decode(searchRes.bodyBytes))),
  );

  // 2. 실시간 시세
  final realtimeUri = Uri.parse(
    'https://polling.finance.naver.com/api/realtime',
  ).replace(queryParameters: {'query': 'SERVICE_ITEM:005930'});
  final realtimeRes = await http.get(realtimeUri, headers: _headers);
  print('\n=== REALTIME ===');
  print('status: ${realtimeRes.statusCode}');
  print(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonDecode(latin1.decode(realtimeRes.bodyBytes))),
  );

  // 3. 종목 메타데이터
  final metaUri = Uri.parse(
    'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/005930',
  );
  final metaRes = await http.get(metaUri, headers: _headers);
  print('\n=== META ===');
  print('status: ${metaRes.statusCode}');
  print(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonDecode(utf8.decode(metaRes.bodyBytes))),
  );

  // 4. 일별 시세
  await testDailyPrice();
}

Future<void> testDailyPrice() async {
  final api = StockApiClient();
  final result = await api.fetchDailyPricePage(symbol: '005930', page: 1);

  print('\n=== DAILY PRICE (page 1) ===');
  print('lastPage: ${result.lastPage}');
  print('row count: ${result.rows.length}');
  for (final row in result.rows) {
    print(
      '${row.normalizedDate} | close=${row.closePrice} open=${row.openPrice} '
      'high=${row.highPrice} low=${row.lowPrice} vol=${row.volume}',
    );
  }
  api.dispose();
}
