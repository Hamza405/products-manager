import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-model/main.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.logout),
          onTap: () {
            model.logout();
            Navigator.of(context).pushReplacementNamed('/');
          });
    });
  }
}
