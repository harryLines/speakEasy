import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;

  ConversationScreen({required this.conversationId});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late Stream<QuerySnapshot> _messagesStream;

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

  @override
  void initState() {
    super.initState();
    // Fetch messages from Firebase Firestore database
    _messagesStream = FirebaseFirestore.instance
        .collection('Conversations')
        .doc(widget.conversationId)
        .collection('Messages')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messagesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              final messages =
                  snapshot.data!.docs.map((doc) => doc.data()).toList();
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = messages[index];
                  final Map<String, dynamic> data =
                      message as Map<String, dynamic>;
                  final futureEmail = getEmailFromUserID(message['senderID']);
                  return FutureBuilder<String?>(
                    future: futureEmail,
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> emailSnapshot) {
                      if (emailSnapshot.hasData) {
                        final email = emailSnapshot.data!;
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    message['text']!,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    message['timestamp']!,
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }
}
