import 'package:asd/scoped-model/main.dart';
import 'package:asd/widgets/products/products.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;
  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage> {
  Widget _buildProductsList() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      Widget content = Center(child: Text('No products baby'));
      if (model.displayedProducts.length > 0 && !model.isLoading) {
        content = Products();
      } else if (model.isLoading) {
        content = Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(onRefresh: model.fetchProduct, child: content);
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.model.fetchProduct();
    return Scaffold(
        drawer: Drawer(
            child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('choose'),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            )
          ],
        )),
        appBar: AppBar(
          title: Text('EasyList'),
          actions: <Widget>[
            ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            })
          ],
        ),
        body: _buildProductsList());
  }
}
