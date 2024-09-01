import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

class ChallengeCountdown extends StatefulWidget {
  ChallengeCountdown({
    super.key,
    required this.countdownValue,
    required this.challengeWidget,
    required this.showCountdown,
    required this.countdownText,
  });

  final ValueListenable<int> countdownValue;
  final Widget challengeWidget;
  final bool showCountdown;
  final String countdownText;

  @override
  State<ChallengeCountdown> createState() => _ChallengeCountdownState();
}

class _ChallengeCountdownState extends State<ChallengeCountdown> with TickerProviderStateMixin {
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
          Widget child;
          if (snapshot.hasData) {
            child = Container(
              key: ValueKey(1), // assign key

              child: widget.challengeWidget,
            );
          } else {
            child = Container(
              key: ValueKey(0), // assign key
              color: Colors.black,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: RichText(
                    textAlign: TextAlign.center,
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: widget.countdownText + "\n", style: TextStyle(color: Colors.white, fontSize: 50)),
                        TextSpan(
                          text: widget.showCountdown ? _countdownValue.toString() : "",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 100, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: child,
          );
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
