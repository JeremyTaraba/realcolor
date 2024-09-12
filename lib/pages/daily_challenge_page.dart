import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/camera_widget.dart';
import 'package:realcolor/utilities/countdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/challenge_helpers.dart';

class Daily_Challenge_Page extends StatefulWidget {
  const Daily_Challenge_Page({
    super.key,
    required this.camera,
    required this.colorList,
    required this.dailyChallengeAttempt,
  });
  final CameraDescription camera;
  final List colorList;
  final String dailyChallengeAttempt;
  @override
  State<Daily_Challenge_Page> createState() => _Daily_Challenge_PageState();
}

class _Daily_Challenge_PageState extends State<Daily_Challenge_Page> {
  final countdownValue = ValueNotifier(0);
  late int _countdownValue; // flutter says this isn't used for some reason
  late Duration _duration = const Duration(seconds: 3);
  late Map<String, dynamic> todaysColorData;
  Timer? _timer;
  double _animatedHeight = 2000;

  @override
  void initState() {
    super.initState();
    _countdownValue = _duration.inSeconds;
    todaysColorData = getTodaysColor(widget.colorList);
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
    Color randomColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
    DateTime beginningOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (widget.dailyChallengeAttempt != "" && DateTime.parse(widget.dailyChallengeAttempt).isAfter(beginningOfDay)) {
      // they already took a picture today

      return Scaffold(
        body: FutureBuilder(
          future: getPreviousAttempt(), // get info from sharedprefs and show results
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: resultDialog(todaysColorData, context, snapshot.data?[0], snapshot.data?[1], true, secondAttempt: true),
              );
            }
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black,
            );
          },
        ),
      );
    }

    return ChallengeCountdown(
      showCountdown: false,
      countdownText: "Find this color before midnight",
      countdownValue: countdownValue,
      challengeWidget: Container(
        color: randomColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Column(
                  children: [
                    Flexible(
                      flex: 1,
                      // random color
                      child: Container(
                        color: randomColor,
                        height: MediaQuery.sizeOf(context).height / 2,
                      ),
                    ),
                    const Divider(
                      height: 10,
                      thickness: 10,
                      color: Colors.black,
                    ),
                    Flexible(
                      flex: 1,
                      // camera
                      child: ChallengeCameraScreen(
                        camera: widget.camera,
                        todaysColorData: todaysColorData,
                        isDaily: true,
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  height: _animatedHeight,
                  width: double.infinity,
                  color: randomColor,
                  duration: const Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> getPreviousAttempt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> prevColorAndPath = [];
    Color prevColor = Colors.white;
    String prevImgPath = ""; // should set this to a default img
    final List<String>? tempColor = prefs.getStringList('savedDailyColorRGB');
    if (tempColor != null) {
      prevColor = Color.fromRGBO(int.parse(tempColor[0]), int.parse(tempColor[1]), int.parse(tempColor[2]), 1);
    }
    String? tempString = prefs.getString('savedDailyImgPath');
    if (tempString != null) {
      prevImgPath = tempString;
    }
    prevColorAndPath.add(prevColor);
    prevColorAndPath.add(prevImgPath);
    return prevColorAndPath;
  }

  Future<void> _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
        setState(() {
          _animatedHeight = 50;
          _duration = _duration - const Duration(seconds: 1);
        });
      }
      if (_duration.inSeconds > 0) {
        setState(() {
          _countdownValue = _duration.inSeconds;
          _duration = _duration - const Duration(seconds: 1);
        });
      }
    });
  }
}
