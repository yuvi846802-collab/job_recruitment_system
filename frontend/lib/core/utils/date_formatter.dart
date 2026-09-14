import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '\$0';
    final double val = double.tryParse(amount.toString()) ?? 0.0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(val);
  }

  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final DateFormat inputFormat = DateFormat('HH:mm:ss');
      final DateTime dt = inputFormat.parse(timeStr);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }
}
