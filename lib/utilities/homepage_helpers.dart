import "package:app_settings/app_settings.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:realcolor/utilities/constants.dart";

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
              style: TextStyle(
                fontFamily: "PermanentMarker",
                fontSize: 28,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget dailyButton(text, context, nav) {
  return Flexible(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () async {
          await checkCameraPermissionsPush(context, snackBar, nav);
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
              color: Colors.black,
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
              style: TextStyle(
                fontFamily: "Honk",
                fontSize: 58,
                letterSpacing: 0.0,
              ),
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
      'Unlimited Challenge',
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
          await checkCameraPermissionsPushReplace(context, snackBar, nav);
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
            child: const Text(
              'How To Play',
              style: kFontStyleInfoHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Text(
          'Daily Challenge',
          style: kFontStyleInfoHeader,
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'In this mode, you are given the color of the day and have 1 attempt at taking a picture that is similar to this color. You will be given a score based on how close your picture is',
            style: kFontStyleInfoText,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        const Text(
          'Unlimited Challenge',
          style: kFontStyleInfoHeader,
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'This mode is a timed mode that you can play as many times as you want. You will be given a random color and you have 1 minute to take a picture similar to this color',
            style: kFontStyleInfoText,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    ),
  );
}

Drawer settingsDrawer() {
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
            child: Text(
              'Settings',
              style: kFontStyleInfoHeader,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Text(
          "Timezone",
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        Divider(
          height: 5,
          thickness: 10,
          color: Colors.black,
        ),
        Text(
          "Color blind",
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        Divider(
          height: 5,
          thickness: 10,
          color: Colors.black,
        ),
        Text(
          "Camera Access",
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
