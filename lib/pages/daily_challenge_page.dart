import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realcolor/utilities/camera_widget.dart';
import 'package:realcolor/utilities/countdown.dart';

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
  late var todaysColorData;

  @override
  void initState() {
    super.initState();
    todaysColorData = getTodaysColor(widget.colorList);
  }

  @override
  void dispose() {
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
                        isDaily: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
