import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class TestColorCamera extends StatefulWidget {
  const TestColorCamera({super.key});

  @override
  State<TestColorCamera> createState() => _TestColorCameraState();
}

class _TestColorCameraState extends State<TestColorCamera> {
  ColorPickerCamera test = ColorPickerCamera();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Text("Text"),
      ),
    );
  }
}

class ColorPickerCamera {
  static const MethodChannel _channel = const MethodChannel('com.jeremytaraba/color_picker_camera');

  static Future<String> get captureColorFromCamera async {
    try {
      if (await Permission.camera.request().isGranted) {
        var result = await _channel.invokeMethod('startNewActivity');
        return result;
      } else {
        print("Permission not granted");
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
    return "";
  }
}
