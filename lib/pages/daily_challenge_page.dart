import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:realcolor/utilities/timer.dart';

class Daily_Challenge_Page extends StatefulWidget {
  const Daily_Challenge_Page({super.key});

  @override
  State<Daily_Challenge_Page> createState() => _Daily_Challenge_PageState();
}

class _Daily_Challenge_PageState extends State<Daily_Challenge_Page> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  flex: 1,
                  // random color
                  child: Container(
                    color: Colors.green,
                    height: MediaQuery.sizeOf(context).height / 2,
                  ),
                ),
                Divider(
                  height: 5,
                  thickness: 5,
                  color: Colors.black,
                ),
                Flexible(
                  flex: 1,
                  // camera
                  child: Container(
                    color: Colors.red,
                    height: MediaQuery.sizeOf(context).height / 2,
                  ),
                ),
              ],
            ),
            GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return resultDialog();
                    },
                  );
                },
                child: timerWidget(context, "1:00"))
          ],
        ),
      )),
    );
  }

  Widget resultDialog() {
    return AlertDialog.adaptive(
      title: const Text(
        'Results',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'On Time',
                    style: TextStyle(fontSize: 20, color: Colors.green[800], fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: RichText(
                          textAlign: TextAlign.center,
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: "Today's color "),
                              TextSpan(text: "#FFFFF", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 30,
                          width: 30,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: "Highest Score "),
                        TextSpan(text: "70%", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "\nDaily Challenge will reset at a random time tomorrow.",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Back',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
        ),
      ],
    );
  }
}
