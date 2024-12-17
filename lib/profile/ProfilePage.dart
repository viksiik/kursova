import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../BottomBar.dart';
import '../auth/components/AddData.dart';
import '../program/MainPage.dart';
import '../workouts/WorkoutPage.dart';

class UserProfilePage extends StatefulWidget {
  //final String userId; // The user's ID (passed to the page)

  //UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  String _username = '';
  String _avatarUrl = '';
  File? _imageFile;
  bool _isLoading = false;
  int _currentIndex = 2;
  final currentUser = FirebaseAuth.instance.currentUser;


  // TextEditingController for the username input
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user data from Firestore
  void _loadUserData() async {

    if (currentUser == null) {
      print("No authenticated user found.");
      return ;
    }
    String? userId = currentUser?.uid;
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _username = userData['username'] ?? 'No username';
          _avatarUrl = userData['avatarUrl'] ?? '';
          _usernameController.text = _username;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick a new avatar image
  Future<void> _pickAvatarImage() async {

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload avatar image to Firebase Storage
  Future<String?> _uploadAvatarImage() async {
    String? userId = currentUser?.uid;
    if (_imageFile == null) return null;

    try {
      String fileName = '${userId}_avatar.jpg';
      Reference storageRef = _storage.ref().child('avatars/$fileName');

      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar image: $e');
      return null;
    }
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainWorkoutPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    String? userId = currentUser?.uid;
    try {
      String? newAvatarUrl = await _uploadAvatarImage();

      await _firestore.collection('users').doc(userId).update({
        'username': _usernameController.text,
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
      });

      setState(() {
        _username = _usernameController.text;
        if (newAvatarUrl != null) _avatarUrl = newAvatarUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar Image
              GestureDetector(
                onTap: _pickAvatarImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _avatarUrl.isNotEmpty
                      ? NetworkImage(_avatarUrl) as ImageProvider
                      : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              SizedBox(height: 20),

              // Username Input Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
