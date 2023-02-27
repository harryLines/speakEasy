import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/$currentUserID.jpg');
    try {
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    } catch (error) {
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<void> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/$currentUserID.jpg');
    final task = ref.putFile(image);
    await task.whenComplete(() {});
    final url = await ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .update({'pictureURL': url});
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _uploadImage(_image);
    }
  }

  Future<void> _changePassword() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'New Password'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                _updatePassword(_passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(String password) async {
// Update the user's password in the database
    final userCollection = FirebaseFirestore.instance.collection('Users');
    final userId = currentUserID; // replace with your chosen UserID
    final userDoc =
        await userCollection.where('UserID', isEqualTo: userId).get();

    if (userDoc.size == 1) {
      final userRef = userDoc.docs.first.reference;
      await userRef.update({'Password': password});
    } else {
      // handle error when no or multiple documents are found
    }
    ;

    final user = FirebaseAuth.instance.currentUser;
    try {
      await user!.updatePassword(password);
    } catch (error) {
      print('Error updating password: $error');
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
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 75.0,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                child: _imageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 75.0,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
