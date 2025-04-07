import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankScreen extends StatefulWidget {
  @override
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  bool _isLoading = false;
  String _sortBy = 'xp';
  bool _isDescending = true;
  int _itemsPerPage = 10;
  int _currentPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Rankings'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Rankings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting options card
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: [
                      DropdownMenuItem(value: 'xp', child: Text('XP')),
                      DropdownMenuItem(value: 'username', child: Text('Name')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _currentPage = 0; // Reset to first page when sorting changes
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  Text('Order: '),
                  IconButton(
                    icon: Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward),
                    onPressed: () {
                      setState(() {
                        _isDescending = !_isDescending;
                        _currentPage = 0; // Reset to first page when order changes
                      });
                    },
                    tooltip: _isDescending ? 'Descending' : 'Ascending',
                  ),
                ],
              ),
            ),
          ),
          
          // Rankings list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user_collections')
                  .orderBy(_sortBy, descending: _isDescending)
                  .snapshots(),
              builder: (context, snapshot) {
                // Handle loading state without calling setState
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No rankings available.', 
                          style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      ],
                    )
                  );
                }

                final users = snapshot.data!.docs;
                final int totalPages = (users.length / _itemsPerPage).ceil();
                
                // Calculate paginated data
                final int startIndex = _currentPage * _itemsPerPage;
                final int endIndex = startIndex + _itemsPerPage > users.length 
                    ? users.length 
                    : startIndex + _itemsPerPage;
                
                // Ensure valid page range
                if (startIndex >= users.length && _currentPage > 0) {
                  // This is a post-frame callback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _currentPage = (users.length / _itemsPerPage).ceil() - 1;
                    });
                  });
                  // Return loading indicator while we're adjusting the page
                  return Center(child: CircularProgressIndicator());
                }
                
                final List<QueryDocumentSnapshot> paginatedUsers = 
                    users.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    // Header with column labels
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(width: 30, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 8),
                          Expanded(child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 80,
                            child: Text('XP', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Divider(height: 1, thickness: 1),
                    
                    // User list
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedUsers.length,
                        itemBuilder: (context, index) {
                          final user = paginatedUsers[index];
                          final globalRank = startIndex + index + 1;
                          
                          // Determine background color based on rank
                          Color? bgColor;
                          if (globalRank == 1) bgColor = Colors.amber[100];
                          else if (globalRank == 2) bgColor = Colors.blueGrey[100];
                          else if (globalRank == 3) bgColor = Colors.brown[100];
                          
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: bgColor,
                            child: ListTile(
                              leading: Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  '$globalRank',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: globalRank <= 3 ? Colors.deepPurple : null,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.primaries[globalRank % Colors.primaries.length],
                                    child: Text('${user['username']?[0].toUpperCase() ?? '#'}', style: TextStyle(color: Colors.white)),
                                    radius: 18,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user['username'] ?? 'No Name',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  '${user['xp'] ?? 0}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Pagination controls
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0 
                                ? () => setState(() => _currentPage--) 
                                : null,
                            tooltip: 'Previous Page',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Page ${_currentPage + 1} of $totalPages',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1 
                                ? () => setState(() => _currentPage++) 
                                : null,
                            tooltip: 'Next Page',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}