import 'package:intl/intl.dart';

/// Extension for DateFormat
/// Format date object into string using ISO pattern plus timezone offset
/// ie. 2001-02-03T04:05:06.000+07:00
///
/// Example usage:
///
/// var dateStr = "2020-06-14T18:55:21.000+07:00";
/// var dateValue = new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ")
///       .parse("2020-06-14T18:55:21.000+07:00", false)
///       .toLocal();
///
/// var isoStr = DateFormatWithTimeZone.toISOString(dateValue);
///
/// assert(dateStr == isoStr);
///j
// TODO ตรวจสอบว่าใช้งานอยู่หรือไม่
extension DateFormatWithTimeZone on DateFormat {
  static String toISOString(DateTime dateTime) {
    var result = StringBuffer();
    result.write(
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime.toLocal()));

    var offset = dateTime.timeZoneOffset;
    var hours =
        offset.inHours > 0 ? offset.inHours : 1; // For fixing divide by 0

    if (!offset.isNegative) {
      result.writeAll([
        "+",
        offset.inHours.toString().padLeft(2, '0'),
        ":",
        (offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')
      ]);
    } else {
      result.writeAll([
        "-",
        (-offset.inHours).toString().padLeft(2, '0'),
        ":",
        (offset.inMinutes % (hours * 60)).toString().padLeft(2, '0')
      ]);
    }
    return result.toString();
  }
}
