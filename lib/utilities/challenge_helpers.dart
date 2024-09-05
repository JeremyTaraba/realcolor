import "dart:io";
import 'dart:math';
import "package:flutter/material.dart";
import 'package:realcolor/utilities/color_detection.dart';

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

Widget resultDialog(todaysColorData, BuildContext context, Color usersColor, String imagePath) {
  final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
  Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
  return AlertDialog.adaptive(
    insetPadding: EdgeInsets.all(10),
    title: const Text(
      'Results',
      style: TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    content: SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: ListBody(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Text(
                  "Today's color:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  todaysColorData["name"],
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 30,
                  width: 30,
                  color: todaysColor,
                ),
                Text(
                  todaysColorData["hex"].toString().toUpperCase(),
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Text(
                  "Your Color",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 200,
                  width: 200,
                  child: Image.file(
                    File(imagePath),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    color: usersColor,
                  ),
                ),
                Text(
                  "#${usersColor.value.toRadixString(16).substring(2, 8).toUpperCase()}",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: "Score: "),
                        TextSpan(
                            text: (100 - getColorScore(usersColor, todaysColor).toInt()).toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              "Try again tomorrow!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    ),
    actionsAlignment: MainAxisAlignment.spaceBetween,
    actions: <Widget>[
      TextButton(
        child: const Text(
          'Back',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        onPressed: () {
          Navigator.of(context)
            ..pop()
            ..pop();
        },
      ),
    ],
  );
}
