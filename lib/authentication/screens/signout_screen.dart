import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mozhi/main.dart';


class SignoutScreen extends StatefulWidget {
  const SignoutScreen({super.key});

  @override
  _SignoutScreenState createState() => _SignoutScreenState();
}

class _SignoutScreenState extends State<SignoutScreen> {
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyApp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Out"),
        ),
        body: Center(
            child: Column(
          children: [
            const Text('SignOut'),
            ElevatedButton(
                onPressed: () {
                  signOut();
                },
                child: const Text('Sign Out'))
          ],
        )));
  }
}
