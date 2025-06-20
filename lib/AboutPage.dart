import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
        backgroundColor: Colors.purple[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/icons/wedding.png'), // Ganti dengan path logo Anda
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'UD Joko Tarub Jingga',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                ),
              ),
              SizedBox(height: 40),
              Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: Icon(Icons.description, color: Colors.purple[700]),
                  title: Text('Deskripsi Aplikasi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Aplikasi SISTEM INFORMASI SEWA PERNIKAHAN UD JOKO TARUB JINGGA BERBASIS MOBILE. '
                    'Tujuan dari aplikasi ini adalah untuk project laporan akhir dan menunjukkan berbagai fitur dan konsep dalam pengembangan aplikasi mobile '
                    'menggunakan Flutter framework.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: Icon(Icons.info, color: Colors.purple[700]),
                  title: Text('Versi Aplikasi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('1.0.0', style: TextStyle(fontSize: 16)),
                ),
              ),
              Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.purple[700]),
                  title: Text('Pengembang:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Ahmad Nana Maingga\n2131730069\nnanamaingga12@gmail.com\n087754532633',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
