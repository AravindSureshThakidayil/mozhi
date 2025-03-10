// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mozhi/authentication/screens/login.dart';
import 'create_account.dart';
import '../../main.dart';

void createUserwithEmailAndPassword(
    String emailAddress, String password,BuildContext context) async {
  try {
    print(emailAddress);
    print(password);
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
    //if no exception is raised user creating is successful redirect to Login
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));

  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
    }
  } catch (e) {
    print(e);
  }
}

Future<void> signInWithEmailAndPassword(String emailAddress, String password,BuildContext context) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
        //on successful login move to home page
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
    else{

     print('An unexpected error occurred: ${e.code}');
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const CreateAccount()));
    }
     
  }
}
