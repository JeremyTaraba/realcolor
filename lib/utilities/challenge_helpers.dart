import "dart:io";
import 'dart:math';
import "package:flutter/material.dart";
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'package:realcolor/utilities/color_detection.dart';
import 'package:realcolor/utilities/variables/constants.dart';

import 'variables/globals.dart';

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

Widget resultDialog(todaysColorData, BuildContext context, Color usersColor, String imagePath, bool isDaily, {bool secondAttempt = false}) {
  final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
  Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
  int score = (100 - getColorScore(usersColor, todaysColor).toInt());
  if (imagePath == "") {
    score = 0;
  }
  return PopScope(
    canPop: false,
    onPopInvoked: (pop) {
      Navigator.of(context)
        ..pop()
        ..pop();
    },
    child: AlertDialog.adaptive(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(25),
      content: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListBody(
            children: <Widget>[
              const Text(
                'Results',
                style: kFontStyleHeader1,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          isDaily ? DateTime.now().toString().split(' ')[0] : "Unlimited",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
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
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          color: todaysColor,
                        ),
                        Text(
                          todaysColorData["hex"].toString().toUpperCase(),
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(
                            thickness: 2,
                          ),
                        ),
                        const Text(
                          "Your Color",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
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
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: imagePath != ""
                              ? Image.file(
                                  File(imagePath),
                                )
                              : Container(
                                  color: Colors.white,
                                ),
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
                                    TextSpan(text: "Match: "),
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
              ),
              isDaily
                  ? const Text(
                      "Try again tomorrow!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (context) => Unlimited_Challenge_Page(colorList: GLOBAL_COLOR_LIST)));
                      },
                      child: const Text(
                        "Try again?",
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
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Back to Menu',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            if (secondAttempt) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context)
                ..pop()
                ..pop();
            }
          },
        ),
      ],
    ),
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
