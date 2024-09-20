import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ******************** Camera Permissions for the homepage ***************************
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

// ******************************************************************************
