import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/camera_widget.dart';
import 'package:realcolor/utilities/countdown.dart';
import 'package:realcolor/utilities/timer.dart';

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
  final Future<String> _countdown = Future<String>.delayed(
    const Duration(seconds: 3),
    () => 'Countdown finished',
  );
  final countdownValue = ValueNotifier(0);

  Duration _duration = const Duration(seconds: 62);

  Timer? _timer;

  late int _countdownValue;
  late var todaysColorData;

  @override
  void initState() {
    super.initState();
    _countdownValue = _duration.inSeconds;
    todaysColorData = getTodaysColor(widget.colorList);
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> todaysColorRGB = todaysColorData["rgb"];
    DateTime beginningOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (widget.dailyChallengeAttempt != "" && DateTime.parse(widget.dailyChallengeAttempt).isAfter(beginningOfDay)) {
      // they already took a picture today
      print("show dialog box");
    }

    return ChallengeCountdown(
      showCountdown: false,
      countdownText: "Find this color before midnight",
      countdownValue: countdownValue,
      challengeWidget: Container(
        color: Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1),
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
                        color: Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1),
                        height: MediaQuery.sizeOf(context).height / 2,
                      ),
                    ),
                    Divider(
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
                      ),
                    ),
                  ],
                ),
                // GestureDetector(
                //     onTap: () {
                //       showDialog<void>(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return resultDialog(todaysColorData, context, Colors.yellow);
                //         },
                //       );
                //     },
                //     child: timerWidget(context, _countdownValue.toString()),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        timer.cancel();
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return Placeholder();
            // return resultDialog(todaysColorData, context, Colors.red);
          },
        );
        // Perform any desired action when the countdown is completed
      } else {
        // Update the countdown value and decrement by 1 second
        setState(() {
          _countdownValue = _duration.inSeconds;
          _duration = _duration - const Duration(seconds: 1);
        });
      }
    });
    return _countdown;
  }
}
