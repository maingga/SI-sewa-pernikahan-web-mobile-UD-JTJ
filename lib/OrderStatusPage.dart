import 'package:flutter/material.dart';

class OrderStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        title: Text('Status Pesanan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Ganti dengan jumlah produk yang sesuai
                itemBuilder: (BuildContext context, int index) {
                  return _buildOrderItem(
                    productName: 'Nama Produk $index',
                    price: '\$100',
                    quantity: '1',
                    status: 'Dalam Proses', // Ganti status sesuai dengan status pesanan
                    onCancelPressed: () {
                      _showCancelConfirmationDialog(context, index); // Tampilkan dialog konfirmasi pembatalan
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem({required String productName, required String price, required String quantity, required String status, required VoidCallback onCancelPressed}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk: $productName',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Harga: $price',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Jumlah: $quantity',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Status Pesanan: $status',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onCancelPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Batalkan Pesanan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi pembatalan
  void _showCancelConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Pembatalan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
              SizedBox(height: 10),
              Text(
                'Alasan Pembatalan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan pembatalan...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _cancelOrder(index); // Batalkan pesanan
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membatalkan pesanan
  void _cancelOrder(int index) {
    print('Pesanan $index dibatalkan'); // Ganti dengan logika pembatalan pesanan yang sesuai
  }
}
