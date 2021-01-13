import 'package:latlng/latlng.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'dart:async';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/authMode.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

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

  Future<bool> addProduct(String title, String description, String image,
      double price, String address) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'address': address,
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
          address: address,
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
      {String title,
      String description,
      String image,
      double price,
      String address}) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateProduct = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'address': address,
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
          address: address,
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

  Future<Null> fetchProduct({onlyUser = false}) async {
    _isLoading = true;
    return await http
        .get(
            'https://flutter-products-b1170.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
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
            address: productData['address'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishListUser'] == null
                ? false
                : (productData['wishListUser'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchProductList.add(product);
      });
      _products = onlyUser == true
          ? fetchProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchProductList;
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        address: selectedProduct.address,
        isFavorite: newFavoriteStatus,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
    http.Response response;
    try {
      if (newFavoriteStatus) {
        response = await http.put(
            'https://flutter-products-b1170.firebaseio.com/products/${selectedProduct.id}/wishListUser/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(true));
      } else {
        response = await http.delete(
            'https://flutter-products-b1170.firebaseio.com/products/${selectedProduct.id}/wishListUser/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
      }
    } catch (e) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          address: selectedProduct.address,
          isFavorite: !newFavoriteStatus,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    }
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
  Timer _authTimer;

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

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

      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
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

  autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTime = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTime);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
    }

    notifyListeners();
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _userSubject.add(false);
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

class AddressModel extends ConnectedProductsModel {
  PublishSubject<bool> _isAddressFounded = PublishSubject();
  LocationData _currentPosition;
  String _address, _dateTime;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);

  bool _addressIsLoading = false;

  String get currentAddress {
    return _address;
  }

  bool get addressIsLoading {
    return _addressIsLoading;
  }

  Location location = Location();
  getLoc() async {
    _addressIsLoading = true;
    notifyListeners();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);
    List<Address> value = await _getAddress(
        _currentPosition.latitude, _currentPosition.longitude);

    _address = "${value.first.addressLine}";
    print(value.first.addressLine);
    _isAddressFounded.add(true);
    _addressIsLoading = false;
    notifyListeners();
  }

  PublishSubject<bool> get isAddressFounded {
    return _isAddressFounded;
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
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
