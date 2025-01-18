import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:mozhi/authentication/screens/create_account.dart';
import 'package:mozhi/authentication/screens/login.dart';
import './authentication/screens/signout_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'components/video.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _isSignedIn = true;

  @override
  void initState() {
    isSignedIn();
    super.initState(); // Initialize with false initially
  }

  Future<void> isSignedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // print(user!.uid);
      if (user != null) {
        print(user.uid);
        print("lol");
        this._isSignedIn = true;
      } else {
        print("here");
        this._isSignedIn = false;
      }
    });
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
        ));
  }

  void _sendToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _sendToLogout() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // isSignedIn();
    double width = MediaQuery.of(context).size.width;
    const Color background1 = Color.fromRGBO(0x3B, 0x3B, 0x3B, 0.9);

    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Mozhi'),
        //   backgroundColor: Colors.black,
        // ),
        body: Center(
            child: Row(children: [
      Container(
          // left sidebar
          padding: const EdgeInsets.all(10),
          color: Colors.black,
          width: 200,
          height: MediaQuery.of(context).size.height,
          child: Column(children: [
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
                        ))
                  ],
                )),
            sidebarElement("Home", Icons.home, true),
            const SizedBox(height: 10),
            sidebarElement("Rankings", Icons.bar_chart, false),
            const SizedBox(height: 10),
            sidebarElement("Profile", Icons.person_outline, false),
            const Spacer(),
            // sidebarElement("Settings", Icons.settings, false),
            Align(
                alignment: Alignment.bottomLeft,
                child: Column(children: [
                  sidebarElement("Settings", Icons.settings, false),
                  _isSignedIn
                      ? sidebarElement(
                          "Logout", Icons.logout, false, _sendToLogout)
                      : sidebarElement(
                          "Login", Icons.login, false, _sendToLogin)
                ]))
          ])),
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
                    // Top Bar with steak and profile
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
                      // Add this
                      color: Color.fromARGB(255, 163, 163, 163),
                      thickness: 1,
                    ),
                    const SizedBox(height: 10),
                    //until this, everything should be in all the pages
                    //---------------------------------------------------------------------------------------------------------------------------
                    //progress bar for the whole learning
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progress: 18%'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: width - 480,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.18,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chapters List
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              // Add this wrapper
                              child: Column(
                                children: [
                                  _buildChapterCard(
                                    chapterNumber: "1",
                                    title: "COUNTING WITH HANDS",
                                    description:
                                        "Learn the universal language of numbers through gestures.",
                                    isCompleted: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildChapterCard(
                                    chapterNumber: "2",
                                    title: "FINGER SPELL IT",
                                    description:
                                        "Master the art of alphabets in sign language.",
                                    isActive: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildChapterCard(
                                    chapterNumber: "3",
                                    title: "EVERYDAY EXPRESSIONS",
                                    description:
                                        "Express yourself with common phrases and gestures.",
                                    isLocked: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildChapterCard(
                                    chapterNumber: "4",
                                    title: "EVERYDAY EXPRESSIONS",
                                    description:
                                        "Express yourself with common phrases and gestures.",
                                    isLocked: true,
                                  ),
                                  // Add more chapters as needed
                                ],
                              ),
                            ),
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
                                Image.asset('../assets/hand1.png', height: 150),
                                Image.asset('../assets/hand2.png', height: 150),
                                Image.asset('../assets/hand3.png', height: 150),
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

Widget _buildChapterCard({
  required String chapterNumber,
  required String title,
  required String description,
  bool isCompleted = false,
  bool isActive = false,
  bool isLocked = false,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border.all(
          color: isCompleted
              ? const Color.fromARGB(255, 133, 193, 135)
              : Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: isActive
              ? const Color.fromARGB(51, 0, 0, 0)
              : Colors.white, // 20% opacity (51 out of 255)
          blurRadius: 8,
          offset: const Offset(2, 4), // Position of the shadow (x, y)
        ),
      ],
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chapter $chapterNumber',
            style: const TextStyle(
                fontSize: 16, color: Color.fromARGB(255, 0, 0, 0))),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isCompleted)
              const Row(
                children: [
                  Text('Completed', style: TextStyle(color: Colors.green)),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              )
            else if (isActive)
              const Text('Start Now →',
                  style: TextStyle(fontWeight: FontWeight.bold))
            else if (isLocked)
              const Text('Start Now →', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}
