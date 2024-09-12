import "package:app_settings/app_settings.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:purchases_flutter/purchases_flutter.dart";
import "package:purchases_ui_flutter/purchases_ui_flutter.dart";
import "package:realcolor/utilities/constants.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../pages/daily_challenge_page.dart";

Widget challengeButton(String text, context, alert) {
  return Flexible(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(1, 2),
                )
              ]),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: kFontStyleUnlimited,
            ),
          ),
        ),
      ),
    ),
  );
}

Future<String> getDailyChallengeTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? temp = prefs.getString('dailyAttemptTime');
  String dailyChallengeAttemptTime = "";
  if (temp != null) {
    dailyChallengeAttemptTime = temp;
  }
  return dailyChallengeAttemptTime;
}

Widget dailyButton(text, context, camera, colorListFromJson) {
  return Flexible(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () async {
          String dailyChallengeTime = await getDailyChallengeTime();
          await checkCameraPermissionsPush(
            context,
            snackBar,
            Daily_Challenge_Page(
              camera: camera,
              colorList: colorListFromJson,
              dailyChallengeAttempt: dailyChallengeTime,
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(1, 2),
                )
              ]),
          child: Center(
            child: Text(
              text,
              style: kFontStyleDaily,
            ),
          ),
        ),
      ),
    ),
  );
}

var snackBar = SnackBar(
  backgroundColor: Colors.red,
  content: GestureDetector(
    onTap: () {
      AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
    },
    child: const Row(
      children: [
        Text(
          'Please allow camera access to play',
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

Widget unlimitedButtonDialog(context, nav) {
  return AlertDialog.adaptive(
    title: const Text(
      'Unlimited',
      style: kFontStyleHeader1,
    ),
    content: const SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            'You can play this challenge as many times as you want\n',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'A 1 minute timer will begin when you start.',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    ),
    actionsAlignment: MainAxisAlignment.spaceBetween,
    actions: <Widget>[
      TextButton(
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text(
          'Start',
          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 20),
        ),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? promoTimeStr = prefs.getString('promoCodeTime');

          if (promoTimeStr != null) {
            DateTime promoTime = DateTime.parse(promoTimeStr);
            if (promoTime.isBefore(DateTime.now().add(const Duration(days: 7)))) {
              // 7 day trial
              await checkCameraPermissionsPushReplace(context, snackBar, nav);
              return;
            }
            // trial expired
            // continue
          }

          CustomerInfo customerInfo = await Purchases.getCustomerInfo();
          EntitlementInfo? entitlement = customerInfo.entitlements.all['pro'];
          if (entitlement != null && entitlement.isActive) {
            await checkCameraPermissionsPushReplace(context, snackBar, nav);
          } else {
            final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("default");
            print('paywall result: $paywallResult');
          }
        },
      ),
    ],
  );
}

Future<bool> checkIfCameraAccepted() async {
  const permission = Permission.camera;
  return await permission.status.isGranted;
}

Future<void> requestPermission() async {
  const permission = Permission.camera;

  if (await permission.isDenied) {
    await permission.request();
  }
}

Future<bool> checkPermanentlyDenied() async {
  const permission = Permission.camera;
  return await permission.status.isPermanentlyDenied;
}

Future<void> checkCameraPermissionsPush(context, snackBar, nav) async {
  if (await checkIfCameraAccepted()) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => nav));
  } else {
    if (await checkPermanentlyDenied()) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await requestPermission();
      if (await checkIfCameraAccepted()) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => nav));
      }
    }
  }
}

Future<void> checkCameraPermissionsPushReplace(context, snackBar, nav) async {
  if (await checkIfCameraAccepted()) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nav));
  } else {
    if (await checkPermanentlyDenied()) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      await requestPermission();
      if (await checkIfCameraAccepted()) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nav));
      }
    }
  }
}

Drawer infoDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 120,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[100],
            ),
            child: Center(
              child: Text(
                'How To Play',
                style: kFontStyleInfoHeader,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const Text(
          'Daily',
          style: kFontStyleInfoHeader,
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Find and photograph something that embodies today's color. The closer your match, the higher your score. Everyone gets the same color each day, so you can challenge your friends and see who gets the highest score!",
            style: kFontStyleInfoText,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        const Text(
          'Unlimited',
          style: kFontStyleInfoHeader,
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Test your speed and precision! You’ll get a random color and just 60 seconds to snap a photo that matches it as closely as possible. Play as many times as you like and race against the clock to find your perfect shot!',
            style: kFontStyleInfoText,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    ),
  );
}

class settingsDrawer extends StatefulWidget {
  const settingsDrawer({super.key});

  @override
  State<settingsDrawer> createState() => _settingsDrawerState();
}

class _settingsDrawerState extends State<settingsDrawer> {
  bool validated = false;
  bool submitted = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[200],
              ),
              child: Center(
                child: Text(
                  'Settings',
                  style: kFontStyleInfoHeader,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Text(
          //   "Timezone",
          //   style: TextStyle(fontSize: 30),
          //   textAlign: TextAlign.center,
          // ),
          // settingsDiv,
          // Text(
          //   "Color blind",
          //   style: TextStyle(fontSize: 30),
          //   textAlign: TextAlign.center,
          // ),
          // settingsDiv,
          InkWell(
            onTap: () {},
            child: GestureDetector(
              onTap: () {
                //open camera permissions
                AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 30,
                  ),
                  Text(
                    "Camera Access",
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          settingsDiv,
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: promoCodeField(),
          ),
        ],
      ),
    );
  }

  Widget promoCodeField() {
    return TextFormField(
      style: TextStyle(fontSize: 18),
      onChanged: (text) {
        setState(() {
          submitted = false;
        });
      },
      onFieldSubmitted: (text) async {
        // check if correct or not and show check mark if it is
        // x if it is not, change shared variable for code to have datetime now
        setState(() {
          submitted = true;
        });

        if (text.toLowerCase() == "revenuecat") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? promoTimeStr = prefs.getString('promoCodeTime');
          if (promoTimeStr != null) {
            DateTime promoTime = DateTime.parse(promoTimeStr);
            if (promoTime.isBefore(DateTime.now().add(const Duration(days: 7)))) {
              // green check
              setState(() {
                validated = true;
              });
            } else {
              // promo expired
              // red x
              print("promo expired"); // uninstall and reinstall will reset this
              setState(() {
                validated = false;
              });
            }
          } else {
            prefs.setString('promoCodeTime', DateTime.now().toString());
            // green check
            setState(() {
              validated = true;
            });
          }
        } else {
          // red x
          setState(() {
            validated = false;
          });
        }
      },
      decoration: InputDecoration(
        suffixIcon: promoCodePrefixIcon(validated, submitted),
        border: OutlineInputBorder(),
        fillColor: validated ? Colors.green.shade100 : Colors.red.shade100,
        filled: submitted,
        labelText: 'Promo Code',
        labelStyle: TextStyle(fontSize: 20),
      ),
      maxLength: 10,
    );
  }

  static const settingsDiv = Divider(
    height: 5,
    thickness: 1,
    color: Colors.black,
  );

  Widget promoCodePrefixIcon(bool validated, bool submitted) {
    if (validated && submitted) {
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      if (submitted) {
        return Icon(
          Icons.close,
          color: Colors.red,
        );
      }
      return const Icon(null);
    }
  }
}
