import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'cart_provider.dart';
import 'product.dart';
import 'checkout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Color.fromARGB(255, 220, 198, 224),
      body: FutureBuilder<Map<String, DateTime?>>(
        future: _loadDates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final startDate = snapshot.data?['startDate'];
          final endDate = snapshot.data?['endDate'];

          return Column(
            children: [
              if (startDate != null && endDate != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.purple[50],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Mulai: ${DateFormat('dd-MM-yyyy').format(startDate)}',
                            style: TextStyle(fontSize: 16, color: Colors.purple[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tanggal Akhir: ${DateFormat('dd-MM-yyyy').format(endDate)}',
                            style: TextStyle(fontSize: 16, color: Colors.purple[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartProvider.cartItems[index];
                    return ListTile(
                      leading: Image.network(product.imageUrl, width: 50, height: 50),
                      title: Text(product.name),
                      subtitle: Text('Rp${NumberFormat('#,##0', 'id_ID').format(product.price)} x ${product.quantity}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, product, cartProvider);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Rp${NumberFormat('#,##0', 'id_ID').format(cartProvider.getTotalPrice(startDate, endDate))}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[500]),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutPage(startDate: startDate, endDate: endDate)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[200],
                      ),
                      child: Text('Lanjut'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, DateTime?>> _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? startDateString = prefs.getString('startDate');
    String? endDateString = prefs.getString('endDate');

    DateTime? startDate = startDateString != null ? DateTime.parse(startDateString) : null;
    DateTime? endDate = endDateString != null ? DateTime.parse(endDateString) : null;

    return {'startDate': startDate, 'endDate': endDate};
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Item'),
          content: Text('Apakah Anda yakin ingin menghapus ${product.name} dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.removeFromCart(product);
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
