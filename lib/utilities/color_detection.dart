import 'package:delta_e/delta_e.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

Future<Color> imageToRGB(XFile xFile) async {
  // decode the image taken from camera
  final decodedImg = img.decodeImage(await xFile.readAsBytes());
  if (decodedImg == null) {
    throw 'Invalid image';
  }
  // get center pixel of image
  int midX = decodedImg.width ~/ 2;
  int midY = decodedImg.height ~/ 2;
  // img.Pixel pixel = decodedImg.getPixelSafe(midX, midY); // if we want to return the center pixel only

  // get all pixels in a 20 x 20 radius from the center and find the most common pixel
  int startX = midX - 10;
  int endX = midX + 10;
  int startY = midY - 10;
  int endY = midY + 10;
  Map<img.Pixel, int> counter = {};
  for (var i = startX; i <= endX; i++) {
    for (var j = startY; j <= endY; j++) {
      counter.update(decodedImg.getPixelSafe(i, j), (value) => ++value, ifAbsent: () => 1);
    }
  }
  late img.Pixel mostCommon;
  int highestVal = 0;

  counter.forEach((k, v) {
    if (v > highestVal) {
      highestVal = v;
      mostCommon = k;
    }
  });

  // print(mostCommon);

  return Color.fromARGB(mostCommon.a.toInt(), mostCommon.r.toInt(), mostCommon.g.toInt(), mostCommon.b.toInt());
}

// https://pub.dev/packages/delta_e
double getColorScore(Color first, Color second, {int threshold = 50}) {
  LabColor lab1 = LabColor.fromRGB(first.red, first.green, first.blue);
  LabColor lab2 = LabColor.fromRGB(second.red, second.green, second.blue);
  return deltaE00(lab1, lab2);
}
