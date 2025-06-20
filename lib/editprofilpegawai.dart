import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Import halaman login

class EditProfilPegawai extends StatefulWidget {
  @override
  _EditProfilPegawaiState createState() => _EditProfilPegawaiState();
}

class _EditProfilPegawaiState extends State<EditProfilPegawai> {
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

  void _loadProfilePicture() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userSnapshot = await _firestore.collection('staffs').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _profilePictureURL = userData['profile_picture'] ?? '';
      });
    }
  }

  void _loadUsername() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userSnapshot = await _firestore.collection('staffs').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _username = userData['username'] ?? '';
      });
    } else {
      setState(() {
        _username = '';
      });
    }
  }

  void _editProfilePicture(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        TaskSnapshot snapshot = await _storage
            .ref()
            .child('profile_photos/${_auth.currentUser!.uid}')
            .putFile(imageFile);

        String downloadURL = await snapshot.ref.getDownloadURL();

        setState(() {
          _profilePictureURL = downloadURL;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_picture_url', downloadURL);

        await _firestore.collection('staffs').doc(_auth.currentUser!.uid).update({'profile_picture': downloadURL});

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

  void _changeUsername(BuildContext context) async {
    TextEditingController _usernameController = TextEditingController();

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
                try {
                  await _firestore
                      .collection('staffs')
                      .doc(_auth.currentUser!.uid)
                      .update({'username': _usernameController.text});

                  _loadUsername();
                  setState(() {});

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

  void _changePassword(BuildContext context) async {
    TextEditingController _passwordController = TextEditingController();

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

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
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
                    backgroundImage: _profilePictureURL.isNotEmpty
                        ? NetworkImage(_profilePictureURL)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.lightBlue,
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
              _username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _changeUsername(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Change Username',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _changePassword(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
