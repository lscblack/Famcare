import 'package:client/globals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:client/screens/dashboard_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String chatId = '';
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    chatId = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF48B1A5)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        foregroundColor: Colors.black87,
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Chat');
            final chatData = snapshot.data!.data() as Map<String, dynamic>?;
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryGreen.withOpacity(0.2),
                  child: Text(
                    (chatData?['name'] ?? 'Chat').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: secondaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatData?['name'] ?? 'Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Active now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date header
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            // Messages list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryGreen,
                      ),
                    );
                  }
                  final messages = snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index].data() as Map<String, dynamic>;
                      final isConsecutive = index < messages.length - 1 &&
                          messages[index + 1]['sender'] == message['sender'];
                      
                      return MessageBubble(
                        message: message,
                        showSenderInfo: !isConsecutive,
                      );
                    },
                  );
                },
              ),
            ),
            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.attach_file_rounded),
            color: Colors.black54,
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _isComposing ? primaryGreen : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isComposing ? Icons.send : Icons.mic,
                color: _isComposing ? Colors.white : Colors.black54,
              ),
              onPressed: () async {
                if (!_isComposing) return;
                
                if (_messageController.text.trim().isEmpty) return;
                final userId = FirebaseAuth.instance.currentUser!.uid;

                // Add message to Firestore
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .add({
                  'sender': userId,
                  'content': _messageController.text.trim(),
                  'type': 'text',
                  'timestamp': Timestamp.now(),
                });

                // Update chat's last message
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .update({
                  'lastMessage': _messageController.text.trim(),
                  'lastUpdated': Timestamp.now(),
                });

                _messageController.clear();
                setState(() {
                  _isComposing = false;
                });
                
                // Scroll to bottom
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool showSenderInfo;
  
  const MessageBubble({
    required this.message,
    this.showSenderInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isMe = message['sender'] == currentUser.uid;

    return Padding(
      padding: EdgeInsets.only(
        top: showSenderInfo ? 12 : 2, 
        bottom: 2,
        left: 8,
        right: 8,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderInfo && !isMe)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(message['sender'])
                  .get(),
              builder: (context, snapshot) {
                final userName = snapshot.data?['fullName'] ?? 'User';
                return Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showSenderInfo)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: primaryBlue.withOpacity(0.2),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(message['sender'])
                        .get(),
                    builder: (context, snapshot) {
                      final userName = snapshot.data?['fullName'] ?? 'User';
                      return Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              if (!isMe && showSenderInfo) SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: isMe
                          ? Radius.circular(18)
                          : Radius.circular(4),
                      bottomRight: isMe
                          ? Radius.circular(4)
                          : Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['content'],
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('h:mm a')
                                .format((message['timestamp'] as Timestamp).toDate()),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.black38,
                            ),
                          ),
                          if (isMe)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
