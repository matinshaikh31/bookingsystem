import 'package:intl/intl.dart';

class DateHelper {
  /// Formats to 'yyyy-MM-dd' (e.g. '2026-06-10')
  static String formatToYmd(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats to 'dd MMM, yyyy' (e.g. '10 Jun, 2026')
  static String formatToDmy(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date);
  }

  /// Formats to 'EEE' (e.g. 'Wed')
  static String formatToEee(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Formats to 'dd' (e.g. '10')
  static String formatToDd(DateTime date) {
    return DateFormat('dd').format(date);
  }

  /// Formats to 'EEE, MMM d' (e.g. 'Wed, Jun 10')
  static String formatToEeemmd(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  /// Formats to 'MMMM yyyy' (e.g. 'June 2026')
  static String formatToMy(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Formats to 'hh:mm a' (e.g. '10:00 PM')
  static String formatToHma(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Parses a string formatted in 'hh:mm a' back to DateTime
  static DateTime parseHma(String timeStr) {
    return DateFormat('hh:mm a').parse(timeStr);
  }
}
