import 'package:flutter/material.dart';
import 'package:ud_joko_tarub_jingga/cart_page.dart';
import 'package:flutter/services.dart'; // Perlu diimpor untuk akses SystemChrome
import 'fragment1.dart';
import 'fragment2.dart';
import 'fragment3.dart';
import 'fragment4.dart';
import 'AboutPage.dart';
import 'HistoryPage.dart';
import 'SearchPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:ud_joko_tarub_jingga/signup.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.purple[200], // Atur warna status bar sesuai dengan warna bottom navigation bar
    statusBarIconBrightness: Brightness.dark, // Atur ikon status bar supaya lebih terlihat dengan warna gelap
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
    );
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  String _userName = 'User'; // Default username
  late StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _getUserDisplayName();
    _initUserDisplayNameListener();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _initUserDisplayNameListener() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _userName = (snapshot.data() as Map<String, dynamic>?)?['username'] ?? 'User';
          });
        }
      }, onError: (error) {
        _showError('Error listening to user data: $error');
      });
    }
  }

  void _getUserDisplayName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userSnapshot.exists) {
          setState(() {
            _userName = (userSnapshot.data() as Map<String, dynamic>?)?['username'] ?? 'User';
          });
        }
      }
    } catch (e) {
      _showError('Error getting user display name: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.purple[200], // Atur warna latar belakang AppBar sesuai dengan bottom navigation bar
        title: Text(
          'Welcome',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple[200],
              ),
              child: Text(
                'Hello, $_userName!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.black87),
              title: Text(
                'Riwayat',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.black87),
              title: Text(
                'Tentang',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.black87),
              title: Text(
                'Buat Akun',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildFragment(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple[200], // Warna latar belakang bottom navigation bar ungu muda
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
            backgroundColor: Colors.purple[300], // Warna latar belakang item ungu muda yang sedikit lebih terang
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Paket',
            backgroundColor: Colors.purple[400], // Warna latar belakang item ungu muda utama
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.curtains),
            label: 'Alat/Dekor',
            backgroundColor: Colors.purple[500], // Warna latar belakang item ungu muda yang sedikit lebih gelap
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
            backgroundColor: Colors.purple[600], // Warna latar belakang item ungu muda yang lebih gelap lagi
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildFragment(int index) {
    switch (index) {
      case 0:
        return Fragment1();
      case 1:
        return Fragment2();
      case 2:
        return Fragment3();
      case 3:
        return Fragment4();
      default:
        return Fragment1();
    }
  }
}
