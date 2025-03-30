import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/globals.dart';
import 'package:client/screens/select_participants_screen.dart' hide User;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'package:client/screens/dashboard_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 3; // Setting to 3 since this is the chat tab
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('en', timeago.EnMessages());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        backgroundColor: primaryGreen,
        title: const Text(
          'Conversations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectParticipantsScreen(),
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: primaryBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _getChatStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return FadeTransition(
                  opacity: _animation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: primaryGreen.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            color: secondaryGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start a new chat by pressing the + button',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return FadeTransition(
                opacity: _animation,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var chatDoc = snapshot.data!.docs[index];
                    return _ChatListItem(chatDoc: chatDoc);
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectParticipantsScreen(),
          ),
        ),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.chat, color: Colors.white),
        elevation: 4,
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
          // Already on chat screen, no need to navigate
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
        currentIndex: currentIndex,
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
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: secondaryGreen,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.white : Colors.white30,
          width: 1,
        ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: unread ? primaryBlue.withOpacity(0.15) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: unread
            ? Border.all(color: primaryBlue.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: _ChatAvatar(
          isGroup: isGroup,
          participants: chatData['participants'],
        ),
        title: Row(
          children: [
            Expanded(child: _ChatTitle(chatData: chatData)),
            const SizedBox(width: 4),
            if (unread) const _UnreadIndicator(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unread ? Colors.black87 : Colors.grey.shade600,
                fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            _LastUpdated(chatData['lastUpdated']),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: () =>
            Navigator.pushNamed(context, '/chat-detail', arguments: chatDoc.id),
      ),
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
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryBlue, Color(0xFF5B86FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.group, color: Colors.white, size: 28),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _getOtherUser(participants),
      builder: (context, snapshot) {
        final String initial = snapshot.hasData && snapshot.data?['fullName'] != null
            ? snapshot.data!['fullName'].toString().substring(0, 1).toUpperCase()
            : '?';
            
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: secondaryGreen,
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _getOtherUser(chatData['participants']),
      builder: (context, snapshot) {
        final displayName = snapshot.data?['fullName'] ?? 'Unknown User';
        return Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: secondaryGreen,
          ),
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

class _LastUpdated extends StatelessWidget {
  final Timestamp? timestamp;

  const _LastUpdated(this.timestamp);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          timestamp != null ? timeago.format(timestamp!.toDate()) : '',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: primaryBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x882260FF),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        headlineMedium: const TextStyle(color: Colors.white),
      ),
    );
  }

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

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search for conversations',
              style: TextStyle(
                color: secondaryGreen,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
            ),
          );

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: primaryGreen.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(
                    color: secondaryGreen,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: chatData['isGroup'] 
                          ? [primaryBlue, const Color(0xFF5B86FF)]
                          : [primaryGreen, secondaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    chatData['isGroup'] ? Icons.group : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  chatData['isGroup']
                      ? chatData['groupName'] ?? 'Group Chat'
                      : 'Direct Message',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondaryGreen,
                  ),
                ),
                subtitle: Text(
                  chatData['lastMessage'] ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: () {
                  close(context, '');
                  Navigator.pushNamed(context, '/chat-detail',
                      arguments: chatDoc.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}