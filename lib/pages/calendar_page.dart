import 'dart:collection';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/calendar_helpers.dart';
import 'dart:convert';

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

  Future<Directory?>? _appDocumentsDirectory;

  Future<String> _read() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/daily_results.json');
      if (!await file.exists()) {
        _writeNew();
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
    file.readAsString();
    await file.writeAsString("[]", mode: FileMode.write);
  }

  _writeAppend(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/daily_results.json');
    if (!await file.exists()) {
      _writeNew();
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
    print(jsonBody[0].toString());
    for (var i = 0; i < jsonBody.length; i++) {
      kEventSource[DateTime.parse(jsonBody[i]["date"])] = [
        Event(
          colorRGB: jsonBody[i]["todays_color_rgb"],
          colorName: jsonBody[i]["todays_color_name"],
          score: jsonBody[i]["users_score"],
        )
      ];
    }
    print(kEventSource);
  }

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

  @override
  void initState() {
    super.initState();
    // _writeNew();
    //   _writeAppend(
    //       '{"date" : "${DateTime.now().toString()}", "todays_color_rgb": [93, 138, 168], "todays_color_name": "Color Name", "users_color_rgb": [93, 138, 168], "users_score": 70}');
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
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
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  onTap: () => print('${value[index]}'),
                                  title: Text('${value[index]}'),
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
          ],
        ),
      ),
    );
  }
}
