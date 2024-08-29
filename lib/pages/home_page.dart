import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:realcolor/pages/daily_challenge_page.dart';
import 'package:realcolor/pages/unlimited_challenge_page.dart';
import 'dart:math';
import 'package:realcolor/utilities/background_gradients.dart' as background;
import 'package:realcolor/utilities/camera_widget.dart';
import 'dart:convert';
import '../utilities/fancy_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_settings/app_settings.dart';
import 'package:realcolor/utilities/homepage_helpers.dart';
import 'package:permission_handler/permission_handler.dart';

//TODO: Add change camera access to the settings menu so they can enable it from there also

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

  List<List<Color>> randomColorArray = background.allBackgroundGradients;

  Future<String> readJson() async {
    final String response = await rootBundle.loadString('assets/colors.json');
    final data = await json.decode(response);
    colorListFromJson = data;
    return "done";
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
                        challengeButton(
                          "Daily",
                          context,
                          dailyButtonDialog(
                              context,
                              Daily_Challenge_Page(
                                camera: widget.camera,
                                colorList: colorListFromJson,
                              ),
                              widget.camera),
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
                              ChallengeCameraScreen(
                                camera: widget.camera,
                              )),
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
}
