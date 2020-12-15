import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final BuildContext context;
  SplashScreen(this.context);
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState(context);
  }
}

class SplashScreenState extends State<SplashScreen> {
  final BuildContext context;
  SplashScreenState(this.context);
  void initState() {
    startTime(context);
    super.initState();
  }

  startTime(BuildContext context) async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(50),
            child: Image.asset(
              'assets/product-release.png',
              alignment: Alignment.center,
            ),
          )),
    );
  }
}
