import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:realcolor/utilities/color_detection.dart";

import "challenge_helpers.dart";

// A screen that allows users to take a picture using a given camera.
class ChallengeCameraScreen extends StatefulWidget {
  ChallengeCameraScreen({
    super.key,
    required this.camera,
    required this.todaysColorData,
  });

  final CameraDescription camera;
  final Map<String, dynamic> todaysColorData;

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
                    child: cameraButon(widget.todaysColorData),
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

  Widget cameraButon(todaysColorData) {
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

          // If the picture was taken, open dialog box.
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return resultDialog(todaysColorData, context, c, xFile.path);
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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final XFile xFile;

  const DisplayPictureScreen({super.key, required this.imagePath, required this.xFile});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Color c = Colors.white;
  Future<void> setup() async {
    c = await imageToRGB(widget.xFile);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RGB: (${c.red}) (${c.green}) (${c.blue})"),
        backgroundColor: c,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        children: [
          Image.file(File(widget.imagePath)),
          Center(
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                await setup();
              },
              child: Text('press here'),
            ),
          )
        ],
      ),
    );
  }
}
