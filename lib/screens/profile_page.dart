// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
import 'package:mozhi/screens/rank_Screen.dart';
import 'package:mozhi/authentication/screens/login.dart';
import 'package:mozhi/authentication/screens/signout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:mozhi/methods/camera_service.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSignedIn = FirebaseAuth.instance.currentUser != null;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _disableCamera();
  }

// Method to disable camera
  void _disableCamera() async {
    try {
      // Get list of cameras
      final cameras = await availableCameras();

      // For each camera, create a controller and dispose it immediately
      // This ensures any active camera instances are properly shut down
      for (var camera in cameras) {
        final controller = CameraController(
          camera,
          ResolutionPreset.low,
          enableAudio: false,
        );

        // Initialize and then immediately dispose
        await controller.initialize();
        await controller.dispose();
      }

      print('Camera disabled in ProfileScreen');
    } catch (e) {
      print('Error while disabling camera in ProfileScreen: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('user_collections')
          .doc(user.uid)
          .get();
    } else {
      // Handle the case where the user is not signed in
      return Future.error('User not signed in');
    }
  }

  Future<Map<String, String>> fetchLessonChapterMappings() async {
    Map<String, String> lessonIdToChapter = {};
    try {
      final chaptersRef = FirebaseFirestore.instance.collection('chapters');
      final chaptersSnapshot = await chaptersRef.get();

      for (var chapterDoc in chaptersSnapshot.docs) {
        final chapterData = chapterDoc.data();
        final chapterName = chapterData['name'] ?? 'Unknown Chapter';
        final chapterNumber = chapterDoc.id;

        final lessonsRef = chapterDoc.reference.collection('lessons');
        final lessonsSnapshot = await lessonsRef.get();

        for (var lessonDoc in lessonsSnapshot.docs) {
          final lessonId = 'chapters/${chapterNumber}/lessons/${lessonDoc.id}';
          lessonIdToChapter[lessonId] =
              'Chapter ${chapterNumber}: ${chapterName}';
        }
      }

      print(
          'Successfully fetched ${lessonIdToChapter.length} lesson-to-chapter mappings');
    } catch (e) {
      print('Error fetching chapter data: $e');
    }

    return lessonIdToChapter;
  }

  void _sendToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _sendToLogout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _isSignedIn = false;
    });
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignoutScreen()));
  }

  Widget sidebarElement(String title, IconData icon, bool isActive,
      [Function? method]) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (method != null) {
            method();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B3B3B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    final userData = snapshot.data!.data();
    final username = userData?['username'] as String? ?? 'Guest';
    final email = userData?['email'] as String? ?? '';
    const profileImageUrl =
        ''; // You might have a profile image URL in Firebase

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              print('Tapped to change profile picture');
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: profileImageUrl.isNotEmpty
                      ? Image.network(
                          profileImageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                size: 80, color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.person, size: 80, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 196, 35, 205),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildXpProgress(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    final userData = snapshot.data!.data();
    final xp = userData?['xp'] as int? ?? 0;
    const maxXp = 100; // You might want to fetch this from somewhere

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'XP Progress',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 10,
              width: (xp / maxXp) * MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: (xp / maxXp) * MediaQuery.of(context).size.width * 0.6 +
                      8),
              child:
                  Text('$xp / $maxXp XP', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompletedLessons(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    final userData = snapshot.data!.data();
    final completedLessonsData =
        userData?['lessons_completed'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> completedLessons =
        completedLessonsData.map((item) {
      final completedTimestamp = item['completed'] as String?;
      DateTime? completedAt;
      if (completedTimestamp != null) {
        completedAt = DateTime.tryParse(completedTimestamp);
      }
      return {
        'lessonId': item['lessonid'] as String? ?? 'Unknown Lesson',
        'completedAt': completedAt,
      };
    }).toList();

    // Group completed lessons by chapter
    final Map<String, List<Map<String, dynamic>>> lessonsByChapter = {};
    for (var lesson in completedLessons) {
      final lessonId = lesson['lessonId'];
      // Extract chapter number from reference path
      String chapterNumber = 'Unknown';
      final RegExp regExp = RegExp(r'chapters/(\d+)/');
      final match = regExp.firstMatch(lessonId);
      if (match != null && match.groupCount >= 1) {
        chapterNumber = match.group(1)!;
      }

      final chapterName = 'Chapter $chapterNumber';
      if (!lessonsByChapter.containsKey(chapterName)) {
        lessonsByChapter[chapterName] = [];
      }
      lessonsByChapter[chapterName]!.add(lesson);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Completed Lessons',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (completedLessons.isEmpty)
          const Text('No lessons completed yet.')
        else
          ...lessonsByChapter.entries.map((entry) {
            final chapterName = entry.key;
            final lessonsInChapter = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapterName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessonsInChapter.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lesson = lessonsInChapter[index];
                    final lessonId = lesson['lessonId'];
                    RegExp pattern = RegExp(r".*chapters/([A-Z|1-9]+)");
                    var chapterId = pattern.firstMatch(lessonId)![0];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .doc(chapterId.toString())
                          .get(),
                      builder: (context, lessonSnapshot) {
                        String lessonName = lessonId;
                        // print("\033[46m" + lessonId.toString() + "\033[0m");
                        if (lessonSnapshot.hasData &&
                            lessonSnapshot.data != null) {
                          final lessonData = lessonSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          lessonName = lessonData?['title'] ?? lessonId;
                        }

                        final DateTime? completedAt = lesson['completedAt'];
                        String formattedDate = 'N/A';
                        String formattedTime = 'N/A';
                        if (completedAt != null) {
                          formattedDate =
                              DateFormat('dd-MM-yyyy').format(completedAt);
                          formattedTime =
                              DateFormat('HH:mm').format(completedAt);
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          title: Text(lessonName),
                          subtitle: Text(
                            'Completed on $formattedDate at $formattedTime',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            print(
                                'Tapped on completed lesson: $lessonName in $chapterName');
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          children: [
            // Sidebar Section
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black,
              width: 200,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 80, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              AssetImage('../assets/mozhilogo.jpg'),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const Text(
                            "MOZHI",
                            textScaler: TextScaler.linear(3),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Squada One",
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sidebarElement("Home", Icons.home, false, () {
                    if (Navigator.of(context).canPop()) {
                      // Navigate back to the first route (home page)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    // If we're already on the home page, do nothing
                  }),
                  const SizedBox(height: 10),
                  sidebarElement("Rankings", Icons.bar_chart, false, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RankScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  sidebarElement("Profile", Icons.person_outline, true),
                  const SizedBox(height: 10),
                  //_evaluationButton(),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      children: [
                        //sidebarElement("Settings", Icons.settings, false),
                        _isSignedIn
                            ? sidebarElement(
                                "Logout", Icons.logout, false, _sendToLogout)
                            : sidebarElement(
                                "Login", Icons.login, false, _sendToLogin),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile Content Section
            Expanded(
              child: Container(
                color: Colors.black,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SingleChildScrollView(
                    child:
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: _userDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error loading profile: ${snapshot.error}'));
                        } else if (snapshot.hasData && snapshot.data!.exists) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeader(snapshot),
                              const SizedBox(height: 20),
                              _buildXpProgress(snapshot),
                              const SizedBox(height: 20),
                              _buildCompletedLessons(snapshot),
                            ],
                          );
                        } else {
                          return const Center(
                              child: Text('Profile data not found.'));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evaluationButton({context}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Evaluation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
