import 'package:flutter/material.dart';

Widget timerWidget(context, time) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 4,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 4,
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ]),
      width: MediaQuery.of(context).size.width / 3,
      child: Text(
        time,
        textScaler: TextScaler.noScaling,
        style: TextStyle(fontSize: 32),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
