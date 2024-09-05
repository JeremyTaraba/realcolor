import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:realcolor/pages/daily_challenge_page.dart';
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'dart:math';
import 'package:realcolor/utilities/background_gradients.dart' as background;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../utilities/fancy_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_settings/app_settings.dart';
import 'package:realcolor/utilities/homepage_helpers.dart';

//TODO: Make the results screen wider. make sure the daily can only be played once
//TODO: bug with going back on dialog after taking picture
//TODO: timer needs to stop after taking picture in unlimited
//TODO: if timer runs out without picture it causes an error
//TODO: create custom score words like in Rhyth heaven: Perfect!!(100-91), Superb(90-81), Good(80-71), Okay..(70-61), Bad(60 <)

//TODO: work on adding awesome camera in since it is faster.

class Home_Page extends StatefulWidget {
  Home_Page({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final random = Random();
  late List colorListFromJson;
  late SharedPreferences prefs;
  late String dailyChallengeAttemptTime;

  List<List<Color>> randomColorArray = background.allBackgroundGradients;

  Future<String> readJson() async {
    final String response = await rootBundle.loadString('assets/colors.json');
    final data = await json.decode(response);
    colorListFromJson = data;
    prefs = await SharedPreferences.getInstance();
    String? temp = prefs.getString('dailyAttemptTime');
    dailyChallengeAttemptTime = "";
    if (temp != null) {
      dailyChallengeAttemptTime = temp;
    }
    return "done";
  }

  String appNamePath = "assets/images/realColor.png";
  String appIconPath = "assets/images/realColorIcon.png";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readJson(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                FancyContainer(
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  cycle: Duration(seconds: 30),
                  colors: randomColorArray[random.nextInt(randomColorArray.length)],
                ),
                SafeArea(
                  child: Scaffold(
                    drawer: infoDrawer(),
                    endDrawer: settingsDrawer(),
                    backgroundColor: Colors.transparent,
                    body: Builder(builder: (context) {
                      return Column(
                        children: [
                          Flexible(
                            flex: 4,
                            child: Container(
                              height: 1000,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Stack(children: [
                                  Opacity(child: Image.asset(appNamePath, color: Colors.black), opacity: 0.5),
                                  ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 3.0), child: Image.asset(appNamePath)))
                                ]),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 6,
                            child: Container(
                              height: 1000,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(children: [
                                  Opacity(child: Image.asset(appIconPath, color: Colors.black), opacity: 0.5),
                                  ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 6.0), child: Image.asset(appIconPath)))
                                ]),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 1000,
                            ),
                          ),
                          dailyButton(
                            "Daily",
                            context,
                            Daily_Challenge_Page(
                              camera: widget.camera,
                              colorList: colorListFromJson,
                              dailyChallengeAttempt: dailyChallengeAttemptTime,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 1000,
                            ),
                          ),
                          challengeButton(
                            "Unlimited",
                            context,
                            unlimitedButtonDialog(
                              context,
                              Unlimited_Challenge_Page(
                                camera: widget.camera,
                                colorList: colorListFromJson,
                              ),
                            ),
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
                                    GestureDetector(
                                      child: infoAndSettings(Icons.info),
                                      onTap: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                    ),
                                    GestureDetector(
                                      child: infoAndSettings(Icons.settings),
                                      onTap: () {
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ],
            );
          } else {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: SpinKitDancingSquare(
                color: Colors.white,
              ),
            );
          }
        });
  }

  Future<CameraController> initCameraController(camera) async {
    CameraController controller = CameraController(
      // Get a specific camera from the list of available cameras.
      camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
      // dont need audio
      enableAudio: false,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Navigator.pop(context);
            break;
          default:
            // if they previously denied it then open the settings
            AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
            break;
        }
      }
    });
    return controller;
  }

  Drawer setDrawer(int drawerNum) {
    if (drawerNum == 1) {
      return infoDrawer();
    } else {
      return const Drawer();
    }
  }

  Widget infoAndSettings(icon) {
    return Stack(
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
    );
  }
}
