import 'package:another_flushbar/flushbar.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../variables/constants.dart';

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

Flexible homepageSpacer() {
  return Flexible(
    flex: 1,
    child: Container(height: double.infinity),
  );
}
