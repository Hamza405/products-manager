import 'dart:html';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'dart:async';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allproducts {
    return List.from(_products);
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return http
        .post('https://flutter-products-b1170.firebaseio.com/products.json',
            body: json.encode(productData))
        .then((http.Response response) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Product _newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.password);
      _products.add(_newProduct);
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    });
  }

  Future<Null> updateProduct(
      {String title, String description, String image, double price}) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateProduct = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    return http
        .put(
            'https://flutter-products-b1170.firebaseio.com/products/${selectedProduct.id}.json',
            body: json.encode(updateProduct))
        .then((http.Response response) {
      final Product _newProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.password);

      _products[selectedProductIndex] = _newProduct;
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final selectedProductId = selectedProduct.id;

    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    http
        .delete(
            'https://flutter-products-b1170.firebaseio.com/products/${selectedProductId}.json')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> fetchProduct() {
    _isLoading = true;
    return http
        .get('https://flutter-products-b1170.firebaseio.com/products.json')
        .then((http.Response response) {
      final List<Product> fetchProductList = [];
      final Map<String, dynamic> productsListData = jsonDecode(response.body);
      if (productsListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productsListData.forEach((String procuctId, dynamic productData) {
        final Product product = Product(
            id: procuctId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchProductList.add(product);
      });
      _products = fetchProductList;
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavoriteStatus,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products[selectedProductIndex] = updatedProduct;
    _selProductId = null;
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser =
        User(id: 'fdalsdfasf', email: email, password: password);
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
