import "dart:io";
import 'dart:math';
import "package:flutter/material.dart";
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'package:realcolor/utilities/color_detection.dart';
import 'package:realcolor/utilities/constants.dart';

dynamic getTodaysColor(List colorList) {
  final seed = _getTodaysSeed();
  final random = Random(seed);
  final randomIndex = random.nextInt(colorList.length);
  return colorList[randomIndex];
}

dynamic getRandomColor(List colorList) {
  final random = Random();
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

Widget resultDialog(todaysColorData, BuildContext context, Color usersColor, String imagePath, bool isDaily) {
  final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
  Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
  int score = (100 - getColorScore(usersColor, todaysColor).toInt());
  return AlertDialog.adaptive(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.all(10),
    content: SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: ListBody(
          children: <Widget>[
            Text(
              'Results',
              style: kFontStyleHeader1,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      isDaily ? DateTime.now().toString().split(' ')[0] : "Unlimited",
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
                      isDaily ? "Today's color:" : "Random color",
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
                      height: 250,
                      width: 250,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: "Score: "),
                                TextSpan(text: "${score.toString()}%", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          getScoreText(score),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: Text(
                isDaily ? "Try again tomorrow!" : "Try again?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    actionsAlignment: MainAxisAlignment.spaceBetween,
    actions: <Widget>[
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: Text(
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

Text getScoreText(score) {
  if (score >= 91) {
    return kScoreTextPerfect;
  }
  if (score >= 81) {
    return kScoreTextSuperb;
  }
  if (score >= 71) {
    return kScoreTextGood;
  }
  if (score >= 61) {
    return kScoreTextOkay;
  }
  return kScoreTextBad;
}
