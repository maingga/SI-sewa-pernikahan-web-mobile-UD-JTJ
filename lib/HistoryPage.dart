import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'payment_intent_service.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userId = cartProvider.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Riwayat Pesanan'),
          backgroundColor: Colors.purple,
        ),
        backgroundColor: Colors.purple[50],
        body: Center(
          child: Text(
            'Anda belum login.',
            style: TextStyle(color: Colors.purple),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pesanan'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.purple[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;

              final String address = orderData['address'] ?? '';
              final DateTime? startDate = (orderData['startDate'] as Timestamp?)?.toDate();
              final DateTime? endDate = (orderData['endDate'] as Timestamp?)?.toDate();
              int rentalDays = endDate != null && startDate != null
                  ? endDate.difference(startDate).inDays + 1
                  : 0;

              final remainingAmount = orderData['remainingAmount'] ?? 0;

              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat Pengiriman:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        address.isNotEmpty ? address : 'Tidak tersedia',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Tanggal Mulai:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : 'Tidak tersedia',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Tanggal Selesai:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : 'Tidak tersedia',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Total Pembayaran:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        'Rp${NumberFormat('#,##0', 'id_ID').format(orderData['totalPrice'])}',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Uang Muka (DP):',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        'Rp${NumberFormat('#,##0', 'id_ID').format(orderData['downPayment'] ?? 0)}',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Sisa Pembayaran:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        'Rp${NumberFormat('#,##0', 'id_ID').format(remainingAmount)}',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Status Pesanan:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Text(
                        orderData['status'] ?? 'Tidak tersedia',
                        style: TextStyle(fontSize: 16.0, color: Colors.purple[700]),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Item:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      ...orderData['items'].map<Widget>((item) {
                        double totalItemPrice = item['price'] * item['quantity'] * rentalDays;

                        return ListTile(
                          title: Text('${item['name']}', style: TextStyle(color: Colors.purple[700])),
                          subtitle: Text(
                            'Harga: Rp${NumberFormat('#,##0', 'id_ID').format(item['price'])} x ${item['quantity']} = Rp${NumberFormat('#,##0', 'id_ID').format(totalItemPrice)}',
                            style: TextStyle(color: Colors.purple[700]),
                          ),
                          trailing: Text(
                            item['note'] ?? 'Tidak ada catatan',
                            style: TextStyle(color: Colors.purple[600]),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (remainingAmount > 0 && 
                              orderData['status'] != 'Dibatalkan' && 
                              orderData['status'] != 'Selesai' &&
                              orderData['status'] != 'Uang Dikembalikan' &&
                              orderData['status'] != 'Dibayar Lunas')
                            ElevatedButton(
                              onPressed: () => _payRemainingDP(context, order.id, remainingAmount),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                              ),
                              child: Text('Lunasi DP'),
                            ),
                          if (orderData['status'] != null && 
                              orderData['status'] != 'Dibatalkan' && 
                              orderData['status'] != 'Selesai' &&
                              orderData['status'] != 'Uang Dikembalikan' &&
                              orderData['status'] != 'Dibayar Lunas')
                            ElevatedButton(
                              onPressed: () => _cancelOrder(context, order.id, orderData['items']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                              ),
                              child: Text('Batalkan Pesanan'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, String orderId, List<dynamic> items) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      batch.update(orderRef, {'status': 'Dibatalkan'});

      for (var item in items) {
        DocumentReference itemRef;
        if (item['collection'] == 'paket') {
          itemRef = FirebaseFirestore.instance.collection('paket').doc(item['id']);
        } else if (item['collection'] == 'dekor') {
          itemRef = FirebaseFirestore.instance.collection('dekor').doc(item['id']);
        } else {
          continue;
        }

        batch.update(itemRef, {'status': 'tersedia'});
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dibatalkan')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan pesanan')),
      );
    }
  }

  Future<void> _payRemainingDP(BuildContext context, String orderId, double remainingAmount) async {
    try {
      final paymentIntentData = await createPaymentIntent(
        name: 'Nama Pengguna',
        address: 'Alamat',
        pin: 'Kode Pos',
        city: 'Kota',
        state: 'Provinsi',
        country: 'Negara',
        currency: 'idr',
        amount: (remainingAmount * 100).toInt().toString(),
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Contoh Toko',
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      await orderRef.update({
        'remainingAmount': 0.0,
        'status': 'Dibayar Lunas',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran DP berhasil dilunasi')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melunasi DP')),
      );
    }
  }
}
