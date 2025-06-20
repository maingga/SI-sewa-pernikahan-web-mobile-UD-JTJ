import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_provider.dart';
import 'HistoryPage.dart';
import 'payment_intent_service.dart';
import 'package:intl/intl.dart';
import 'push_notification_service.dart';

class PaymentPage extends StatefulWidget {
  final double totalPrice;
  final String name;
  final String address;
  final String pin;
  final String city;
  final String state;
  final String country;
  final String orderId;
  final DateTime? startDate;
  final DateTime? endDate;

  PaymentPage({
    required this.totalPrice,
    required this.name,
    required this.address,
    required this.pin,
    required this.city,
    required this.state,
    required this.country,
    required this.orderId,
    this.startDate,
    this.endDate,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dpController = TextEditingController();
  double downPayment = 0.0;
  bool isFullPayment = true;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.address;
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(price);
  }

  Future<void> _startPayment() async {
    try {
      double amountToPay;
      if (isFullPayment) {
        amountToPay = widget.totalPrice;
      } else {
        amountToPay = downPayment;
      }

      final paymentIntentData = await createPaymentIntent(
        name: widget.name,
        address: widget.address,
        pin: widget.pin,
        city: widget.city,
        state: widget.state,
        country: widget.country,
        currency: 'idr',
        amount: (amountToPay * 100).toInt().toString(),
      );

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData['client_secret'],
        merchantDisplayName: 'Contoh Toko',
      ));

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran Berhasil')),
      );

      _addressController.clear();
      _dpController.clear();

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await _addOrderHistory(cartProvider);
      await _updateItemStatus(cartProvider);
      cartProvider.clearCart();

      PushNotificationService().showSuccessNotification();

      Navigator.pop(context, 'success');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryPage()),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran Gagal')),
      );
      Navigator.pop(context, 'failure');
    }
  }

  Future<void> _addOrderHistory(CartProvider cartProvider) async {
    final userId = cartProvider.userId;
    if (userId == null) return;

    final order = {
      'userId': userId,
      'address': widget.address,
      'status': 'Sedang Diproses',
      'totalPrice': cartProvider.getTotalPrice(widget.startDate, widget.endDate),
      'downPayment': isFullPayment ? widget.totalPrice : downPayment,
      'remainingAmount': isFullPayment ? 0.0 : widget.totalPrice - downPayment,
      'items': cartProvider.cartItems.map((item) => {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'price': item.price,
        'quantity': item.quantity,
        'status': item.status,
        'collection': item.collection,
        'note': item.note,
      }).toList(),
      'startDate': widget.startDate != null ? Timestamp.fromDate(widget.startDate!) : null,
      'endDate': widget.endDate != null ? Timestamp.fromDate(widget.endDate!) : null,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).set(order);
  }

  Future<void> _updateItemStatus(CartProvider cartProvider) async {
    final orderItems = cartProvider.cartItems;
    final batch = FirebaseFirestore.instance.batch();

    for (var item in orderItems) {
      DocumentReference itemRef;
      if (item.collection == 'paket') {
        itemRef = FirebaseFirestore.instance.collection('paket').doc(item.id);
      } else if (item.collection == 'dekor') {
        itemRef = FirebaseFirestore.instance.collection('dekor').doc(item.id);
      } else {
        continue;
      }

      if (widget.endDate != null && widget.endDate!.isBefore(DateTime.now())) {
        batch.update(itemRef, {'status': 'Tersedia'});
      } else {
        batch.update(itemRef, {'status': 'Disewa'});
      }
    }

    await batch.commit();
  }

  double _calculateTotalPriceWithRentalDays(CartProvider cartProvider) {
    int rentalDays = widget.endDate!.difference(widget.startDate!).inDays + 1;
    return cartProvider.cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity * rentalDays);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    double totalPriceWithRentalDays = _calculateTotalPriceWithRentalDays(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Color.fromARGB(255, 220, 198, 224),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Pembayaran',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[500],
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              _formatPrice(totalPriceWithRentalDays),
              style: TextStyle(
                fontSize: 28.0,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            SwitchListTile(
              title: Text('Pembayaran Penuh'),
              value: isFullPayment,
              onChanged: (value) {
                setState(() {
                  isFullPayment = value;
                });
              },
            ),
            if (!isFullPayment)
              TextField(
                controller: _dpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Uang Muka (DP)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    downPayment = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            SizedBox(height: 20.0),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Alamat Pengiriman',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20.0),
            Text(
              'Detail Barang:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[500],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.cartItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Catatan: ${item.note}'),
                    trailing: Text('Rp${NumberFormat('#,##0', 'id_ID').format(item.price)} x ${item.quantity}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _startPayment,
              child: Text('Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
