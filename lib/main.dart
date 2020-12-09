import 'dart:async';

import 'package:asd/pages/products_admin.dart';
import 'package:asd/pages/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'models/product.dart';
import 'pages/auth.dart';
import 'pages/product.dart';
import 'pages/products.dart';
import 'package:asd/scoped-model/main.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  @override
  void initState() {
    _model.setLoading(true);
    _model.autoAuthenticate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        routes: {
          '/': (BuildContext context) => SplashScreen(_model),
          '/productsPage': (BuildContext context) => ProductsPage(_model),
          '/admin': (BuildContext context) => ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product myProduct =
                _model.allproducts.firstWhere((Product product) {
              return product.id == productId;
            });

            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductPage(myProduct));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ProductsPage(_model));
        },
      ),
    );
  }
}
