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
import './video.dart';


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
  late bool _isSignedIn;
  @override
  void initState() {
    super.initState();
    _isSignedIn = false; // Initialize with false initially
    isSignedIn();
  }

  Future<void> isSignedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
        _isSignedIn = true;
        return;
      }
      print("here");
      _isSignedIn = false;
    });
  }

  Widget sidebarElement(
      String title, IconData icon, Color background, [Function? method]) {
    return GestureDetector(
        onTap: () {
          if(method!=null)
          {
            method();
          }
        },
        child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ))
            ])));
  }

  void _sendToLogin () 
  {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginScreen()));
  }
  void _sendToLogout()
  {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SignoutScreen()));
  }
  @override
  Widget build(BuildContext context) {
    isSignedIn();
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
          width: width * 0.2,
          height: MediaQuery.of(context).size.height,
          child: Column(children: [
            Container(
                margin: const EdgeInsets.only(bottom: 100),
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
                              fontWeight: FontWeight.w900),
                        ))
                  ],
                )),
            Column(// links in sidebar
                children: [
              sidebarElement("Home", Icons.home, background1),
              sidebarElement("Rankings", Icons.sports, background1),
              sidebarElement("Profile", Icons.person_sharp, background1)
            ]),
            Align(
                alignment: Alignment.bottomLeft,
                child: Column(children: [
                  sidebarElement("Settings", Icons.settings, Colors.black),
                  _isSignedIn
                      ?sidebarElement("Logout", Icons.logout, Colors.black,_sendToLogout)
                      :sidebarElement("Login", Icons.login, Colors.black,_sendToLogin)

                ]))
          ])),
      Container(
          width: 0.8 * width,
          color: Colors.black,
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ))
    ])));
  }
}
