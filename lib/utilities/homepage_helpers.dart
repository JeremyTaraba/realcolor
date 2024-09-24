import "package:app_settings/app_settings.dart";
import "package:flutter/material.dart";
import "package:purchases_flutter/purchases_flutter.dart";
import "package:purchases_ui_flutter/purchases_ui_flutter.dart";
import "package:realcolor/pages/calendar_page.dart";
import "package:realcolor/utilities/functions/rewarded_ad.dart";
import "package:realcolor/utilities/variables/constants.dart";
import "package:realcolor/utilities/widgets/home_page_widgets.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../utilities/functions/camera_permissions.dart";
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
                offset: const Offset(1, 2),
              )
            ],
          ),
          child: Center(
            child: Text(
              text,
              textScaler: TextScaler.noScaling,
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

Widget dailyButton(text, context, colorListFromJson) {
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
              child: dropShadowIcon(Icons.calendar_month, size: 60.0),
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
                        offset: const Offset(1, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      text,
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.left,
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
        child: const Text(
          'Watch ad',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        onPressed: () async {
          await loadAd();
          await showAd();
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
            DateTime promoTime = DateTime.parse(promoTimeStr).subtract(Duration(days: 8));
            print(promoTime.toIso8601String());
            if (promoTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
              // 7 day trial
              debugPrint("Trial NOT expired");
              await checkCameraPermissionsPushReplace(context, snackBar, nav);
              return;
            }
            debugPrint("Trial expired");

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
