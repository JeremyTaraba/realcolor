import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
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
            previewFit: CameraPreviewFit.contain,
            previewAlignment: Alignment.center,
            // Buttons of CameraAwesome UI will use this theme
            theme: AwesomeTheme(
              bottomActionsBackgroundColor: Colors.black54,
              buttonTheme: AwesomeButtonTheme(
                backgroundColor: Colors.black54,
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
              children: const [
                // Expanded(
                //   child: AwesomeFilterWidget(
                //     state: state,
                //     filterListPosition: FilterListPosition.aboveButton,
                //     filterListPadding: const EdgeInsets.only(top: 8),
                //   ),
                // ),
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
                      if (widget.isDaily) {
                        print("setting daily sharedprefs");
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('dailyAttemptTime', DateTime.now().toString());
                        await prefs.setString('savedDailyImgPath', xFile.path);
                        await prefs.setStringList('savedDailyColorRGB', <String>[c.red.toString(), c.green.toString(), c.blue.toString()]);
                      }
                      // stop timer
                      if (widget.timer != null) {
                        widget.timer?.cancel();
                      }

                      // If the picture was taken, open dialog box.
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return resultDialog(widget.todaysColorData, context, c, xFile.path, widget.isDaily);
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
              onMediaTap: (mediaCapture) {
                print("Hi why doesnt it print out here");
                print(mediaCapture.isPicture);
              },
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
