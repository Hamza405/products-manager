import 'package:asd/scoped-model/main.dart';
import 'package:asd/widgets/ensure_visible.dart';
import 'package:flutter/material.dart';
import 'package:asd/models/product.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductEditPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _dataForm = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg',
    'address': null
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  void Function(void) asd;
  final TextEditingController c = new TextEditingController();

  Widget _buildTitleTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Title'),
        initialValue: product == null ? '' : product.title,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Title is required and title should be +5 char';
          }
        },
        onSaved: (String value) {
          _dataForm['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Description'),
        maxLines: 4,
        initialValue: product == null ? '' : product.description,
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'Description is required and Description should be +5 char';
          }
        },
        onSaved: (String value) {
          _dataForm['description'] = value;
        },
      ),
    );
  }

  Widget _buildPriceTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Price'),
        keyboardType: TextInputType.number,
        initialValue: product == null ? '' : product.price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'Price is required and Price should be a number';
          }
        },
        onSaved: (String value) {
          _dataForm['price'] = double.parse(value);
        },
      ),
    );
  }

  Widget _buildAddressTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _addressFocusNode,
      child: TextFormField(
        controller: c,

        decoration: InputDecoration(labelText: 'Address'),
        // initialValue: product == null ? '' : product.address.toString(),
        onSaved: (String value) {
          _dataForm['address'] = value;
        },
      ),
    );
  }

  Widget _buildSubmitButton(Product product) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('Save'),
              textColor: Colors.white,
              onPressed: () => sumbitForm(model.addProduct, model.updateProduct,
                  model.selectedProductIndex),
            );
    });
  }

  Widget _buildAddressButton(Product product) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.addressIsLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('My Address'),
              textColor: Colors.white,
              onPressed: () {
                model.getLoc();
                model.isAddressFounded.listen((bool address) {
                  if (address) {
                    c.text = model.currentAddress == null
                        ? "getting address"
                        : model.currentAddress;
                  }
                });
              });
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
        deviceWidth > 550 ? deviceWidth * 0.8 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Material(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
              children: [
                _buildTitleTextField(product),
                _buildDescriptionTextField(product),
                _buildPriceTextField(product),
                _buildAddressTextField(product),
                SizedBox(
                  height: 10.0,
                ),
                _buildAddressButton(product),
                SizedBox(
                  height: 10.0,
                ),
                _buildSubmitButton(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sumbitForm(Function addProduct, Function updateProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(_dataForm['title'], _dataForm['description'],
              _dataForm['image'], _dataForm['price'], _dataForm['address'])
          .then((bool s) {
        if (s) {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('Try agin'),
                );
              });
        }
      });
    } else {
      updateProduct(
              title: _dataForm['title'],
              description: _dataForm['description'],
              price: _dataForm['price'],
              image: _dataForm['image'],
              address: _dataForm['address'])
          .then((_) => Navigator.pushReplacementNamed(context, '/'));
    }

    ;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget _pageContent =
            _buildPageContent(context, model.selectedProduct);

        return model.selectedProductIndex == -1
            ? _pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: _pageContent);
      },
    );
  }
}
