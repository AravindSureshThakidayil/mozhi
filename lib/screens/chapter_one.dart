import 'package:flutter/material.dart';
import './lesson_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterScreen extends StatefulWidget {
  final int chapterNumber;

  const ChapterScreen({super.key, required this.chapterNumber});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  Future<List<Widget>> readLessons() async {
    List<Widget> lessonsData = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chapters/${widget.chapterNumber}/lessons')
              .get();

      Map<String, dynamic> lessonData;
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        lessonData = doc.data();
        lessonsData.add(_buildLessonCard(
            title: "Lesson ${doc.id}",
            subtitle: lessonData['title'],
            isUnlocked: true,
            onTap: () => _navigateToLesson(lessonData['title'], widget.chapterNumber,false)));
      }
      return lessonsData;
    } catch (e) {
      // print('Error reading lessons for chapter ${widget.chapterNumber}: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _navigateToLesson(String sign,int chapterNumber, bool isLocked) {
    if (isLocked) {
      // Show a dialog or snackbar indicating the chapter is locked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This lesson is locked. Complete previous lessons first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Widget lessonScreen = LessonScreen(symbol: sign,chapterNumber: chapterNumber);
    // You might want to pass the lessonNumber or other relevant data to the LessonScreen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => lessonScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuint,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget sidebarElement(String title, IconData icon, bool isActive,
      [Function? method]) {
    return GestureDetector(
      onTap: () {
        if (method != null) {
          method();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B3B3B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
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
    );
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double progressValue = 0.3;
    String chapterTitle;
    String chapterSubtitle;

    switch (widget.chapterNumber) {
      case 1:
        chapterTitle = "Chapter 1";
        chapterSubtitle = "GETTING STARTED";
        break;
      case 2:
        chapterTitle = "Chapter 2";
        chapterSubtitle = "FINGER SPELL IT";
        break;
      default:
        chapterTitle = "Chapter ${widget.chapterNumber}";
        chapterSubtitle = "Learning Module";
        break;
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            // left sidebar
            padding: const EdgeInsets.all(10),
            color: Colors.black,
            width: 200,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 100, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
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
                sidebarElement("Home", Icons.home, true, _goBack),
                const SizedBox(height: 10),
                sidebarElement("Rankings", Icons.bar_chart, false),
                const SizedBox(height: 10),
                sidebarElement("Profile", Icons.person_outline, false),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      sidebarElement("Settings", Icons.settings, false),
                      sidebarElement("Logout", Icons.logout, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: width - 200,
            color: Colors.black,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with streak and profile - Exact match from main.dart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                color: Colors.orange),
                            SizedBox(width: 5),
                            Text('365'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  AssetImage('../assets/stephen.jpg'),
                            ),
                            SizedBox(width: 8),
                            Text('Stephen'),
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

                  // Chapter-specific content below
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                chapterTitle,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                chapterSubtitle,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "Learn the universal language of numbers through gestures",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              const Divider(
                                color: Colors.black,
                                thickness: 2,
                                indent: 20,
                                endIndent: 20,
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Progress: ${(progressValue * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green[500],
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(height: 25),
                              const SizedBox(height: 10),
                              Expanded(
                                  child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      child: SingleChildScrollView(
                                        child: FutureBuilder<List<Widget>>(
                                          future: readLessons(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return const Center(
                                                  child: Text(
                                                      'No widgets found.'));
                                            } else {
                                              return Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                alignment:
                                                    WrapAlignment.spaceAround,
                                                children: snapshot.data!,
                                              );
                                            }
                                          },
                                        ),
                                      ))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5DFD2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset('../assets/hand1.png', height: 150),
                              Image.asset('../assets/hand2.png', height: 150),
                              Image.asset('../assets/hand3.png', height: 150),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard({
    required String title,
    required String subtitle,
    bool isUnlocked = false,
    bool isCompleted = false,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 100,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isUnlocked ? Colors.black87 : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 24)
                  else if (isUnlocked)
                    const Icon(Icons.play_circle_fill,
                        color: Colors.deepPurple, size: 24)
                  else
                    const Icon(Icons.lock, color: Colors.grey, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
