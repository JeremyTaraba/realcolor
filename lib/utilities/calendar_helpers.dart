import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  List<dynamic> colorRGB;
  final String colorName;
  final int score;

  Event({required this.colorRGB, required this.colorName, required this.score});

  @override
  String toString() => colorName;
}

Map<DateTime, List<Event>> kEventSource = {};

var kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(kEventSource);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
