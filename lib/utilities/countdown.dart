import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChallengeCountdown extends StatefulWidget {
  ChallengeCountdown({
    super.key,
    required this.countdownValue,
    required this.challengeWidget,
  });

  final ValueListenable<int> countdownValue;
  final Widget challengeWidget;

  @override
  State<ChallengeCountdown> createState() => _ChallengeCountdownState();
}

class _ChallengeCountdownState extends State<ChallengeCountdown> {
  final Future<String> _countdown = Future<String>.delayed(
    const Duration(seconds: 3),
    () => 'Countdown finished',
  );

  Duration _duration = const Duration(seconds: 3);

  Timer? _timer;

  late int _countdownValue;

  bool _visible = true;

  void initState() {
    super.initState();
    // Start the countdown timer
    _countdownValue = _duration.inSeconds;
    startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: startTimer(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return widget.challengeWidget;
          } else {
            return Container(
              color: Colors.black,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: RichText(
                    textAlign: TextAlign.center,
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: "Find the color\n", style: TextStyle(color: Colors.white, fontSize: 50)),
                        TextSpan(
                          text: _countdownValue.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 100, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Future<String> startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        timer.cancel();

        // Perform any desired action when the countdown is completed
      } else {
        // Update the countdown value and decrement by 1 second
        setState(() {
          _visible = !_visible;
          _countdownValue = _duration.inSeconds;
          _duration = _duration - const Duration(seconds: 1);
        });
      }
    });
    return _countdown;
  }
}
