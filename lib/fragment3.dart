import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DateFilterPopup.dart'; // Import DateFilterPopup
import 'ProductDetailPage.dart';
import 'checkout_page.dart'; // Import CheckoutPage
import 'package:intl/intl.dart'; // Import intl for number formatting

class Product {
  final String id; // Add id property
  final String name;
  final String description;
  final String imageUrl;
  final dynamic price;
  final String status;
  final DateTime startDate;
  final DateTime endDate;

  Product({
    required this.id, // Require id parameter in constructor
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.startDate,
    required this.endDate,
  });
}

class Fragment3 extends StatefulWidget {
  @override
  _Fragment3State createState() => _Fragment3State();
}

class _Fragment3State extends State<Fragment3> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _applyDateFilter(DateTime startDate, DateTime endDate) async {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });

    print('Start Date: $_startDate');
    print('End Date: $_endDate');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('startDate', _startDate!.toIso8601String());
    await prefs.setString('endDate', _endDate!.toIso8601String());

    FirebaseFirestore.instance.collection('dekor').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = {};

        if (_startDate != null) {
          data['startDate'] = Timestamp.fromDate(_startDate!);
        }
        if (_endDate != null) {
          data['endDate'] = Timestamp.fromDate(_endDate!);
        }

        doc.reference.set(data, SetOptions(merge: true));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 220, 198, 224), // Warna ungu muda
      appBar: AppBar(
        title: Text('Daftar Alat dan Dekor'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DateFilterPopup(onApply: _applyDateFilter);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Alat dan Dekor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple, // Warna teks ungu
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _startDate != null && _endDate != null
                  ? FirebaseFirestore.instance
                      .collection('dekor')
                      .where('startDate', isGreaterThanOrEqualTo: _startDate)
                      .where('endDate', isLessThanOrEqualTo: _endDate)
                      .where('status', isEqualTo: 'tersedia') // Filter status tersedia
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('dekor')
                      .where('status', isEqualTo: 'tersedia') // Filter status tersedia
                      .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    DateTime? startDate = data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null;
                    DateTime? endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;

                    if (startDate == null || endDate == null) {
                      return SizedBox.shrink(); // Skip products with null dates
                    }

                    return ProductWidget(
                      product: Product(
                        id: document.id, // Pass document id as product id
                        name: data['name'],
                        description: data['description'],
                        imageUrl: data['imageUrl'],
                        price: data['price'],
                        status: data['status'],
                        startDate: startDate,
                        endDate: endDate,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductWidget extends StatelessWidget {
  final Product product;

  ProductWidget({required this.product});

  @override
  Widget build(BuildContext context) {
    double? price;
    if (product.price is double) {
      price = product.price as double;
    } else if (product.price is int) {
      price = (product.price as int).toDouble();
    } else if (product.price is String) {
      String cleanPrice = product.price.replaceAll(RegExp(r'[^0-9]'), '');
      price = double.tryParse(cleanPrice) ?? 0.0;
    }

    String shortDescription = product.description.length > 50
        ? product.description.substring(0, 50) + '...'
        : product.description;

    Color statusColor;
    if (product.status.toLowerCase() == 'tersedia') {
      statusColor = Colors.green;
    } else if (product.status.toLowerCase() == 'disewa') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.black;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              id: product.id, // Pass the id to ProductDetailPage
              name: product.name,
              description: product.description,
              imageUrl: product.imageUrl,
              price: price ?? 0.0,
              status: product.status,
              collection: 'dekor', // Pass the collection name
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black), // Warna teks judul hitam
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    shortDescription,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey), // Warna teks deskripsi abu-abu
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        price != null ? 'Rp${NumberFormat('#,##0', 'id_ID').format(price)}' : 'Harga tidak tersedia',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black), // Warna teks harga hitam
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                id: product.id, // Pass the id to ProductDetailPage
                                name: product.name,
                                description: product.description,
                                imageUrl: product.imageUrl,
                                price: price ?? 0.0,
                                status: product.status,
                                collection: 'dekor', // Pass the collection name
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 235, 125, 255), // Warna tombol ungu muda
                          textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text('Detail Dekor'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Status: ${product.status}',
                    style: TextStyle(fontSize: 16.0, color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Fragment3(),
  ));
}
