import 'package:asd/scoped-model/main.dart';
import 'package:asd/widgets/ui_elements/adress_tag.dart';
import 'package:asd/widgets/ui_elements/title_default.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  ProductPage(this.product);

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are u sure ?'),
            content: Text('Fuck u bebe'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('DISCARD')),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: Text('Continue'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop(false);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(product.title),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInImage(
                  placeholder: AssetImage(
                    'assets/loading.gif',
                  ),
                  image: NetworkImage(product.image),
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.cover,
                ),
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: TitleDefault(product.title)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AdressTag('Bsnada / Latakia'),
                    SizedBox(
                      width: 16.0,
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("\$ ${product.price.toString()}"),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(product.description),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    // onPressed: () => _showWarningDialog(context),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Back'),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
