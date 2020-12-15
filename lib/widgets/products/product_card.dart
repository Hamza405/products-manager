import 'package:asd/scoped-model/main.dart';

import '../../models/product.dart';
import 'package:asd/widgets/ui_elements/adress_tag.dart';
import 'package:asd/widgets/ui_elements/title_default.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'price_tag.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildActionButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => Navigator.pushNamed<bool>(
                  context, '/product/${model.allproducts[productIndex].id}'),
              icon: Icon(
                Icons.info,
                color: Theme.of(context).accentColor,
              )),
          IconButton(
              onPressed: () {
                model.selectProduct(model.allproducts[productIndex].id);
                print(model.allproducts[productIndex].id.toString());
                print(model.user.id.toString());

                model.toggleProductFavoriteStatus();
              },
              icon: Icon(
                model.allproducts[productIndex].isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        FadeInImage(
          placeholder: AssetImage(
            'assets/loading.gif',
          ),
          image: NetworkImage(product.image),
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.cover,
        ),
        Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TitleDefault(product.title),
                SizedBox(
                  width: 10,
                ),
                PriceTag(product.price.toString())
              ],
            )),
        AdressTag('Latakia , Bsnada'),
        Text(product.userEmail),
        _buildActionButton(context),
      ]),
    );
  }
}
