import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speak_easy/conversation.dart';
import 'package:speak_easy/main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _conversations = [];

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

  Future<String?> getEmailFromUserID(String ID) async {
    final userDocsSnapshot = FirebaseFirestore.instance
        .collection('Users')
        .where('UserID', isEqualTo: ID)
        .snapshots();
    final userDocs = await userDocsSnapshot.first;
    if (userDocs.docs.isNotEmpty) {
      return userDocs.docs.first['Email'];
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

    // Get the latest message for each conversation
    for (var doc in userConversations.docs) {
      final conversationId = doc.id;
      final otherUserID =
          doc['users'][0] == currentUserID ? doc['users'][1] : doc['users'][0];

      latestMessagesFutures
          .add(getLatestMessage(conversationId).then((message) {
        return {
          'name': otherUserID,
          'conversationID': conversationId,
          'latestMessage': message,
        };
      }));
    }

    final latestMessages = await Future.wait(latestMessagesFutures);

    setState(() {
      _conversations = latestMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Messaging App'),
      ),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (BuildContext context, int index) {
          final conversation = _conversations[index];
          final latestMessage = conversation['latestMessage'] ?? {};

          return FutureBuilder<String?>(
            future: getEmailFromUserID(conversation['name']),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("N"),
                  ),
                  title: Text(snapshot.data!),
                  subtitle: Text(latestMessage['text'] ?? ''),
                  trailing: Text(latestMessage['timestamp']?.toString() ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          conversationId: conversation['conversationID']!,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      ),
    );
  }
}
