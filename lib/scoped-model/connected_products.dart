import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'dart:async';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/authMode.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      String title, String description, String image, double price) async {
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
    try {
      final http.Response response = await http.post(
          'https://flutter-products-b1170.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Product _newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(_newProduct);
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      {String title, String description, String image, double price}) async {
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
            'https://flutter-products-b1170.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updateProduct))
        .then((http.Response response) {
      final Product _newProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);

      _products[selectedProductIndex] = _newProduct;
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    });

    // } catch (e) {
    //   _isLoading = false;
    //   notifyListeners();
    //   return false;
    // }
  }

  Future<bool> deleteProduct() async {
    _isLoading = true;
    final selectedProductId = selectedProduct.id;

    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();

    final http.Response response = await http.delete(
        'https://flutter-products-b1170.firebaseio.com/products/${selectedProductId}.json?auth=${_authenticatedUser.token}');
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> fetchProduct() {
    _isLoading = true;
    return http
        .get('https://flutter-products-b1170.firebaseio.com/products.json')
        .then<Null>((http.Response response) {
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
      return;
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
  // bool isAuth = false;

  // void login(String email, String password) {
  //   _authenticatedUser =
  //       User(id: 'fdalsdfasf', email: email, password: password);
  // }

  User get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticating(String email, String password,
      [AuthMode authMode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> _authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
    if (authMode == AuthMode.Login) {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBfiUssphPD96jbABIlwzEx0lY87V3nd5g',
        body: json.encode(_authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBfiUssphPD96jbABIlwzEx0lY87V3nd5g',
        body: json.encode(_authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    var message = 'something went rong!';
    print(responseData.toString());

    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Auth succseeded';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      // isAuth = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setBool('is', isAuth);
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'The email Already Exists!';
    } else if (responseData['error']['message'] == 'OPERATION_NOT_ALLOWED') {
      message = 'OPERATION_NOT_ALLOWED!';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'EMAIL_NOT_FOUND!';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'INVALID_PASSWORD!';
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      message = 'USER_DISABLED!';
    } else if (responseData['error']['message'] ==
        'TOO_MANY_ATTEMPTS_TRY_LATER') {
      message = 'TOO_MANY_ATTEMPTS_TRY_LATER!';
    }

    _isLoading = false;
    notifyListeners();
    return {'succes': !hasError, 'message': message};
  }

  Future<bool> get isAuthe async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool z = prefs.getBool('is');
    return z;
  }

  autoAuthenticate() async {
    _isLoading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if (token != null) {
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      print(userId.toString());
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      print('is auth cheked');
    }
    _isLoading = false;
    notifyListeners();
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool f) {
    _isLoading = f;
    notifyListeners();
  }
}
