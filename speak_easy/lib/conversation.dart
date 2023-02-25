import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speak_easy/main.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;

  ConversationScreen({required this.conversationId});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late Stream<QuerySnapshot> _messagesStream;
  final TextEditingController _messageController = TextEditingController();

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

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      _messageController.clear();
      final senderID = currentUserID; // Replace with actual user ID
      final timestamp = Timestamp.now();
      await FirebaseFirestore.instance
          .collection('Conversations')
          .doc(widget.conversationId)
          .collection('Messages')
          .doc()
          .set({
        'text': messageText,
        'senderID': senderID,
        'timestamp': timestamp,
      });
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        final futureEmail =
                            getEmailFromUserID(message['senderID']);
                        return FutureBuilder<String?>(
                          future: futureEmail,
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> emailSnapshot) {
                            if (emailSnapshot.hasData) {
                              final email = emailSnapshot.data!;
                              final timestamp =
                                  message['timestamp'] as Timestamp;
                              final formattedDate = DateFormat('kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp.seconds * 1000));
                              final isMe = message['senderID'] == currentUserID;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      CircleAvatar(
                                        child: Text(
                                          email[0].toUpperCase(),
                                        ),
                                      ),
                                    SizedBox(width: 8.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            email,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6),
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? Colors.grey[300]
                                                : Theme.of(context)
                                                    .primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            message['text'],
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isMe)
                                      CircleAvatar(
                                        child: Text(
                                          email[0].toUpperCase(),
                                        ),
                                      ),
                                    SizedBox(width: 8.0),
                                  ],
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        );
                      },
                    );
                }
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _messageController,
                      decoration:
                          InputDecoration(hintText: 'Enter a message...'),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
