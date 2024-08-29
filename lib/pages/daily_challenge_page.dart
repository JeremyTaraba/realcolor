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
  });
  final CameraDescription camera;
  final List colorList;
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

    return ChallengeCountdown(
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
                      height: 5,
                      thickness: 5,
                      color: Colors.black,
                    ),
                    Flexible(
                        flex: 1,
                        // camera
                        child: ChallengeCameraScreen(
                          camera: widget.camera,
                        )),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return resultDialog(todaysColorData);
                        },
                      );
                    },
                    child: timerWidget(context, _countdownValue.toString()))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget resultDialog(todaysColorData) {
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

  Future<String> startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        timer.cancel();
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return resultDialog(todaysColorData);
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
