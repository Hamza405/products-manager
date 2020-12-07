import 'package:asd/pages/product_edit.dart';
import 'package:asd/scoped-model/main.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;
  ProductListPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return ProductListPageState();
  }
}

class ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    widget.model.fetchProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading == true
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(model.allproducts[index].title),
                    background: Container(
                      color: Colors.red,
                    ),
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        model.selectProduct(model.allproducts[index].id);
                        model.deleteProduct();
                      }
                    },
                    child: Column(
                      children: [
                        ListTile(
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    model.allproducts[index].image)),
                            title: Text(model.allproducts[index].title),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                model
                                    .selectProduct(model.allproducts[index].id);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ProductEditPage();
                                }));
                              },
                            )),
                        Divider()
                      ],
                    ),
                  );
                },
                itemCount: model.allproducts.length,
              );
      },
    );
  }
}
