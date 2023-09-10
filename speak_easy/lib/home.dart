import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line to import the intl package
import 'package:speak_easy/conversation.dart';
import 'package:speak_easy/main.dart';

import 'new_conversation_page.dart';
import 'user_profile_view.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _conversations = [];
  late String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    _getConversations();
  }

  Future<Map<String, dynamic>> getLatestMessage(String conversationId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Conversations')
        .doc(conversationId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final message = querySnapshot.docs.first.data();
      final text = message['text'];
      final timestamp = message['timestamp'];

      return {'text': text, 'timestamp': timestamp};
    } else {
      return {};
    }
  }

  Future<String?> getNameFromUserID(String ID) async {
    final userDocsSnapshot = FirebaseFirestore.instance
        .collection('Users')
        .where('UserID', isEqualTo: ID)
        .snapshots();
    final userDocs = await userDocsSnapshot.first;
    if (userDocs.docs.isNotEmpty) {
      return userDocs.docs.first['Name'];
    } else {
      return null;
    }
  }

  Future<void> _getConversations() async {
    final userConversations = await FirebaseFirestore.instance
        .collection('Conversations')
        .where('users', arrayContains: currentUserID)
        .get();

    List<Future<Map<String, dynamic>>> latestMessagesFutures = [];

    // Get the latest message for each conversation and the profile image URL for the other user
    for (var doc in userConversations.docs) {
      final conversationId = doc.id;
      final otherUserID =
          doc['users'][0] == currentUserID ? doc['users'][1] : doc['users'][0];

      latestMessagesFutures.add(Future.wait([
        getLatestMessage(conversationId),
        _getProfileImage(otherUserID),
        getNameFromUserID(otherUserID),
      ]).then((results) {
        final message = results[0];
        final profileImage = results[1];
        final name = results[2];
        return {
          'name': name,
          'conversationID': conversationId,
          'latestMessage': message,
          'profileImage': profileImage,
        };
      }));
    }

    final latestMessages = await Future.wait(latestMessagesFutures);

    setState(() {
      _conversations = latestMessages;
    });
  }

  Future<String?> _getProfileImage(String userID) async {
    final ref =
        FirebaseStorage.instance.ref().child('profile_images/$userID.jpg');
    try {
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (error) {
      // If the user has no profile image, set _imageUrl to null
      return null;
    }
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
        _imageUrl = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speak Easy'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50.0,
                backgroundImage:
                    _imageUrl != null ? NetworkImage(_imageUrl) : null,
                child: _imageUrl == null ? Icon(Icons.person) : null,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                'Welcome!',
                style: TextStyle(fontSize: 20.0),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: conversation['profileImage'] != null
                        ? NetworkImage(conversation['profileImage'])
                        : null,
                    child: conversation['profileImage'] == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  title: Text(conversation['name']),
                  subtitle: conversation['latestMessage'].isEmpty
                      ? null
                      : Text(
                          conversation['latestMessage']['text'],
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          conversationId: conversation['conversationID'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.messenger),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewConversationPage(),
            ),
          );
        },
      ),
    );
  }
}
