class AppFormatters {
  static final _comma = RegExp(r'(\d)(?=(\d{3})+(?!\d))');

  static String comma(num value) {
    final isNegative = value < 0;
    final intPart = value.abs().toStringAsFixed(0);
    final formatted = intPart.replaceAllMapped(_comma, (m) => '${m[1]},');
    return isNegative ? '-$formatted' : formatted;
  }

  // 등락액: +400 / -400 / 0
  static String changeAmount(int amount) {
    if (amount > 0) return '+${comma(amount)}';
    if (amount < 0) return comma(amount); // comma()가 이미 '-' 붙여줌
    return '0';
  }

  // 등락률: (+0.22%) / (-0.22%) / (0.00%)
  static String changeRate(double rate) {
    final percent = rate * 100;
    final sign = percent > 0 ? '+' : '';
    return '($sign${percent.toStringAsFixed(2)}%)';
  }

  // 날짜: 2026.09.11 -> 09.11
  static String monthDay(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$mm.$dd';
  }

  // 거래량/시가총액 축약: 29113000 -> 29,113천 / 1063000000000000 -> 1,063조
  static String abbreviate(num value) {
    if (value >= 1e12) {
      return '${comma((value / 1e12).floor())}조';
    }
    if (value >= 1e3) {
      return '${comma((value / 1e3).floor())}천';
    }
    return comma(value);
  }
}
