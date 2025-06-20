import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';
import 'login.dart';

class CartProvider extends ChangeNotifier {
  List<Product> _cartItems = [];
  String? _userId;

  List<Product> get cartItems => _cartItems;

  double getTotalPrice(DateTime? startDate, DateTime? endDate) {
    int rentalDays = calculateRentalDays(startDate, endDate);
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity * rentalDays));
  }

  int calculateRentalDays(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      return endDate.difference(startDate).inDays + 1;
    }
    return 1;
  }

  String? get userId => _userId;

  void setUserId(String? userId) {
    _userId = userId;
    _loadCartItems();
    notifyListeners();
  }

  Future<void> _loadCartItems() async {
    _cartItems.clear();

    if (_userId == null || _userId == 'dummy_user_id') return;

    final snapshot = await FirebaseFirestore.instance
        .collection('keranjang')
        .doc(_userId)
        .collection('items')
        .get();

    _cartItems = snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        name: data['name'],
        description: data['description'],
        imageUrl: data['imageUrl'],
        price: data['price'],
        status: data['status'],
        quantity: data['quantity'],
        collection: data['collection'],
        note: data['note'] ?? '',
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addToCart(Product product, BuildContext context, {String? note}) async {
    if (_userId == null || _userId == 'dummy_user_id') {
      _showAccountRequiredDialog(context);
      return;
    }

    if (product.status.toLowerCase() == 'disewa') {
      _showAddToCartDialog(context, product, false);
      return;
    }

    final existingProductIndex =
        _cartItems.indexWhere((item) => item.id == product.id);
    if (existingProductIndex >= 0) {
      _cartItems[existingProductIndex].quantity += 1;
      if (note != null && note.isNotEmpty) {
        _cartItems[existingProductIndex].note = note;
      }
    } else {
      final newProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        status: product.status,
        quantity: product.quantity,
        collection: product.collection,
        note: note ?? '',
      );
      _cartItems.add(newProduct);
    }
    notifyListeners();

    final cartItem = FirebaseFirestore.instance
        .collection('keranjang')
        .doc(_userId)
        .collection('items')
        .doc(product.id);

    await cartItem.set({
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'status': product.status,
      'quantity': product.quantity,
      'collection': product.collection,
      'note': note ?? '',
    });

    _showAddToCartDialog(context, product, true);
  }

  Future<void> removeFromCart(Product product) async {
    if (_userId == null || _userId == 'dummy_user_id') return;

    _cartItems.remove(product);
    notifyListeners();

    final cartItem = FirebaseFirestore.instance
        .collection('keranjang')
        .doc(_userId)
        .collection('items')
        .doc(product.id);

    await cartItem.delete();
  }

  void clearCart() async {
    _cartItems = [];
    notifyListeners();

    if (_userId != null && _userId != 'dummy_user_id') {
      final batch = FirebaseFirestore.instance.batch();
      final cartItemsRef =
          FirebaseFirestore.instance.collection('keranjang').doc(_userId).collection('items');

      final snapshot = await cartItemsRef.get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  void _showAddToCartDialog(BuildContext context, Product product, bool added) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(added ? 'Item Ditambahkan' : 'Tidak Bisa Ditambahkan'),
          content: Text(added
              ? '${product.name} telah ditambahkan ke keranjang Anda.'
              : '${product.name} tidak bisa ditambahkan karena statusnya "Disewa".'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Akun Diperlukan'),
          content: Text('Silakan buat akun atau masuk terlebih dahulu untuk menambahkan item ke keranjang.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
