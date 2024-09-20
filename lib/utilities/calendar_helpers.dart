import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realcolor/utilities/variables/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

import 'challenge_helpers.dart';

class Event {
  List<dynamic> colorRGB;
  final String colorName;
  final int score;
  List<dynamic> userColorRGB;
  DateTime day;

  Event({required this.colorRGB, required this.colorName, required this.score, required this.userColorRGB, required this.day});

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

Color _getColorFromScore(score) {
  if (score >= 91) {
    return Colors.purple.shade300;
  } else if (score >= 81) {
    return Colors.blue.shade300;
  } else if (score >= 71) {
    return Colors.green.shade300;
  } else if (score >= 61) {
    return Colors.orange.shade300;
  } else if (score >= 0) {
    return Colors.red.shade300;
  } else {
    return Colors.white;
  }
}

Future<void> populateCalendarEvents(jsonBody) async {
  kEventSource = {};
  for (var i = 0; i < jsonBody.length; i++) {
    kEventSource[DateTime.parse(jsonBody[i]["date"])] = [
      Event(
        colorRGB: jsonBody[i]["todays_color_rgb"],
        colorName: jsonBody[i]["todays_color_name"],
        score: jsonBody[i]["users_score"],
        userColorRGB: jsonBody[i]["users_color_rgb"],
        day: DateTime.parse(jsonBody[i]["date"]),
      )
    ];
  }
  // print(kEventSource);
}

Future<String> readDailyResults() async {
  String text = "";
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/daily_results.json');
    if (!await file.exists()) {
      writeNewDailyResults();
      file = File('${directory.path}/daily_results.json');
    }
    text = await file.readAsString();
    // print(text);
  } catch (e) {
    if (kDebugMode) {
      print("Couldn't read file: $e");
    }
  }
  return text;
}

writeNewDailyResults() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/daily_results.json');
  await file.writeAsString("[]", mode: FileMode.write);
}

Widget buildCellDate(DateTime day, Map<DateTime, int> calendarScores, {DateTime? focusedDay}) {
  DateTime justDay = DateTime(day.year, day.month, day.day);
  int? score = calendarScores[justDay];
  score ??= -1;
  Color boxColor = _getColorFromScore(score);
  return Container(
    margin: const EdgeInsets.all(3),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: (day == focusedDay) ? BoxShape.circle : BoxShape.rectangle,
      color: (day == focusedDay)
          ? boxColor == Colors.white
              ? Colors.grey.shade400
              : boxColor.withOpacity(0.9)
          : boxColor,
      borderRadius: (day == focusedDay) ? null : BorderRadius.circular(4),
    ),
    child: Text(
      day.day.toString(),
      style: const TextStyle(color: Colors.black),
    ),
  );
}

ValueListenableBuilder calendarResultsBuilder(selectedEvents) {
  return ValueListenableBuilder<List<Event>>(
    valueListenable: selectedEvents,
    builder: (context, value, _) {
      return ListView.builder(
        itemCount: value.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "${value[index].day.month}/${value[index].day.day} Results",
                    textScaler: TextScaler.noScaling,
                    style: kFontStyleHeader1,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  Text(
                    value[index].colorName,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Daily Color: ",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        color: Color.fromRGBO(value[index].colorRGB[0], value[index].colorRGB[1], value[index].colorRGB[2], 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Your Color: ",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        color: Color.fromRGBO(value[index].userColorRGB[0], value[index].userColorRGB[1], value[index].userColorRGB[2], 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: "Match: "),
                        TextSpan(text: "${value[index].score.toString()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  getScoreText(value[index].score),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
