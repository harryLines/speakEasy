import 'dart:io';
import 'package:speak_easy/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late File _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
// Load the user's profile image from Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/$currentUserID.jpg');
    try {
      final url = await ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });
    } catch (error) {
      // If the user has no profile image, set _imageUrl to null
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<void> _uploadImage(File image) async {
// Upload the user's new profile image to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/$currentUserID.jpg');
    final task = ref.putFile(image);
    await task.whenComplete(() {});
    final url = await ref.getDownloadURL();

// Update the user's profile image URL in Firestore
    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .update({'pictureURL': url});
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// Allow the user to select an image from their device
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _uploadImage(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imageUrl!),
              ),
            if (_imageUrl == null)
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Change Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
