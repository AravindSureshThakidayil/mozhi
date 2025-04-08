import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // If no user is logged in, show a placeholder
    if (currentUserId == null) {
      return _buildTopBarWithPlaceholder();
    }
    
    // Fetch user data from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_collections')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildTopBarWithLoading();
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildTopBarWithPlaceholder();
        }
        
        // Extract user data
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final username = userData?['username'] ?? 'User';
        final xp = userData?['xp'] ?? 0;
        
        return _buildTopBar(username, xp);
      },
    );
  }
  
  Widget _buildTopBar(String username, int xp) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on,
                                  color: Colors.orange),
                  const SizedBox(width: 5),
                  Text('$xp'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                    // Use profile image if available
                    // backgroundImage: NetworkImage(userProfileImageUrl),
                  ),
                  const SizedBox(width: 8),
                  Text(username),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Color.fromARGB(255, 163, 163, 163),
          thickness: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
  
  Widget _buildTopBarWithLoading() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Color.fromARGB(255, 163, 163, 163),
          thickness: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
  
  Widget _buildTopBarWithPlaceholder() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 5),
                  Text('0'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey,
                    child: Text('?', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 8),
                  Text('Guest'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Color.fromARGB(255, 163, 163, 163),
          thickness: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}