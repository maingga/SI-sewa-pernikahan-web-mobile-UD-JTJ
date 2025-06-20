import 'package:flutter/material.dart';
import 'login.dart'; // Import file login.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Fragment4 extends StatefulWidget {
  @override
  _Fragment4State createState() => _Fragment4State();
}

class _Fragment4State extends State<Fragment4> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  String _profilePictureURL = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _loadUsername();
  }

  // Fungsi untuk memuat URL gambar profil dari Firestore
  void _loadProfilePicture() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
    if (userSnapshot.exists && userSnapshot.data() != null) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _profilePictureURL = userData['profile_picture'] ?? '';
      });
    }
  }

  void _loadUsername() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
    if (userSnapshot.exists && userSnapshot.data() != null) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _username = userData['username'] ?? ''; // Ambil username dari Firestore
      });
    } else {
      setState(() {
        _username = '';
      });
    }
  }

  // Fungsi untuk logout
  void _logout(BuildContext context) async {
    await _auth.signOut();
    // Pindah ke halaman login.dart
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  // Fungsi untuk mengedit foto profil
  void _editProfilePicture(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload gambar ke Firebase Storage
      try {
        TaskSnapshot snapshot = await _storage
            .ref()
            .child('profile_pictures/${_auth.currentUser!.uid}')
            .putFile(imageFile);

        // Dapatkan URL gambar yang diunggah
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Perbarui gambar profil di CircleAvatar
        setState(() {
          _profilePictureURL = downloadURL; // Simpan URL gambar untuk digunakan di widget CircleAvatar
        });

        // Simpan URL gambar di Firestore
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'profile_picture': downloadURL});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile picture updated successfully'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update profile picture'),
        ));
      }
    }
  }

  // Fungsi untuk mengubah username
  void _changeUsername(BuildContext context) async {
    TextEditingController _usernameController = TextEditingController();

    // Tampilkan dialog untuk pengguna memasukkan username baru
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Enter new username'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update username di Firestore
                try {
                  await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'username': _usernameController.text});

                  // Perbarui nilai _username dan tampilan UI
                  _loadUsername();
                  setState(() {}); // Memperbarui tampilan UI

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Username changed successfully'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to change username'),
                  ));
                }

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengubah password
  void _changePassword(BuildContext context) async {
    TextEditingController _passwordController = TextEditingController();

    // Tampilkan dialog untuk pengguna memasukkan password baru
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter new password'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update password di Firebase Authentication
                try {
                  await _auth.currentUser!.updatePassword(_passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Password changed successfully'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to change password'),
                  ));
                }

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 220, 198, 224), // Warna ungu muda
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    // Tampilkan gambar profil dari Firebase Storage
                    backgroundImage: _profilePictureURL.isNotEmpty ? NetworkImage(_profilePictureURL) : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple, // Warna ungu muda
                    ),
                    padding: EdgeInsets.all(6),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      color: Colors.white,
                      onPressed: () {
                        _editProfilePicture(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _username, // Gunakan nilai username yang diperoleh dari Firestore
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _changeUsername(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 237, 135, 255), // Warna ungu muda
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Change Username',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _changePassword(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 237, 135, 255), // Warna ungu muda
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Panggil fungsi logout saat tombol logout ditekan
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 100, 89),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
