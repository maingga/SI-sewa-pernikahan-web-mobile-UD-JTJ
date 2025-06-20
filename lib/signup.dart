import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:ud_joko_tarub_jingga/login.dart';
import 'package:ud_joko_tarub_jingga/welcome.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Simpan data pengguna di Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      String errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          errorMessage = 'Kata sandi terlalu lemah.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Email sudah digunakan pada akun lain.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Alamat email tidak valid.';
        }
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.yellow[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icons/sign-up.png',
                    width: 80.0,
                    height: 80.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Silahkan mendaftar!',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 197, 197, 56),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _usernameController,
                    style: TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                   backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  icon: Icon(Icons.person_add, size: 24.0),
                  label: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(16),
                  ),
                  child: Text(
                    'Sudah memiliki akun? Login',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
