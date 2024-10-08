import 'package:flutter/material.dart';

const TextStyle kFontStyleSnackbarError = TextStyle(fontSize: 16, color: Colors.white);

const TextStyle kFontStyleHeader1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

const TextStyle kFontStyleInfoText = TextStyle(fontSize: 24, fontFamily: "JosefinSans", fontWeight: FontWeight.bold);

const TextStyle kFontStyleInfoHeader = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

const TextStyle kFontStyleUnlimited = TextStyle(
  fontFamily: "PermanentMarker",
  fontSize: 38,
  letterSpacing: 1.5,
);

const TextStyle kFontStyleDaily = TextStyle(
  fontFamily: "PermanentMarker",
  fontSize: 48,
  letterSpacing: 2,
);

Text kScoreTextPerfect = Text(
  "Perfect!",
  style: TextStyle(
    fontSize: 30,
    fontFamily: "Pacifico",
    color: Colors.purple[300],
  ),
);
Text kScoreTextSuperb = const Text(
  "Superb!",
  style: TextStyle(
    fontSize: 30,
    fontFamily: "Gluten",
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  ),
);
const Text kScoreTextGood = Text(
  "Good",
  style: TextStyle(
    fontSize: 33,
    fontFamily: "Caveat",
    color: Colors.green,
    fontWeight: FontWeight.bold,
  ),
);
Text kScoreTextOkay = Text(
  "Okay..",
  style: TextStyle(
    fontSize: 30,
    fontFamily: "JosefinSans",
    color: Colors.orange[700],
    fontWeight: FontWeight.bold,
  ),
);
const Text kScoreTextBad = Text(
  "Bad!",
  style: TextStyle(
    fontSize: 30,
    color: Colors.red,
  ),
);
