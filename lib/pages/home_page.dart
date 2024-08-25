import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:realcolor/pages/daily_challenge_page.dart';
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'dart:math';
import 'package:realcolor/utilities/background_gradients.dart' as background;
import 'package:realcolor/utilities/camera_widget.dart';

import '../utilities/fancy_container.dart';

class Home_Page extends StatelessWidget {
  Home_Page({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  final random = Random();
  List<List<Color>> randomColorArray = background.allBackgroundGradients;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FancyContainer(
          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          cycle: Duration(seconds: 30),
          colors: randomColorArray[random.nextInt(randomColorArray.length)],
        ),
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    height: 1000,
                    child: Text("Real Color [photoshop text]"),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: Container(
                    height: 1000,
                    child: Text("[Logo goes here]"),
                  ),
                ),
                ChallengeButton(
                  "Daily",
                  context,
                  dailyButtonDialog(
                      context,
                      Daily_Challenge_Page(
                        camera: camera,
                      )),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 1000,
                  ),
                ),
                ChallengeButton(
                  "Unlimited",
                  context,
                  unlimitedButtonDialog(context, ChallengeCameraScreen(camera: camera)),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoAndSettings(Icons.info, ()),
                          infoAndSettings(Icons.settings, ()),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget ChallengeButton(String text, context, alert) {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                  // Color.fromRGBO(255, 143, 158, 1),
                  // Color.fromRGBO(255, 188, 143, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ]),
          child: Center(
            child: GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoAndSettings(icon, onPress) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Stack(
        children: [
          Positioned(
            left: 1.0,
            top: 1.0,
            child: Icon(
              icon,
              color: Colors.black54,
              size: 41,
            ),
          ),
          Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget dailyButtonDialog(context, nav) {
    return AlertDialog.adaptive(
      title: const Text(
        'Daily Challenge',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Would you like to start the daily challenge?\n',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'A 1 minute timer will begin when you start.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Start',
            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nav));
          },
        ),
      ],
    );
  }

  Widget unlimitedButtonDialog(context, nav) {
    return AlertDialog.adaptive(
      title: const Text(
        'Unlimited Challenge',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Would you like to start the daily challenge?\n',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'A 1 minute timer will begin when you start.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Start',
            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nav));
          },
        ),
      ],
    );
  }
}
