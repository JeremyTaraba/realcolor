import "package:another_flushbar/flushbar.dart";
import "package:app_settings/app_settings.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:permission_handler/permission_handler.dart";
import "package:purchases_flutter/purchases_flutter.dart";
import "package:purchases_ui_flutter/purchases_ui_flutter.dart";
import "package:realcolor/pages/calendar_page.dart";
import "package:realcolor/utilities/variables/constants.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../pages/daily_challenge_page.dart";
import "../pages/unlimited_challenge_page.dart";

Widget unlimitedChallengeButton(String text, context, colorListFromJson) {
  return Flexible(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return unlimitedButtonDialog(
                context,
                Unlimited_Challenge_Page(
                  colorList: colorListFromJson,
                ),
                prefs,
              );
            },
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3,
              strokeAlign: BorderSide.strokeAlignOutside,
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
            ],
          ),
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

Future<void> getDailyStreakInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // need to check daily challenge time to see if current streaks lost
  int? currentStreakPrefs = prefs.getInt('currentStreak');
  if (currentStreakPrefs != null) {
    String? temp = prefs.getString('dailyAttemptTime');
    if (temp != null) {
      // check if temp is 2 days away
      DateTime beginningOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime lastSetStreak = DateTime.parse(temp);
      if (lastSetStreak.isBefore(beginningOfToday.subtract(const Duration(days: 1)))) {
        prefs.setInt('currentStreak', 0);
      }
    }
  }
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
    child: Row(
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CalendarPage()));
              },
              child: dropShadowIcon(Icons.calendar_month),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Center(
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
                      strokeAlign: BorderSide.strokeAlignOutside,
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
                    ],
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: kFontStyleDaily,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
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

SnackBar snackBarText(String text, Color c) {
  return SnackBar(
    backgroundColor: c,
    content: Text(
      text,
      style: kFontStyleSnackbarError,
    ),
  );
}

Widget unlimitedButtonDialog(context, nav, SharedPreferences prefs) {
  int? currentUnlimitedStreakPrefs = prefs.getInt('currentUnlimitedStreak');
  currentUnlimitedStreakPrefs ??= 0;
  int? highestUnlimitedStreakPrefs = prefs.getInt('highestUnlimitedStreak');
  highestUnlimitedStreakPrefs ??= 0;
  return AlertDialog.adaptive(
    title: const Text(
      'Unlimited',
      style: kFontStyleHeader1,
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          const Text(
            'A 1 minute timer will begin when you start.\n',
            style: TextStyle(fontSize: 20),
          ),
          const Text(
            'Try to get above 80% for a win streak.\n',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Highest Streak: $highestUnlimitedStreakPrefs',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Current Streak: $currentUnlimitedStreakPrefs',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          currentUnlimitedStreakPrefs == 0 ? 'Start' : "Continue",
          style: TextStyle(color: currentUnlimitedStreakPrefs == 0 ? Colors.green[800] : Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
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

Widget dropShadowIcon(icon) {
  return Stack(
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
  );
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
            child: const Center(
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
            "Find and photograph something that embodies today's color. The closer your match, the higher your score. Everyone gets the same color each day, so you can challenge your friends and see who gets the highest score! Click the calendar to see your past results.",
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
  Widget build(BuildContext drawerContext) {
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
              child: const Center(
                child: Text(
                  'Settings',
                  style: kFontStyleInfoHeader,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: GestureDetector(
              onTap: () {
                //open camera permissions
                AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
              },
              child: const Row(
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
      style: const TextStyle(fontSize: 18),
      onChanged: (text) {
        setState(() {
          submitted = false;
        });
      },
      onFieldSubmitted: (text) async {
        FocusScope.of(context).unfocus();
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
              // they already entered it once before
              Future.delayed(
                  const Duration(milliseconds: 100),
                  () => Flushbar(
                        message: "Already applied",
                        duration: const Duration(seconds: 1, milliseconds: 500),
                        backgroundColor: Colors.green,
                      ).show(context));

              setState(() {
                validated = true;
              });
            } else {
              // promo expired
              // red x
              print("promo expired"); // uninstall and reinstall will reset this
              Future.delayed(
                  const Duration(milliseconds: 100),
                  () => Flushbar(
                        message: "Trial expired",
                        duration: const Duration(seconds: 1, milliseconds: 500),
                        backgroundColor: Colors.red,
                      ).show(context));

              setState(() {
                validated = false;
              });
            }
          } else {
            prefs.setString('promoCodeTime', DateTime.now().toString());
            // green check
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Flushbar(
                message: "Promo code applied",
                duration: const Duration(seconds: 1, milliseconds: 500),
                backgroundColor: Colors.green,
              ).show(context),
            );

            setState(() {
              validated = true;
            });
          }
        } else {
          // red x
          Future.delayed(
            const Duration(milliseconds: 100),
            () => Flushbar(
              message: "Invalid code",
              duration: const Duration(seconds: 1, milliseconds: 500),
              backgroundColor: Colors.red,
            ).show(context),
          );

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
      return const Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      if (submitted) {
        return const Icon(
          Icons.close,
          color: Colors.red,
        );
      }
      return const Icon(null);
    }
  }
}
