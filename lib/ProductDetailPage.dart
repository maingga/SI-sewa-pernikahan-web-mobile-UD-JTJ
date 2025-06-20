import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package

import 'product.dart';
import 'cart_provider.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String status;
  final String collection;

  ProductDetailPage({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Produk'),
        backgroundColor: Colors.purple[200],
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 220, 198, 224),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Divider(
              color: Colors.purple[200],
              thickness: 1.5,
            ),
            SizedBox(height: 10.0),
            Text(
              'Deskripsi',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[200],
              ),
            ),
            SizedBox(height: 5.0),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.purple[50], // Latar belakang ungu muda
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Harga',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[200],
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              'Rp${NumberFormat('#,##0', 'id_ID').format(price)}',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[500],
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple[200],
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: status.toLowerCase() == 'tersedia'
                    ? Colors.green
                    : status.toLowerCase() == 'disewa'
                        ? Colors.red
                        : Colors.black,
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                onPressed: status.toLowerCase() == 'disewa'
                    ? () {
                        _showStatusAlert(context);
                      }
                    : () {
                        cartProvider.addToCart(
                          Product(
                            id: id,
                            name: name,
                            description: description,
                            imageUrl: imageUrl,
                            price: price,
                            status: status,
                            collection: collection,
                          ),
                          context,
                        );
                      },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(
                    'Tambah ke Keranjang',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Produk Tidak Tersedia'),
          content: Text(
            'Maaf, produk ini sedang disewa dan tidak dapat ditambahkan ke keranjang.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.purple[200]),
              ),
            ),
          ],
        );
      },
    );
  }
}
