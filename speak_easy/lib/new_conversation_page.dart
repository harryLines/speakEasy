import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewConversationPage extends StatefulWidget {
  @override
  _NewConversationPageState createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  String _searchText = '';

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
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for people to chat with',
              ),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _searchUsers(_searchText),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final email = snapshot.data![index];
                        return ListTile(
                          title: Text(email),
                          onTap: () {
                            // Navigate to chat page with selected user
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

  Future<List<String>> _searchUsers(String searchText) async {
    try {
      // Initialize Firestore
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a reference to the users collection in Firestore
      final CollectionReference usersCollection = firestore.collection('Users');

      // Query Firestore to get users whose email contains the search text
      final QuerySnapshot userSnapshot = await usersCollection
          .where('Email', isGreaterThanOrEqualTo: searchText)
          .where('Email', isLessThan: searchText + 'z')
          .get();
      // Extract user emails from the snapshot
      final matchingUsers =
          userSnapshot.docs.map((doc) => doc['Email'] as String).toList();

      return matchingUsers;
    } catch (e) {
      // Handle any potential errors here
      print('Error searching users: $e');
      return [];
    }
  }
}
