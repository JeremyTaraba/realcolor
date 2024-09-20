import "dart:io";
import 'dart:math';
import 'package:flutter/cupertino.dart';
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

Widget resultDialog(todaysColorData, BuildContext context, Color usersColor, String imagePath, bool isDaily,
    {bool secondAttempt = false, currentStreak = 0}) {
  final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
  Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
  int score = (100 - getColorScore(usersColor, todaysColor).toInt());
  if (imagePath == "") {
    score = 0;
  }
  return PopScope(
    canPop: false,
    child: AlertDialog.adaptive(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(25),
      content: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListBody(
            children: <Widget>[
              const Text(
                'Results',
                textScaler: TextScaler.noScaling,
                style: kFontStyleHeader1,
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDaily
                          ? Colors.blueAccent
                          : score >= 80
                              ? Colors.green
                              : Colors.red,
                      width: 3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      isDaily ? DateTime.now().toString().split(' ')[0] : "Unlimited",
                      style: const TextStyle(fontSize: 20),
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      textScaler: TextScaler.noScaling,
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
                    Container(
                      height: 30,
                      width: 30,
                      color: usersColor,
                    ),
                    Text(
                      "#${usersColor.value.toRadixString(16).substring(2, 8).toUpperCase()}",
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(fontSize: 20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.center,
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                const TextSpan(text: "Match: "),
                                TextSpan(text: "${score.toString()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: getScoreText(score),
                        ),
                      ],
                    ),
                  ],
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Current Streak: $currentStreak",
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(builder: (context) => Unlimited_Challenge_Page(colorList: GLOBAL_COLOR_LIST)));
                          },
                          child: Text(
                            score >= 80 ? "Continue" : "Try again?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: score >= 80 ? Colors.green.shade600 : Colors.blue.shade600),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            if (secondAttempt) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context)
                ..pop()
                ..pop();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 3,
                )
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Back to Menu",
                textScaler: TextScaler.noScaling,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
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
