import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:realcolor/pages/home_page.dart';
import 'package:realcolor/utilities/api_keys.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
/* 
Outside Sources: 
Color Dataset from: https://www.kaggle.com/datasets/avi1023/color-names
Color Comparison Algorithm from: https://en.wikipedia.org/wiki/Color_difference
Fonts from: Google
Packages from: Pub dev
In-App Purchases: Revenue Cat
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  // revenue cat SDK
  await _configureSDK();

  runApp(const MyApp());
}

Future<void> _configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration? configuration;
  configuration = PurchasesConfiguration(revenueCatAndroidKey);
  if (configuration != null) {
    await Purchases.configure(configuration);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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
      home: const Home_Page(),
    );
  }
}
