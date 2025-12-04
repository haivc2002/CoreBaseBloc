import 'package:intl/intl.dart';

extension DateTimeFlexibleFormat on Object? {

  DateTime? _toDateTime() {
    if (this == null) return null;
    if (this is DateTime) return this as DateTime;
    if (this is String) {
      final raw = this as String;
      try {
        return DateTime.parse(raw);
      } catch (_) {}
      try {
        return DateFormat("dd/MM/yyyy").parse(raw);
      } catch (_) {}
      return null;
    }
    return null;
  }

  String fDateTime([String pattern = "dd/MM/yyyy"]) {
    final date = _toDateTime();
    if (date == null) return "";
    return DateFormat(pattern).format(date);
  }

  String get weekdayName {
    final date = _toDateTime();
    if (date == null) return "";
    const weekdays = [
      'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ Nhật'
    ];
    return weekdays[date.weekday - 1];
  }

  bool isSameDate(DateTime other) {
    if(this is DateTime) {
      final d = this as DateTime;
      return d.year == other.year && d.month == other.month && d.day == other.day;
    } else {
      throw Exception("chưa phát triển string");
    }
  }

}

