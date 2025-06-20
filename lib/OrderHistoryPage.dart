import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pesanan'),
      ),
      body: ListView.builder(
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          final order = completedOrders[index];
          return ListTile(
            title: Text(order.productName),
            subtitle: Text('Status: Selesai'),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman untuk memberikan komentar dan rating
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentAndRatingPage(productName: order.productName),
                  ),
                );
              },
              child: Text('Komentar & Rating'),
            ),
          );
        },
      ),
    );
  }
}

class CompletedOrder {
  final String productName;

  CompletedOrder({required this.productName});
}

// Contoh daftar produk yang telah selesai
List<CompletedOrder> completedOrders = [
  CompletedOrder(productName: 'Produk 1'),
  CompletedOrder(productName: 'Produk 2'),
  CompletedOrder(productName: 'Produk 3'),
];

class CommentAndRatingPage extends StatefulWidget {
  final String productName;

  CommentAndRatingPage({required this.productName});

  @override
  _CommentAndRatingPageState createState() => _CommentAndRatingPageState();
}

class _CommentAndRatingPageState extends State<CommentAndRatingPage> {
  double _rating = 0;
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar & Rating untuk ${widget.productName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk: ${widget.productName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Tulis komentar Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Text(
              'Rating: $_rating',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simpan komentar dan rating ke database atau lakukan tindakan yang sesuai
                final comment = _commentController.text;
                print('Komentar untuk ${widget.productName}: $comment');
                print('Rating untuk ${widget.productName}: $_rating');
                Navigator.pop(context);
              },
              child: Text('Simpan Komentar & Rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
