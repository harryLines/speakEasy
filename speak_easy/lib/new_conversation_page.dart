import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speak_easy/conversation.dart';
import "main.dart";

class NewConversationPage extends StatefulWidget {
  @override
  _NewConversationPageState createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  String _searchText = ''; // Define _searchText here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ...

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchUsers(_searchText),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final userData = snapshot.data![index];
                        final email = userData['Email'];
                        final UserID = userData['UserID'];

                        return ListTile(
                          title: Text(email),
                          onTap: () {
                            // Create a new conversation with the selected user
                            _createNewConversation(UserID);
                          },
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create a new conversation with the selected user
  void _createNewConversation(String selectedUserId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new conversation in the Conversations collection
      final newConversation = await firestore.collection('Conversations').add({
        'users': [
          currentUserID,
          selectedUserId
        ], // Add the user IDs to the conversation
      });

      final conversationId = newConversation.id;

      // Navigate to the chat page with the new conversation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(
            conversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      // Handle any potential errors here
      print('Error creating a new conversation: $e');
    }
  }

  // ...

  Future<List<Map<String, dynamic>>> _searchUsers(String searchText) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot userSnapshot = await firestore
          .collection('Users')
          .where('Email', isGreaterThanOrEqualTo: searchText)
          .where('Email', isLessThan: searchText + 'z')
          .get();

      final matchingUsers = userSnapshot.docs.map((doc) {
        return {
          'Email': doc['Email'] as String,
          'UserID': doc['UserID'] as String,
        };
      }).toList();

      return matchingUsers;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
}
