import 'dart:collection';
import 'package:realcolor/utilities/variables/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/calendar_helpers.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  late ValueNotifier<List<Event>> _selectedEvents = ValueNotifier(_getEventsForDay(DateTime.now()));
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.disabled;
  late dynamic jsonBody;
  int highestStreak = 0;
  int currentStreak = 0;
  Map<DateTime, int> dailyScores = {};

  @override
  void initState() {
    super.initState();
    _getStreaks();
    _getDailyScores();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 8, 10),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, day, focusedDay) => buildCellDate(day, dailyScores, focusedDay: focusedDay),
                defaultBuilder: (context, day, focusedDay) => buildCellDate(day, dailyScores),
                todayBuilder: (context, day, focusedDay) => buildCellDate(day, dailyScores),
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
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: FutureBuilder(
                  future: _setup(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return calendarResultsBuilder(_selectedEvents);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: streaksContainer(Colors.blue.shade100, "Highest Streak: ", highestStreak),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: streaksContainer(Colors.orange.shade200, "Current Streak: ", currentStreak),
            ),
          ],
        ),
      ),
    );
  }

  Widget streaksContainer(Color backgroundColor, String text, int streakValue) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(1, 2),
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
              TextSpan(text: text, style: kFontStyleHeader1),
              TextSpan(text: '$streakValue', style: kFontStyleHeader1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getDailyScores() async {
    String body = await readDailyResults();
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

  // this runs any time you click on the calendar, should change it so only the necessary events are in here
  Future<String> _setup() async {
    String body = await readDailyResults();
    // print("finished reading");
    jsonBody = json.decode(body);
    // print("finished decode");
    await populateCalendarEvents(jsonBody);
    // print("finished populating events");
    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEventSource);
    // print("finished adding events");
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    return "Done";
  }

  Future<void> _getStreaks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentStreakPrefs = prefs.getInt('currentStreak');
    if (currentStreakPrefs != null) {
      currentStreak = currentStreakPrefs;
    }
    int? highestStreakPrefs = prefs.getInt('highestStreak');
    if (highestStreakPrefs != null) {
      highestStreak = highestStreakPrefs;
    }
    setState(() {});
  }
}
