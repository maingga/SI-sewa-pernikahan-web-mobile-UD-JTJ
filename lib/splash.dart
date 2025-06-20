import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // Import CartProvider
import 'package:firebase_auth/firebase_auth.dart';
import 'OnboardingScreen.dart'; // Ganti dengan lokasi OnboardingScreen Anda

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animationLoaded = false;

  @override
  void initState() {
    super.initState();
    // Memeriksa koneksi internet dan menginisialisasi CartProvider
    _checkInternetAndInitCart();
  }

  Future<void> _checkInternetAndInitCart() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // Memeriksa status login user
      _checkLoginStatus();
    } else {
      // Tampilkan pesan kesalahan jika tidak ada koneksi internet
      _showErrorDialog("No internet connection");
    }
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Set user ID di CartProvider jika user sudah login
      Provider.of<CartProvider>(context, listen: false).setUserId(user.uid);
    } else {
      // Jika user belum login, bisa memberikan ID dummy atau mengarahkan ke layar login
      Provider.of<CartProvider>(context, listen: false).setUserId("dummy_user_id");
    }

    // Navigasi ke OnboardingScreen setelah penundaan singkat
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 223, 186),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Kesalahan Koneksi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Keluar dari aplikasi saat tombol "Tutup" ditekan
                    SystemNavigator.pop();
                  },
                  child: Text(
                    "Tutup",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Add this
      ),
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 255, 223, 186), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Lottie.network(
                  'https://lottie.host/ddc18124-88c8-4d2a-9d50-0770f77edd28/InqEkwKQwt.json',
                  alignment: Alignment.center,
                  onLoaded: (composition) {
                    setState(() {
                      _animationLoaded = true;
                    });
                  },
                ),
              ),
              // Display text only if the animation is loaded
              if (_animationLoaded)
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'UD Joko Tarub Jingga',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 214, 204, 117),
                        fontFamily: 'Inspiration', // Change the font as desired
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
