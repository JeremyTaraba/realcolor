import 'dart:math';
import "package:flutter/material.dart";

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

Widget resultDialog(todaysColorData, BuildContext context) {
  final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
  return AlertDialog.adaptive(
    title: const Text(
      'Results',
      style: TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
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
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Text(
                  todaysColorData["name"],
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    color: Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1),
                  ),
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
                RichText(
                  textAlign: TextAlign.center,
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "Score "),
                      TextSpan(text: "70%", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\nCome back tomorrow to try again!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
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
