import 'package:html/parser.dart' as html_parser;

class DailyPriceRawRow {
  final String dateText; // "2026.09.11"
  final int closePrice;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;

  DailyPriceRawRow({
    required this.dateText,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  // "2026.09.11" -> "20260911"
  String get normalizedDate => dateText.replaceAll('.', '');
}

class DailySisePageParser {
  static int _parseNum(String raw) => int.parse(raw.replaceAll(',', '').trim());

  // 표 순서: 날짜, 종가, 전일비(스킵), 시가, 고가, 저가, 거래량
  static List<DailyPriceRawRow> parseRows(String htmlBody) {
    final document = html_parser.parse(htmlBody);
    final rows = document.querySelectorAll('table.type2 tr');

    final result = <DailyPriceRawRow>[];
    for (final row in rows) {
      if (!row.attributes.containsKey('onmouseover')) continue; // 데이터 행만

      final cells = row.querySelectorAll('td');
      if (cells.length < 7) continue;

      final dateText = cells[0].text.trim();
      if (dateText.isEmpty) continue;

      result.add(
        DailyPriceRawRow(
          dateText: dateText,
          closePrice: _parseNum(cells[1].text),
          openPrice: _parseNum(cells[3].text),
          highPrice: _parseNum(cells[4].text),
          lowPrice: _parseNum(cells[5].text),
          volume: _parseNum(cells[6].text),
        ),
      );
    }
    return result;
  }

  // 페이지네이션의 '맨뒤' 링크에서 마지막 페이지 번호 추출
  static int parseLastPage(String htmlBody) {
    final document = html_parser.parse(htmlBody);
    final lastLink = document.querySelector('table.Nnavi td.pgRR a');
    if (lastLink == null) return 1;

    final href = lastLink.attributes['href'] ?? '';
    final uri = Uri.parse('https://finance.naver.com$href');
    return int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
  }
}
