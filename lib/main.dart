import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:realcolor/pages/home_page.dart';
import 'package:realcolor/utilities/api_keys.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  await _configureSDK();

// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(
    camera: firstCamera,
  ));
}

Future<void> _configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration? configuration;
  configuration = PurchasesConfiguration(revenueCatAndroidKey);
  if (configuration != null) {
    await Purchases.configure(configuration);
    // final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("default");
    // print('paywall result: $paywallResult');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real Color',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Home_Page(
        camera: camera,
      ),
    );
  }
}
