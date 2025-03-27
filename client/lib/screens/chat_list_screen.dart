import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/globals.dart';
import 'package:client/screens/select_participants_screen.dart' hide User;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
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
  void initState() {
    super.initState();
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        title: const Text('Chats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _currentFilter == 'all',
                  onSelected: () => _updateFilter('all'),
                ),
                _FilterChip(
                  label: 'Unread',
                  selected: _currentFilter == 'unread',
                  onSelected: () => _updateFilter('unread'),
                ),
                _FilterChip(
                  label: 'Groups',
                  selected: _currentFilter == 'groups',
                  onSelected: () => _updateFilter('groups'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectParticipantsScreen(),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getChatStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No chats found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              var chatDoc = snapshot.data!.docs[index];
              return _ChatListItem(chatDoc: chatDoc);
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

  void _updateFilter(String filter) {
    setState(() => _currentFilter = filter);
  }

  Stream<QuerySnapshot> _getChatStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    Query query = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastUpdated', descending: true);

    switch (_currentFilter) {
      case 'unread':
        query = query.where('readBy.${currentUser.uid}', isEqualTo: false);
        break;
      case 'groups':
        query = query.where('isGroup', isEqualTo: true);
        break;
    }

    return query.snapshots();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : Colors.grey,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final DocumentSnapshot chatDoc;

  const _ChatListItem({required this.chatDoc});

  @override
  Widget build(BuildContext context) {
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final lastMessage = chatData['lastMessage'] ?? '';
    final isGroup = chatData['isGroup'] ?? false;
    final unread =
        !(chatData['readBy']?[FirebaseAuth.instance.currentUser?.uid] ?? true);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _ChatAvatar(
        isGroup: isGroup,
        participants: chatData['participants'],
      ),
      title: Row(
        children: [
          Expanded(child: _ChatTitle(chatData: chatData)),
          if (unread) const _UnreadIndicator(),
        ],
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unread ? Colors.black87 : Colors.grey,
          fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: _LastUpdated(chatData['lastUpdated']),
      onTap: () =>
          Navigator.pushNamed(context, '/chat-detail', arguments: chatDoc.id),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final bool isGroup;
  final List<dynamic> participants;

  const _ChatAvatar({required this.isGroup, required this.participants});

  @override
  Widget build(BuildContext context) {
    if (isGroup) {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue,
        child: Icon(Icons.group, color: Colors.white),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _getOtherUser(participants),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?['photoUrl'];
        return CircleAvatar(
          radius: 24,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        );
      },
    );
  }

  Future<DocumentSnapshot> _getOtherUser(List<dynamic> participants) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    return FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();
  }
}

class _ChatTitle extends StatelessWidget {
  final Map<String, dynamic> chatData;

  const _ChatTitle({required this.chatData});

  @override
  Widget build(BuildContext context) {
    if (chatData['isGroup'] ?? false) {
      return Text(
        chatData['groupName'] ?? 'Group Chat',
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _getOtherUser(chatData['participants']),
      builder: (context, snapshot) {
        final displayName = snapshot.data?['fullName'] ?? 'Unknown User';
        return Text(displayName,
            style: const TextStyle(fontWeight: FontWeight.w600));
      },
    );
  }

  Future<DocumentSnapshot> _getOtherUser(List<dynamic> participants) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    return FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();
  }
}

class _LastUpdated extends StatelessWidget {
  final Timestamp? timestamp;

  const _LastUpdated(this.timestamp);

  @override
  Widget build(BuildContext context) {
    return Text(
      timestamp != null ? timeago.format(timestamp!.toDate()) : '',
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.chat)),
              title: Text(chatDoc['isGroup']
                  ? chatDoc['groupName'] ?? 'Group Chat'
                  : 'Direct Message'),
              onTap: () {
                close(context, '');
                Navigator.pushNamed(context, '/chat-detail',
                    arguments: chatDoc.id);
              },
            );
          },
        );
      },
    );
  }
}
