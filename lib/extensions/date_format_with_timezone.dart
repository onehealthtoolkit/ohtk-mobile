import 'package:intl/intl.dart';

/// Extension for DateFormat instance
/// Format date object into string using pattern with ISO date with timezone
/// ie. 2001-02-03T04:05:06.000+07:00
extension DateFormatWithTimeZone on DateFormat {
  String formatWithTimeZone(DateTime dateTime) {
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
