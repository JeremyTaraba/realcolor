import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'dart:math';
import 'package:realcolor/utilities/variables/background_gradients.dart' as background;
import 'dart:convert';
import '../utilities/widgets/fancy_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_settings/app_settings.dart';
import 'package:realcolor/utilities/homepage_helpers.dart';
import '../utilities/variables/globals.dart';

//TODO: add a history to show results for past days
//TODO: watch an ad if u want to redo the daily
//TODO: add animations for transitions
//TODO: in the settings you can change the time for unlimited mode
//TODO: see if can make the cross hair change color according to what it sees (would need to scan screen for this)

class Home_Page extends StatefulWidget {
  const Home_Page({
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
  late String dailyChallengeAttemptTime;
  TextEditingController promoCode = TextEditingController();

  List<List<Color>> randomColorArray = background.allBackgroundGradients;

  Future<String> readJson() async {
    final String response = await rootBundle.loadString('assets/colors.json');
    final data = await json.decode(response);
    colorListFromJson = data;
    GLOBAL_COLOR_LIST = colorListFromJson;
    dailyChallengeAttemptTime = await getDailyChallengeTime();
    return "done";
  }

  String appNamePath = "assets/images/realColor.png";
  String appIconPath = "assets/images/realColorIcon.png";

  @override
  void initState() {
    super.initState();
  }

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
                  cycle: const Duration(seconds: 30),
                  colors: randomColorArray[random.nextInt(randomColorArray.length)],
                ),
                SafeArea(
                  child: Scaffold(
                    drawer: infoDrawer(),
                    endDrawer: const settingsDrawer(),
                    backgroundColor: Colors.transparent,
                    body: Builder(builder: (context) {
                      return Column(
                        children: [
                          Flexible(
                            flex: 4,
                            child: SizedBox(
                              height: double.infinity,
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
                              height: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(children: [
                                  Opacity(opacity: 0.5, child: Image.asset(appIconPath, color: Colors.black)),
                                  ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 6.0), child: Image.asset(appIconPath)))
                                ]),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: double.infinity,
                            ),
                          ),
                          dailyButton(
                            "Daily",
                            context,
                            widget.camera,
                            colorListFromJson,
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: double.infinity,
                            ),
                          ),
                          challengeButton(
                            "Unlimited",
                            context,
                            unlimitedButtonDialog(
                              context,
                              Unlimited_Challenge_Page(
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
                                    // info button
                                    GestureDetector(
                                      child: infoAndSettings(Icons.info),
                                      onTap: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                    ),
                                    // settings button
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
