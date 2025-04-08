import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mozhi/methods/initchapters.dart';
import 'firebase_options.dart';
import 'package:mozhi/components/sidebar.dart';
import 'package:mozhi/components/topbar.dart';
import 'package:mozhi/components/chapter_card.dart';
import './screens/chapter_one.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOZHI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MOZHI Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initializeChapterCount();
  }

  Future<double> getUserProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, return 0%
        return 0.0;
      }

      final userData = await FirebaseFirestore.instance
          .collection('user_collections')
          .doc(user.uid)
          .get();

      if (!userData.exists || userData.data() == null) {
        return 0.0;
      }

      final completedLessonsData =
          userData.data()?['lessons_completed'] as List<dynamic>? ?? [];
      // Calculate progress: (completed lessons / 105) * 100
      return (completedLessonsData.length / 105) * 100;
    } catch (e) {
      print('Error fetching user progress: $e');
      return 0.0;
    }
  }

  Future<List<Widget>> readChapters() async {
    int count = 0;
    List<Widget> chapters = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection("chapters").get();

      Map<String, dynamic> chapterData;
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        chapterData = doc.data();
        print(doc.data());

        chapters.add(ChapterCard(
          chapterNumber: count.toString(),
          title: doc.id,
          description: chapterData['description'],
          onTap: () => _navigateToChapter(doc.id, false),
        ));
        count++;
      }
    } catch (e) {
      print(e);
    }

    return chapters;
  }

  void _navigateToChapter(String chapterNumber, bool isLocked) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This chapter is locked. Complete previous chapters first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Widget chapterScreen = ChapterScreen(chapterNumber: chapterNumber);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => chapterScreen,
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Center(
            child: Row(children: [
      const Sidebar(),
      Container(
          width: width - 200,
          color: Colors.black,
          child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar
                    const TopBar(),

                    //progress bar for the whole learning
                    FutureBuilder<double>(
                        future: getUserProgress(),
                        builder: (context, snapshot) {
                          double progressPercentage = 0.0;
                          String completedLessons = "0";

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show loading state
                            progressPercentage = 0.0;
                          } else if (snapshot.hasError) {
                            // Handle error state
                            print("Error loading progress: ${snapshot.error}");
                            progressPercentage = 0.0;
                          } else if (snapshot.hasData) {
                            // Show actual progress
                            progressPercentage = snapshot.data!;
                            completedLessons = (progressPercentage * 105 / 100)
                                .round()
                                .toString();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Progress: ${progressPercentage.toStringAsFixed(1)}%'),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: width - 480,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progressPercentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.green),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        }),

                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chapters List
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                                child: FutureBuilder(
                                    future: readChapters(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No widgets found.'));
                                      } else {
                                        List<Widget> chapterWidgets =
                                            snapshot.data!;
                                        return Wrap(
                                          spacing: 10.0,
                                          runSpacing: 10.0,
                                          children: chapterWidgets,
                                        );
                                      }
                                    })),
                          ),

                          // Right Side Images
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
                                Image.asset('../assets/hand1.png', height: 100),
                                Image.asset('../assets/hand2.png', height: 100),
                                Image.asset('../assets/hand3.png', height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])))
    ])));
  }
}
