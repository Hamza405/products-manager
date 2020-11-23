import 'package:asd/models/product.dart';
import 'package:asd/scoped-model/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:asd/widgets/products/product_card.dart';
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  Products();

  Widget _buildProductsList(List<Product> products) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) =>
          ProductCard(products[index], index),
      itemCount: products.length,
    );
  }

  @override
  Widget build(Object context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _buildProductsList(model.displayedProducts);
    });
  }
}
