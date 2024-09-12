import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:realcolor/utilities/countdown.dart';

import '../utilities/camera_widget.dart';
import '../utilities/challenge_helpers.dart';
import '../utilities/timer.dart';

class Unlimited_Challenge_Page extends StatefulWidget {
  Unlimited_Challenge_Page({
    super.key,
    required this.camera,
    required this.colorList,
  });

  final CameraDescription camera;
  final List colorList;

  @override
  State<Unlimited_Challenge_Page> createState() => _Unlimited_Challenge_PageState();
}

class _Unlimited_Challenge_PageState extends State<Unlimited_Challenge_Page> {
  final Future<String> _countdown = Future<String>.delayed(
    const Duration(seconds: 3),
    () => 'Countdown finished',
  );
  final countdownValue = ValueNotifier(0);
  Duration _duration = const Duration(seconds: 64);
  Timer? _timer;
  late int _countdownValue;
  late Map<String, dynamic> randomColorData;
  double _animatedHeight = 2000;
  @override
  void initState() {
    super.initState();
    _countdownValue = _duration.inSeconds;
    randomColorData = getRandomColor(widget.colorList);
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> randomColorRGB = randomColorData["rgb"];
    Color randomColor = Color.fromRGBO(randomColorRGB[0], randomColorRGB[1], randomColorRGB[2], 1);

    return ChallengeCountdown(
      showCountdown: true,
      countdownText: "Find this color in 1 minute",
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
                        todaysColorData: randomColorData,
                        isDaily: false,
                        timer: _timer,
                      ),
                    ),
                  ],
                ),
                timerWidget(context, _countdownValue.toString()),
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

  Future<String> _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 61) {
        setState(() {
          _animatedHeight = 50;
        });
      }
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        timer.cancel();
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return resultDialog(randomColorData, context, Colors.white, "", false);
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
