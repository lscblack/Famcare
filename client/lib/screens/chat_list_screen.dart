import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/screens/select_participants_screen.dart' hide User;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int currentIndex = 0;
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterButton('All', 'all'),
              _filterButton('Unread', 'unread'),
              _filterButton('Groups', 'groups'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              showSearch(context: context, delegate: ChatSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectParticipantsScreen()),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getChatStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chatDoc = snapshot.data!.docs[index];
              return _buildChatListItem(chatDoc);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        onHomePressed: () {
          print("Home Pressed");
        },
        onCalendarPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        onRecordPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );
        },
        onChatPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
        currentIndex: currentIndex, // Pass currentIndex
      ),
    );
  }

  Widget _filterButton(String title, String filter) {
    return TextButton(
      onPressed: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: _currentFilter == filter ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getChatStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    Query query = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastUpdated', descending: true);

    // Apply filters based on _currentFilter
    switch (_currentFilter) {
      case 'unread':
        // TODO: Implement unread filter logic
        break;
      case 'groups':
        query = query.where('participants', isGreaterThan: 2);
        break;
    }

    return query.snapshots();
  }

  Widget _buildChatListItem(DocumentSnapshot chatDoc) {
    Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

    return ListTile(
      leading: CircleAvatar(
        // TODO: Add user/group avatar logic
        backgroundColor: Colors.blue,
      ),
      title: Text(_getChatTitle(chatData)),
      subtitle: Text(chatData['lastMessage'] ?? ''),
      trailing: Text(_formatTimestamp(chatData['lastUpdated'])),
      onTap: () {
        // Navigate to individual chat screen
        Navigator.of(context).pushNamed('/chat-detail', arguments: chatDoc.id);
      },
    );
  }

  String _getChatTitle(Map<String, dynamic> chatData) {
    // TODO: Implement logic to get chat title
    // For groups, use group name
    // For 1:1 chats, use other participant's name
    return 'Chat Title';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    // TODO: Implement proper timestamp formatting
    // Show relative time (e.g., "5m ago", "2h ago", etc.)
    return timestamp.toDate().toString();
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement search results
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: Implement search suggestions
    return Container();
  }
}
