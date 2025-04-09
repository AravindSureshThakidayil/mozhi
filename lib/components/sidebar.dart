// lib/components/sidebar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mozhi/authentication/screens/login.dart';
import 'package:mozhi/authentication/screens/signout_screen.dart';
import 'package:mozhi/screens/rank_Screen.dart';
import 'package:mozhi/screens/profile_page.dart';
import 'package:mozhi/main.dart';
import 'package:mozhi/evaluation/alphabet_test.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isSignedIn = true;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  Future<void> isSignedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;
      setState(() {
        if (user != null) {
          _isSignedIn = true;
        } else {
          _isSignedIn = false;
        }
      });
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

  void _sendToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _sendToLogout(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    radius: 15,
                    backgroundImage: AssetImage('../assets/mozhilogo.jpg'),
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
          sidebarElement("Home", Icons.home, true, () {
            if (Navigator.of(context).canPop()) {
              // Navigate back to the first route (home page)
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
            // If we're already on the home page, do nothing
          }),
          const SizedBox(height: 10),
          sidebarElement("Rankings", Icons.bar_chart, false, () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => RankScreen(),
              ),
            )
                .then((_) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          }),
          const SizedBox(height: 10),
          sidebarElement("Profile", Icons.person_outline, false, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }),
          const SizedBox(height: 10),
          //_testCamera(context: context),

          const Spacer(),
          Align(
              alignment: Alignment.bottomLeft,
              child: Column(children: [
                _isSignedIn
                    ? sidebarElement("Logout", Icons.logout, false,
                        () => _sendToLogout(context))
                    : sidebarElement("Login", Icons.login, false,
                        () => _sendToLogin(context))
              ]))
        ]));
  }
}

Widget _testCamera({context}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AlphabetTestScreen()));
      },
      child: const Text('Evaluation'),
    ),
  );
}
