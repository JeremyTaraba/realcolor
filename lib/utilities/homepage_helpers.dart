import "package:app_settings/app_settings.dart";
import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";

Widget unlimitedButtonDialog(context, nav) {
  return AlertDialog.adaptive(
    title: const Text(
      'Unlimited Challenge',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    content: const SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            'Would you like to start the unlimited challenge?\n',
            style: TextStyle(fontSize: 20),
          ),
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
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nav));
        },
      ),
    ],
  );
}

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

Widget dailyButtonDialog(context, nav, camera) {
  var snackBar = SnackBar(
    backgroundColor: Colors.red,
    content: GestureDetector(
      onTap: () {
        AppSettings.openAppSettings(type: AppSettingsType.settings, asAnotherTask: true);
      },
      child: Row(
        children: [
          Text(
            'Please allow camera access to play',
            style: TextStyle(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
  );
  return AlertDialog.adaptive(
    title: const Text(
      'Daily Challenge',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    content: const SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            'Would you like to start the daily challenge?\n',
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
