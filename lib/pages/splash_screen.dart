import 'dart:async';

import 'package:asd/pages/products.dart';
import 'package:asd/scoped-model/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'auth.dart';

class SplashScreen extends StatefulWidget {
  final MainModel _model;
  SplashScreen(this._model);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, () {
      if (widget._model.user == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => AuthPage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ProductsPage(widget._model)));
      }
    });
  }

  void initState() {
    super.initState();
    startTime();
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
