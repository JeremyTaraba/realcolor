import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:realcolor/utilities/countdown.dart';

class Unlimited_Challenge_Page extends StatefulWidget {
  const Unlimited_Challenge_Page({super.key});

  @override
  State<Unlimited_Challenge_Page> createState() => _Unlimited_Challenge_PageState();
}

class _Unlimited_Challenge_PageState extends State<Unlimited_Challenge_Page> {
  final countdownValue = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChallengeCountdown(
        countdownValue: countdownValue,
        challengeWidget: Container(
          color: Colors.blue,
        ),
      ),
    );
  }
}
