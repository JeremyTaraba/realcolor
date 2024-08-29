import 'dart:math';

dynamic getTodaysColor(List colorList) {
  final seed = _getTodaysSeed();
  final random = Random(seed);
  final randomIndex = random.nextInt(colorList.length);
  return colorList[randomIndex];
}

int _getTodaysSeed() {
  DateTime today = DateTime.now();
  int year = today.year;
  int month = today.month;
  int day = today.day;
  int seed = ((year - 2000) * 366) + (month * 31) + day;
  return seed;
}
