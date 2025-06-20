import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_provider.dart';
import 'PaymentPage.dart';

class CheckoutPage extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  CheckoutPage({this.startDate, this.endDate});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _addressController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      setState(() {
        _startDate = DateTime.parse(startDateString);
      });
    } else {
      setState(() {
        _startDate = widget.startDate;
      });
    }

    String? endDateString = prefs.getString('endDate');
    if (endDateString != null) {
      setState(() {
        _endDate = DateTime.parse(endDateString);
      });
    } else {
      setState(() {
        _endDate = widget.endDate;
      });
    }
  }

  Future<void> _saveDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_startDate != null) {
      await prefs.setString('startDate', _startDate!.toIso8601String());
    }
    if (_endDate != null) {
      await prefs.setString('endDate', _endDate!.toIso8601String());
    }
  }

  int _calculateRentalDays() {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays + 1;
    }
    return 1; // Default to 1 day if dates are not set
  }

  double _calculateTotalPrice(CartProvider cartProvider) {
    int rentalDays = _calculateRentalDays();
    return cartProvider.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity * rentalDays));
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Color.fromARGB(255, 220, 198, 224),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal Terpilih:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.purple[200]),
            ),
            Text(
              _startDate != null ? 'Tanggal Mulai: ${DateFormat('dd-MM-yyyy').format(_startDate!)}' : 'Tanggal Mulai: Belum Dipilih',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              _endDate != null ? 'Tanggal Akhir: ${DateFormat('dd-MM-yyyy').format(_endDate!)}' : 'Tanggal Akhir: Belum Dipilih',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Alamat Pengiriman:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.purple[200]),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat pengiriman',
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Barang dalam Keranjang:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.purple[200]),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartProvider.cartItems[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: Image.network(product.imageUrl, width: 50, height: 50),
                        title: Text(product.name),
                        subtitle: Text('Rp${NumberFormat('#,##0', 'id_ID').format(product.price)} x ${product.quantity}'),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Catatan untuk ${product.name}',
                        ),
                        onChanged: (value) {
                          setState(() {
                            product.note = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveOrder(context, cartProvider);
                  _addressController.clear();
                  _saveDates();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                ),
                child: Text('Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrder(BuildContext context, CartProvider cartProvider) async {
    final String address = _addressController.text;
    final userId = cartProvider.userId;

    if (userId == null) return;

    int rentalDays = _calculateRentalDays();
    double totalPrice = _calculateTotalPrice(cartProvider);

    final order = {
      'userId': userId,
      'address': address,
      'status': 'Menunggu Pembayaran',
      'totalPrice': totalPrice,
      'rentalDays': rentalDays,
      'items': cartProvider.cartItems.map((item) => {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'price': item.price,
        'quantity': item.quantity,
        'status': item.status,
        'note': item.note,
      }).toList(),
      'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
      'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final orderRef = await FirebaseFirestore.instance.collection('orders').add(order);

    final paymentResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          totalPrice: totalPrice,
          name: 'Nama Pelanggan',
          address: address,
          pin: '123456',
          city: 'Nama Kota',
          state: 'Nama Provinsi',
          country: 'Nama Negara',
          orderId: orderRef.id,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    if (paymentResult == 'success') {
      await FirebaseFirestore.instance.collection('orders').doc(orderRef.id).update({
        'status': 'Diproses',
      });
    }
  }
}
