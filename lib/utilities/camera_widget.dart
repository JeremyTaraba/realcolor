import "dart:async";

import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:realcolor/utilities/color_detection.dart";
import "package:shared_preferences/shared_preferences.dart";

import "challenge_helpers.dart";

// A screen that allows users to take a picture using a given camera.
class ChallengeCameraScreen extends StatefulWidget {
  ChallengeCameraScreen({
    super.key,
    this.timer,
    required this.camera,
    required this.todaysColorData,
    required this.isDaily,
  });

  final CameraDescription camera;
  final Map<String, dynamic> todaysColorData;
  final bool isDaily;
  final Timer? timer;
  @override
  ChallengeCameraScreenState createState() => ChallengeCameraScreenState();
}

class ChallengeCameraScreenState extends State<ChallengeCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.low,
      // dont need audio
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next steps.
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(height: double.infinity, width: double.infinity, child: CameraPreview(_controller)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: cameraButon(widget.todaysColorData, widget.isDaily, timer: widget.timer),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.pages,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          );
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget cameraButon(todaysColorData, bool isDaily, {Timer? timer}) {
    return GestureDetector(
      // Provide an onPressed callback.
      onTap: () async {
        // Take the Picture in a try / catch block. If anything goes wrong,
        // catch the error.
        try {
          // Ensure that the camera is initialized.
          await _initializeControllerFuture;

          await _controller.setFlashMode(FlashMode.off);

          //Makes it much faster
          await _controller.setFocusMode(FocusMode.locked);

          // Attempt to take a picture and then get the location
          // where the image file is saved.
          final xFile = await _controller.takePicture();

          //Makes it much faster
          await _controller.setFocusMode(FocusMode.locked);

          if (!context.mounted) return;
          Color c = Colors.white;
          c = await imageToRGB(xFile);

          // set daily sharedPreferences
          if (isDaily) {
            print("setting daily sharedprefs");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('dailyAttemptTime', DateTime.now().toString());
            await prefs.setString('savedDailyImgPath', xFile.path);
            await prefs.setStringList('savedDailyColorRGB', <String>[c.red.toString(), c.green.toString(), c.blue.toString()]);
          }
          if (timer != null) {
            timer.cancel();
          }

          // If the picture was taken, open dialog box.
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return resultDialog(todaysColorData, context, c, xFile.path, isDaily);
            },
          );
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.9), width: 6),
            color: const Color(0xFFC0BDBD),
          ),
          height: 65,
          width: 65,
        ),
      ),
    );
  }
}
