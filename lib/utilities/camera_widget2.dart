import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

//TODO: This camera is not implemented yet, will have it replace the other one when have more time

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photo(),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_1_1,
        ),
        previewFit: CameraPreviewFit.contain,
        previewPadding: const EdgeInsets.only(left: 150, top: 100),
        previewAlignment: Alignment.topRight,
        // Buttons of CamerAwesome UI will use this theme
        theme: AwesomeTheme(
          bottomActionsBackgroundColor: Colors.cyan.withOpacity(0.5),
          buttonTheme: AwesomeButtonTheme(
            backgroundColor: Colors.cyan.withOpacity(0.5),
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
                    splashColor: Colors.cyan,
                    highlightColor: Colors.cyan.withOpacity(0.5),
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
          return Column(
            children: [
              const Spacer(),
              Builder(builder: (context) {
                return Container(
                  color: AwesomeThemeProvider.of(context).theme.bottomActionsBackgroundColor,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "Take your best shot!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
        bottomActionsBuilder: (state) => AwesomeBottomActions(
          state: state,
          onMediaTap: (mediaCapture) {
            print("Hi");
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
    );
  }
}
