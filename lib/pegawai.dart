import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'editprofilpegawai.dart'; // Assuming this is where EditProfilPegawai is defined

class PegawaiPage extends StatefulWidget {
  @override
  _PegawaiPageState createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  final TextEditingController _noteController = TextEditingController();
  final PageController _pageController = PageController();
  List<File> _imageFiles = [];
  String? _selectedOrderId;
  String _address = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = ''; // Added for search functionality

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data Pegawai'),
        backgroundColor: Colors.blue,
      ),
      drawer: _buildDrawer(context),
      body: _buildOrderPages(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Profil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilPegawai()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPages() {
    return PageView(
      controller: _pageController,
      children: [
        _buildOrderListPage(),
        _buildOrderReportPage(),
      ],
    );
  }

  Widget _buildOrderListPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari alamat pengiriman...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!.docs.where((order) {
                  final orderData = order.data() as Map<String, dynamic>;
                  final address = orderData['address'].toLowerCase();
                  return address.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderData = order.data() as Map<String, dynamic>;

                    final String address = orderData['address'] ?? '';
                    final DateTime? startDate = (orderData['startDate'] as Timestamp?)?.toDate();
                    final DateTime? endDate = (orderData['endDate'] as Timestamp?)?.toDate();
                    final double totalPrice = orderData['totalPrice'].toDouble();
                    final String status = orderData['status'];
                    final List items = orderData['items'] ?? [];

                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        title: Text(
                          'Alamat Pengiriman: ${address.isNotEmpty ? address : 'Tidak tersedia'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Mulai: ${startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : 'Tidak tersedia'}',
                            ),
                            Text(
                              'Tanggal Selesai: ${endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : 'Tidak tersedia'}',
                            ),
                            Text(
                              'Total Pembayaran: Rp${NumberFormat('#,##0', 'id_ID').format(totalPrice)}',
                            ),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: (status == 'Selesai' || status == 'Dibayar Lunas') ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Catatan Item: ${item['note'] ?? 'Tidak ada catatan'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedOrderId = order.id;
                            _address = address;
                            _startDate = startDate;
                            _endDate = endDate;
                          });
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderReportPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectedOrderId != null ? _buildOrderDetails() : Container(),
            SizedBox(height: 20.0),
            _buildTextField(_noteController, 'Keterangan', 'Masukkan keterangan'),
            SizedBox(height: 20.0),
            _buildImageSection(),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Kembali'),
                ),
                ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('orders').doc(_selectedOrderId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Order not found'));
        }

        final orderData = snapshot.data!.data() as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${orderData['status']}', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 10.0),
            // Add more order details here
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Foto:',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: 10.0),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: _imageFiles.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _imageFiles.map((file) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(file, width: 200.0, height: 200.0, fit: BoxFit.cover),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 200.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.grey[800]),
                    ),
            ),
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

Future<void> _pickImages() async {
  final pickedFiles = await ImagePicker().pickMultiImage();
  setState(() {
    _imageFiles = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
  });
}

  Future<void> _saveData() async {
    if (_selectedOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harap pilih order terlebih dahulu')));
      return;
    }

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harap ambil foto terlebih dahulu')));
      return;
    }

    final String note = _noteController.text;

    List<String> downloadUrls = [];
    for (File imageFile in _imageFiles) {
      final fileName = path.basename(imageFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('pegawai_images/$fileName');
      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    // Save data to Firestore
    await FirebaseFirestore.instance.collection('pegawai_data').add({
      'note': note,
      'photoUrls': downloadUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'address': _address,
      'startDate': _startDate,
      'endDate': _endDate,
    });

    // Update order status
    final batch = FirebaseFirestore.instance.batch();
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(_selectedOrderId);
    batch.update(orderRef, {'status': 'Selesai'});

    // Retrieve the items from the order
    final orderSnapshot = await orderRef.get();
    final orderData = orderSnapshot.data() as Map<String, dynamic>;
    final items = orderData['items'] as List<dynamic>;

    // Update status barang menjadi 'Tersedia' di Firestore
    for (var item in items) {
      DocumentReference itemRef;
      if (item['collection'] == 'paket') {
        itemRef = FirebaseFirestore.instance.collection('paket').doc(item['id']);
      } else if (item['collection'] == 'dekor') {
        itemRef = FirebaseFirestore.instance.collection('dekor').doc(item['id']);
      } else {
        continue; // Jika item tidak termasuk dalam 'paket' atau 'dekor', lewati item tersebut
      }

      batch.update(itemRef, {'status': 'tersedia'});
    }

    await batch.commit();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Data berhasil disimpan dan status diperbarui')));
    _clearFields();
  }

  void _clearFields() {
    _noteController.clear();
    setState(() {
      _imageFiles = [];
      _selectedOrderId = null;
      _address = '';
      _startDate = null;
      _endDate = null;
    });
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: PegawaiPage(),
  ));
}
