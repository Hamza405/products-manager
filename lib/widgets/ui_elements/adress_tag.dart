import 'package:flutter/material.dart';

class AdressTag extends StatelessWidget {
  final String adress;
  AdressTag(this.adress);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(adress),
    );
  }
}
