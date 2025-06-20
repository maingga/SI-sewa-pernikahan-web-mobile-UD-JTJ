import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductDetailPage.dart'; // Import the ProductDetailPage

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    CollectionReference paketCollection = FirebaseFirestore.instance.collection('paket');
    CollectionReference dekorCollection = FirebaseFirestore.instance.collection('dekor');

    QuerySnapshot paketSnapshot = await paketCollection.get();
    QuerySnapshot dekorSnapshot = await dekorCollection.get();

    List<Map<String, dynamic>> allData = [];

    paketSnapshot.docs.forEach((doc) {
      allData.add(doc.data() as Map<String, dynamic>);
    });

    dekorSnapshot.docs.forEach((doc) {
      allData.add(doc.data() as Map<String, dynamic>);
    });

    setState(() {
      _allProducts = allData;
      _searchResult.addAll(_allProducts);
    });
  }

  void _search(String keyword) {
    setState(() {
      _searchResult = _allProducts.where((product) {
        return product['name'].toString().toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.purple[200], // Warna latar belakang app bar ungu muda
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchResult.clear();
                _searchResult.addAll(_allProducts);
              });
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 220, 198, 224), // Warna latar belakang scaffold ungu muda
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _search(_searchController.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResult.length,
                itemBuilder: (context, index) {
                  var product = _searchResult[index];

                  // Parse and format price
                  double parsedPrice = 0.0;
                  if (product['price'] != null) {
                    String priceString = product['price'].toString();
                    String numericString = priceString.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-numeric characters
                    parsedPrice = double.tryParse(numericString) ?? 0.0;
                  }

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        product['name'] ?? 'No Name',
                        style: TextStyle(color: Colors.purple[200]), // Warna teks ungu muda
                      ),
                      onTap: () {
                        // Navigate to ProductDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              id: product['id'] ?? '',
                              name: product['name'] ?? 'No Name',
                              description: product['description'] ?? 'No Description',
                              imageUrl: product['imageUrl'] ?? '',
                              price: parsedPrice,
                              status: product['status'] ?? 'Unknown',
                              collection: product['collection'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
