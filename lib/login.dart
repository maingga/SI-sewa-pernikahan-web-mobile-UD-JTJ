import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'signup.dart';
import 'welcome.dart'; // Import halaman selamat datang
import 'pegawai.dart'; // Import halaman pegawai
import 'cart_provider.dart'; // Import provider keranjang belanja

// Model untuk pengguna
class User {
  final String uid;
  final String email;
  final UserType userType;

  User({
    required this.uid,
    required this.email,
    required this.userType,
  });
}

// Enum untuk tipe pengguna
enum UserType {
  Customer,
  Staff,
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Menentukan jenis pengguna berdasarkan data dari Firebase
      UserType userType = await determineUserType(userCredential.user?.uid);

      // Set the user ID in the CartProvider
      Provider.of<CartProvider>(context, listen: false).setUserId(userCredential.user?.uid);

      // Navigasi sesuai dengan jenis pengguna
      if (userType == UserType.Customer) {
        // Jika pelanggan, navigasikan ke halaman selamat datang
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      } else if (userType == UserType.Staff) {
        // Jika pegawai, navigasikan ke halaman pegawai.dart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PegawaiPage()),
        );
      }
    } catch (e) {
      // Menampilkan pesan kesalahan jika login gagal
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Email atau kata sandi salah. Silakan coba lagi.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<UserType> determineUserType(String? uid) async {
    try {
      // Memeriksa keberadaan UID dalam koleksi 'staffs'
      var staffSnapshot = await FirebaseFirestore.instance.collection('staffs').doc(uid).get();
      if (staffSnapshot.exists) {
        return UserType.Staff; // Pengguna adalah staff
      }

      // Jika tidak ditemukan di koleksi 'staffs', cek di koleksi 'users'
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        return UserType.Customer; // Pengguna adalah customer
      }

      // Jika tidak ditemukan di kedua koleksi, defaultnya adalah pelanggan
      return UserType.Customer;
    } catch (e) {
      print('Error determining user type: $e');
      return UserType.Customer; // Secara default, anggap sebagai pelanggan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.yellow.shade400, Colors.orange.shade700],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.network(
                      'https://lottie.host/06b1c49a-54c6-42bc-b7a7-3e32ed4435e0/pK4OeMUxw2.json',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Selamat datang!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: _isObscure,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text(
                        'Belum punya akun? Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
