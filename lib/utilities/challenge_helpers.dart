import "package:flutter/material.dart";
import 'dart:math';

Color getTodaysColor() {
  List<int> allColorsHex = [0xFFC543CE, 0xFFCC79FF, 0xFF33D78D, 0xFF389CE3, 0xFFFFED67, 0xFFFF8B32];
  final seed = getTodaysSeed();
  final random = Random(seed);
  final randomIndex = random.nextInt(allColorsHex.length);
  return Color(allColorsHex[randomIndex]);
}

int getTodaysSeed() {
  DateTime today = DateTime.now();
  int year = today.year;
  int month = today.month;
  int day = today.day;
  int seed = ((year - 2000) * 366) + (month * 31) + day;
  return seed;
}
