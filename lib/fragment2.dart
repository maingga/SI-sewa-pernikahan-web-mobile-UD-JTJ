import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DateFilterPopup.dart'; // Import DateFilterPopup
import 'ProductDetailPage.dart';
import 'checkout_page.dart'; // Import CheckoutPage
import 'package:intl/intl.dart'; // Import intl for number formatting

class Product {
  final String id; // Add id field
  final String name;
  final String description;
  final String imageUrl;
  final dynamic price;
  final String status;
  final DateTime startDate;
  final DateTime endDate;

  Product({
    required this.id, // Update constructor to accept id
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.startDate,
    required this.endDate,
  });
}

class Fragment2 extends StatefulWidget {
  @override
  _Fragment2State createState() => _Fragment2State();
}

class _Fragment2State extends State<Fragment2> {
  DateTime? _startDate;
  DateTime? _endDate;

  void _applyDateFilter(DateTime startDate, DateTime endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });

    print('Start Date: $_startDate');
    print('End Date: $_endDate');

    _saveDates(); // Save the dates when applying the filter

    FirebaseFirestore.instance.collection('paket').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.set({
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
        }, SetOptions(merge: true));
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.1),
      appBar: AppBar(
        title: Text('Daftar Paket'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DateFilterPopup(
                    onApply: _applyDateFilter,
                    startDate: _startDate, // Provide startDate value
                    endDate: _endDate, // Provide endDate value
                  );
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
                  builder: (context) => CheckoutPage(
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
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
              'Paket Pernikahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _startDate != null && _endDate != null
                  ? FirebaseFirestore.instance
                      .collection('paket')
                      .where('startDate', isGreaterThanOrEqualTo: _startDate)
                      .where('endDate', isLessThanOrEqualTo: _endDate)
                      .where('status', isEqualTo: 'tersedia') // Filter status tersedia
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('paket')
                      .where('status', isEqualTo: 'tersedia') // Filter status tersedia
                      .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Print query results
                print('Query Results: ${snapshot.data!.docs}');

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ProductWidget(
                      product: Product(
                        id: document.id, // Pass document id as product id
                        name: data['name'],
                        description: data['description'],
                        imageUrl: data['imageUrl'],
                        price: data['price'],
                        status: data['status'],
                        startDate: (data['startDate'] as Timestamp).toDate(),
                        endDate: (data['endDate'] as Timestamp).toDate(),
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

    String shortDescription = product.description.length > 100
        ? product.description.substring(0, 100) + '...'
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
              id: product.id, // Pass product id to ProductDetailPage
              name: product.name,
              description: product.description,
              imageUrl: product.imageUrl,
              price: price ?? 0.0,
              status:product.status,
              collection: 'paket', // Pass the collection name
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
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    shortDescription,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        price != null ? 'Rp${NumberFormat('#,##0', 'id_ID').format(price)}' : 'Price not available',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                id: product.id, // Pass product id to ProductDetailPage
                                name: product.name,
                                description: product.description,
                                imageUrl: product.imageUrl,
                                price: price ?? 0.0,
                                status: product.status,
                                collection: 'paket', // Pass the collection name
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 239, 152, 254),
                          textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text('Detail Paket'),
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
    home: Fragment2(),
  ));
}

