import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Text(
                    'Search your records',
                    style: const TextStyle(
                      color: Color(0xFF003F5F),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.search, color: Colors.black87, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // Predefined suggestions
  final List<String> _suggestions = [
    'My medicines',
    'Medical history',
    'Prescription',
    'Health checkup'
  ];
  
  // Store filtered suggestions
  List<String> _filteredSuggestions = [];
  
  // Store recent searches
  List<String> _recentSearches = [];

  // Map to store category icons
  final Map<String, IconData> _categoryIcons = {
    'My medicines': Icons.medication,
    'Medical history': Icons.history_edu,
    'Prescription': Icons.receipt,
    'Health checkup': Icons.health_and_safety,
    // Default icon for other searches
    'default': Icons.search,
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    // Initialize with all suggestions
    _filteredSuggestions = List.from(_suggestions);
  }

  void _onSearchChanged() {
    setState(() {
      if (_controller.text.isEmpty) {
        // Show all suggestions when search field is empty
        _filteredSuggestions = List.from(_suggestions);
      } else {
        // Filter suggestions based on input
        _filteredSuggestions = _suggestions
            .where((s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
            .toList();
      }
    });
  }

  // Add search to recent searches
  void _addToRecentSearches(String search) {
    setState(() {
      // Remove if already exists to avoid duplicates
      _recentSearches.remove(search);
      // Add to the beginning of the list
      _recentSearches.insert(0, search);
      // Keep only the last 5 recent searches
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    // Clear the search field
    _controller.clear();
  }

  // Get appropriate icon for a search term
  IconData _getIconForSearch(String searchTerm) {
    // Check if we have a specific icon for this search term
    for (var key in _categoryIcons.keys) {
      if (searchTerm.toLowerCase().contains(key.toLowerCase()) && key != 'default') {
        return _categoryIcons[key]!;
      }
    }
    // Return default icon if no match found
    return _categoryIcons['default']!;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input field with cancel and search buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Search icon
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.search, color: Color(0xFF3F8585)),
                  ),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Color(0xFF003F5F)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addToRecentSearches(value);
                        }
                      },
                    ),
                  ),
                  // Clear button (only visible when text is entered)
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _controller.clear();
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                    ),
                  // Search button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF3F8585)),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _addToRecentSearches(_controller.text);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Suggestions section
            if (_filteredSuggestions.isNotEmpty && _controller.text.isNotEmpty) ...[
              const Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003F5F),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return ListTile(
                      leading: Icon(
                        _getIconForSearch(suggestion),
                        color: const Color(0xFF3F8585),
                      ),
                      title: Text(suggestion),
                      onTap: () {
                        _addToRecentSearches(suggestion);
                      },
                    );
                  },
                ),
              ),
            ],
            
            // Recent searches section
            if (_recentSearches.isNotEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003F5F),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final recentSearch = _recentSearches[index];
                  return ListTile(
                    leading: Icon(
                      _getIconForSearch(recentSearch),
                      color: const Color(0xFF3F8585),
                    ),
                    title: Text(recentSearch),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _recentSearches.removeAt(index);
                        });
                      },
                    ),
                    onTap: () {
                      _controller.text = recentSearch;
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                  );
                },
              ),
            ],
            
            // Show all suggestions if there's no search text and no recent searches
            if (_controller.text.isEmpty && _recentSearches.isEmpty) ...[
              const Text(
                'Suggested Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003F5F),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      leading: Icon(
                        _getIconForSearch(suggestion),
                        color: const Color(0xFF3F8585),
                      ),
                      title: Text(suggestion),
                      onTap: () {
                        _addToRecentSearches(suggestion);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}