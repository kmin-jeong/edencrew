import 'dart:convert';
import 'package:http/http.dart' as http;

const _headers = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
  'Referer': 'https://finance.naver.com/',
};

Future<void> main() async {
  // 1. 검색 자동완성 (UTF-8 정상)
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

  // 2. 실시간 시세 (EUC-KR로 응답 옴 -> latin1로 디코딩)
  // 사용하는 필드(cd, nv, pcv, ov, hv, lv, aq, countOfListedStock)는
  // 전부 숫자/영문이라 latin1로 디코딩해도 JSON 구조는 깨지지 않음.
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

  // 3. 종목 메타데이터 (UTF-8 정상)
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
}
