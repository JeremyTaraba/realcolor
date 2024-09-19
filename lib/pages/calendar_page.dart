import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realcolor/utilities/variables/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/calendar_helpers.dart';
import 'dart:convert';

import '../utilities/challenge_helpers.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

//TODO: add a current streak and also longest streak to the bottom

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  late ValueNotifier<List<Event>> _selectedEvents = ValueNotifier(_getEventsForDay(DateTime.now()));
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.disabled;
  late dynamic jsonBody;
  int highestStreak = 0;
  int currentStreak = 0;
  Map<DateTime, int> dailyScores = {};

  Future<String> _read() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      File file = File('${directory.path}/daily_results.json');
      if (!await file.exists()) {
        _writeNew();
        file = File('${directory.path}/daily_results.json');
      }
      text = await file.readAsString();
      print(text);
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  _writeNew() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/daily_results.json');
    await file.writeAsString("[]", mode: FileMode.write);
  }

  _writeAppend(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/daily_results.json');
    if (!await file.exists()) {
      _writeNew();
      file = File('${directory.path}/daily_results.json');
    }
    // read file and edit the existing text, then write editted text to file
    String fileText = await file.readAsString();
    String newFileText = "";
    // need to add text without trailing comma
    if (fileText == "[]") {
      newFileText = "[$text]";
    } else {
      newFileText = fileText.substring(0, fileText.length - 1);
      print(newFileText);
      newFileText += ",$text]";
    }
    await file.writeAsString(newFileText, mode: FileMode.write);
  }

  Future<void> _populateEvents(jsonBody) async {
    kEventSource = {};
    for (var i = 0; i < jsonBody.length; i++) {
      kEventSource[DateTime.parse(jsonBody[i]["date"])] = [
        Event(
          colorRGB: jsonBody[i]["todays_color_rgb"],
          colorName: jsonBody[i]["todays_color_name"],
          score: jsonBody[i]["users_score"],
          userColorRGB: jsonBody[i]["users_color_rgb"],
        )
      ];
    }
    print(kEventSource);
  }

  Future<void> _getStreaks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentStreakPrefs = prefs.getInt('currentStreak');
    print("getting streaks");
    if (currentStreakPrefs != null) {
      print("got current streak");
      currentStreak = currentStreakPrefs;
    }
    int? highestStreakPrefs = prefs.getInt('highestStreak');
    if (highestStreakPrefs != null) {
      highestStreak = highestStreakPrefs;
    }
    setState(() {});
  }

  // this runs any time you click on the calendar, should put only the reading events in here
  Future<String> _setup() async {
    String body = await _read();
    print("finished reading");
    jsonBody = json.decode(body);
    print("finished decode");
    await _populateEvents(jsonBody);
    print("finished populating events");
    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEventSource);
    print("finished adding events");
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    return "Done";
  }

  Future<void> _getDailyScores() async {
    String body = await _read();
    jsonBody = json.decode(body);
    DateTime dayWithTime;
    DateTime justDay;
    for (var i = 0; i < jsonBody.length; i++) {
      dayWithTime = DateTime.parse(jsonBody[i]["date"]);
      justDay = DateTime(dayWithTime.year, dayWithTime.month, dayWithTime.day);
      dailyScores[justDay] = jsonBody[i]["users_score"];
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getStreaks();
    _getDailyScores();
    // _writeNew();
    // _writeAppend(
    //     '{"date" : "${DateTime.now().subtract(Duration(days: 4)).toString()}", "todays_color_rgb": [93, 138, 168], "todays_color_name": "Color Name", "users_color_rgb": [40, 138, 16], "users_score": 72}');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
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

  Widget _buildCellDate(DateTime day, Map<DateTime, int> calendarScores, {DateTime? focusedDay}) {
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
                : boxColor.withOpacity(0.8)
            : boxColor,
        borderRadius: (day == focusedDay) ? null : BorderRadius.circular(4),
      ),
      child: Text(
        day.day.toString(),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 7, 10),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, day, focusedDay) => _buildCellDate(day, dailyScores, focusedDay: focusedDay),
                defaultBuilder: (context, day, focusedDay) => _buildCellDate(day, dailyScores),
                todayBuilder: (context, day, focusedDay) => _buildCellDate(day, dailyScores),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: FutureBuilder(
                  future: _setup(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ValueListenableBuilder<List<Event>>(
                        valueListenable: _selectedEvents,
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
                                      offset: Offset(1, 2),
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Results",
                                        style: kFontStyleHeader1,
                                      ),
                                      const Divider(
                                        thickness: 2,
                                      ),
                                      Text(
                                        value[index].colorName,
                                        style: TextStyle(fontSize: 24),
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
                                            color: Color.fromRGBO(
                                                value[index].userColorRGB[0], value[index].userColorRGB[1], value[index].userColorRGB[2], 1),
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
                                            TextSpan(text: "Match: "),
                                            TextSpan(text: "${value[index].score.toString()}%", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(1, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    // textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: "Highest Streak: ", style: kFontStyleHeader1),
                        TextSpan(text: '$highestStreak', style: kFontStyleHeader1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 3,
                        offset: Offset(1, 2),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    // textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: "Current Streak: ", style: kFontStyleHeader1),
                        TextSpan(text: '$currentStreak', style: kFontStyleHeader1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
