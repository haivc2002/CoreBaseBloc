import 'package:intl/intl.dart';

extension DateTimeFlexibleFormat on Object? {

  DateTime? _toDateTime() {
    if (this == null) return null;
    if (this is DateTime) return this as DateTime;
    String raw = toString().trim();
    raw = raw.replaceAll(RegExp(r'\.\d+$'), '');
    if (raw.contains('T') || raw.endsWith('Z')) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }
    final patterns = [
      "HH:mm:ss dd/MM/yyyy",
      "HH:mm:ss dd-MM-yyyy",
      "dd/MM/yyyy HH:mm:ss",
      "dd-MM-yyyy HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy/MM/dd HH:mm:ss",
      "yyyy-MM-dd",
      "dd/MM/yyyy",
      "dd-MM-yyyy",
    ];
    for (final p in patterns) {
      try {
        return DateFormat(p, 'vi_VN').parseLoose(raw).toLocal();
      } catch (_) {}
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
    final weekdays = [
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

  DateTime? get toDateTime => _toDateTime();
}

