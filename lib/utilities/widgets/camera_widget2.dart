import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge_helpers.dart';
import '../color_detection.dart';
import '../variables/constants.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, this.timer, required this.todaysColorData, required this.isDaily});

  final Map<String, dynamic> todaysColorData;
  final bool isDaily;
  final Timer? timer;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Color crossHair = Colors.red;

  _writeNew() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/daily_results.json');
    await file.writeAsString("[]", mode: FileMode.write);
  }

  _writeAppend(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/daily_results.json');
    if (!await file.exists()) {
      _writeNew();
      file = File('${directory.path}/daily_results.json');
    }
    // read file and edit the existing text, then write editted text to file
    String fileText = await file.readAsString();
    String newFileText = "";
    // need to add text without trailing comma
    if (fileText == "[]") {
      newFileText = "[$text]";
    } else {
      newFileText = fileText.substring(0, fileText.length - 1);
      print(newFileText);
      newFileText += ",$text]";
    }
    await file.writeAsString(newFileText, mode: FileMode.write);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(),
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              aspectRatio: CameraAspectRatios.ratio_1_1,
            ),
            previewFit: CameraPreviewFit.fitHeight,
            previewAlignment: Alignment.center,
            // Buttons of CameraAwesome UI will use this theme
            theme: AwesomeTheme(
              bottomActionsBackgroundColor: Colors.black54,
              buttonTheme: AwesomeButtonTheme(
                backgroundColor: Colors.grey.withOpacity(0.5),
                iconSize: 20,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                // Tap visual feedback (ripple, bounce...)
                buttonBuilder: (child, onTap) {
                  return ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        splashColor: Colors.black54,
                        highlightColor: Colors.black54,
                        onTap: onTap,
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            ),
            topActionsBuilder: (state) => AwesomeTopActions(
              padding: EdgeInsets.zero,
              state: state,
              children: [
                Container(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Zoom: ${(state.sensorConfig.zoom * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 18, color: Colors.orange),
                    ),
                  ),
                )
              ],
            ),
            middleContentBuilder: (state) {
              return const Text("");
            },
            onMediaCaptureEvent: (event) {
              switch ((event.status, event.isPicture)) {
                case (MediaCaptureStatus.capturing, true):
                  debugPrint('Capturing picture...');
                case (MediaCaptureStatus.success, true):
                  event.captureRequest.when(
                    single: (single) async {
                      debugPrint('Picture taken');
                      XFile? xFile = single.file;
                      Color c = Colors.white;
                      c = await imageToRGB(xFile!);
                      // set daily sharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      if (widget.isDaily) {
                        print("setting daily sharedprefs");
                        await prefs.setString('dailyAttemptTime', DateTime.now().toString());
                        await prefs.setString('savedDailyImgPath', xFile.path);
                        await prefs.setStringList('savedDailyColorRGB', <String>[c.red.toString(), c.green.toString(), c.blue.toString()]);

                        // set daily streaks
                        int? currentStreakPrefs = prefs.getInt('currentStreak');
                        if (currentStreakPrefs != null) {
                          await prefs.setInt('currentStreak', currentStreakPrefs + 1);
                          currentStreakPrefs = currentStreakPrefs + 1;
                          int? highestStreakPrefs = prefs.getInt('highestStreak');
                          if (highestStreakPrefs != null) {
                            if (highestStreakPrefs < currentStreakPrefs) {
                              await prefs.setInt('highestStreak', currentStreakPrefs);
                            }
                          } else {
                            await prefs.setInt('highestStreak', currentStreakPrefs);
                          }
                        } else {
                          await prefs.setInt('currentStreak', 1);
                          await prefs.setInt('highestStreak', 1);
                        }

                        //set daily results
                        final List<dynamic> todaysColorRGB = widget.todaysColorData["rgb"];
                        Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
                        int score = (100 - getColorScore(c, todaysColor).toInt());
                        _writeAppend(
                            '{"date" : "${DateTime.now().toString()}", "todays_color_rgb": [${todaysColor.red}, ${todaysColor.green}, ${todaysColor.blue}], "todays_color_name": "${widget.todaysColorData["name"]}", "users_color_rgb": [${c.red}, ${c.green}, ${c.blue}], "users_score": $score}');
                      } else {
                        // then its unlimited
                        final List<dynamic> todaysColorRGB = widget.todaysColorData["rgb"];
                        Color todaysColor = Color.fromRGBO(todaysColorRGB[0], todaysColorRGB[1], todaysColorRGB[2], 1);
                        int score = (100 - getColorScore(c, todaysColor).toInt());
                        if (score >= 80) {
                          print("setting unlimited streak");
                          int? currentUnlimitedStreakPrefs = prefs.getInt('currentUnlimitedStreak');
                          if (currentUnlimitedStreakPrefs != null) {
                            await prefs.setInt('currentUnlimitedStreak', currentUnlimitedStreakPrefs + 1);
                            currentUnlimitedStreakPrefs = currentUnlimitedStreakPrefs + 1;
                            int? highestUnlimitedStreakPrefs = prefs.getInt('highestUnlimitedStreak');
                            if (highestUnlimitedStreakPrefs != null) {
                              if (highestUnlimitedStreakPrefs < currentUnlimitedStreakPrefs) {
                                await prefs.setInt('highestUnlimitedStreak', currentUnlimitedStreakPrefs);
                              }
                            } else {
                              await prefs.setInt('highestUnlimitedStreak', currentUnlimitedStreakPrefs);
                            }
                          } else {
                            await prefs.setInt('currentUnlimitedStreak', 1);
                            await prefs.setInt('highestUnlimitedStreak', 1);
                          }
                        } else {
                          print("resetting streak");
                          await prefs.setInt('currentUnlimitedStreak', 0);
                        }
                      }
                      // stop timer
                      if (widget.timer != null) {
                        widget.timer?.cancel();
                      }
                      int? currentUnlimitedStreakPrefs = prefs.getInt('currentUnlimitedStreak');
                      currentUnlimitedStreakPrefs ??= 0;
                      // If the picture was taken, open dialog box.
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return resultDialog(widget.todaysColorData, context, c, xFile.path, widget.isDaily,
                              currentStreak: currentUnlimitedStreakPrefs);
                        },
                      );
                    },
                  );
                case (MediaCaptureStatus.failure, true):
                  debugPrint('Failed to capture picture: ${event.exception}');
                  // show error snack-bar
                  ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                default:
                  debugPrint('Unknown event: $event');
              }
            },
            bottomActionsBuilder: (state) => AwesomeBottomActions(
              state: state,
              left: AwesomeFlashButton(
                state: state,
              ),
              right: AwesomeCameraSwitchButton(
                state: state,
                scale: 1.0,
                onSwitchTap: (state) {
                  state.switchCameraSensor(
                    aspectRatio: state.sensorConfig.aspectRatio,
                  );
                },
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.pages,
              size: 50,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

var snackBarError = SnackBar(
  backgroundColor: Colors.red,
  content: GestureDetector(
    onTap: () {
      AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
    },
    child: const Row(
      children: [
        Text(
          'Error taking picture',
          style: kFontStyleSnackbarError,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.settings,
            color: Colors.white,
          ),
        )
      ],
    ),
  ),
);
