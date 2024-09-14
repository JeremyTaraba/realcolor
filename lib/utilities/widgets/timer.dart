import 'package:flutter/material.dart';

Widget timerWidget(context, time) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
              // Color.fromRGBO(255, 143, 158, 1),
              // Color.fromRGBO(255, 188, 143, 1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(25.0),
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
        style: TextStyle(fontSize: 32),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
