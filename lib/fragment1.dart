import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'ProductDetailPage.dart';

class Fragment1 extends StatefulWidget {
  @override
  _Fragment1State createState() => _Fragment1State();
}

class _Fragment1State extends State<Fragment1> {
  final CarouselController _controller = CarouselController();

  double parsePrice(dynamic priceValue) {
    try {
      if (priceValue is int || priceValue is double) {
        return priceValue.toDouble(); // Jika langsung berupa angka, kembalikan nilainya
      } else if (priceValue is String) {
        // Jika berupa string, parse sebagai double
        String cleanedPrice = priceValue.replaceAll('Rp', '').replaceAll('.', '').trim();
        return double.parse(cleanedPrice);
      } else {
        // Jika tidak dikenali, kembalikan 0.0
        return 0.0;
      }
    } catch (e) {
      print('Error parsing price: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 201, 135, 201), // Warna ungu muda
      ),
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('paket').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Kesalahan: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              List<DocumentSnapshot>? documents = snapshot.data?.docs;

              if (documents == null || documents.isEmpty) {
                return Text('Data tidak tersedia');
              }

              return CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: documents.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String imageUrl = data['imageUrl'] ?? '';
                  String name = data['name'] ?? '';
                  String description = data['description'] ?? '';
                  double price = parsePrice(data['price']);
                  String status = data['status'] ?? '';

                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                id: document.id,
                                name: name,
                                description: description,
                                imageUrl: imageUrl,
                                price: price,
                                status: status,
                                collection: 'paket',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Paket dan Alat/Dekorasi',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Warna teks putih untuk kontras
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('dekor').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Kesalahan: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<DocumentSnapshot>? documents = snapshot.data?.docs;

                if (documents == null || documents.isEmpty) {
                  return Text('Data tidak tersedia');
                }

                return SingleChildScrollView(
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    padding: EdgeInsets.all(16.0),
                    children: documents.take(8).map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String imageUrl = data['imageUrl'] ?? '';
                      String name = data['name'] ?? '';
                      String description = data['description'] ?? '';
                      double price = parsePrice(data['price']);
                      String status = data['status'] ?? '';

                      String itemDescription = description.length > 30
                          ? description.substring(0, 30) + '...'
                          : description;
                      String itemName = name.length > 15 ? name.substring(0, 15) + '...' : name;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                id: document.id,
                                name: name,
                                description: description,
                                imageUrl: imageUrl,
                                price: price,
                                status: status,
                                collection: 'dekor',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Color.fromARGB(255, 240, 200, 240), // Warna ungu muda
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[700], // Warna ungu tua
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rp${NumberFormat('#,##0', 'id_ID').format(price)}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black, // Warna teks hitam
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      itemDescription,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black, // Warna teks hitam
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
