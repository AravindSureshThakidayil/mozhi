// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mozhi/authentication/screens/login.dart';
import 'create_account.dart';
import '../../main.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<User?> createUserwithEmailAndPassword(
  String email,
  String password,
  BuildContext context, {
  String? username, // Optional username parameter
  DateTime? dob, // Example for Date of Birth (if you added that)
  // Add other optional user data here
}) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential.user;

    if (user != null) {
      // Add user data to the 'user_collections' document
      await FirebaseFirestore.instance
          .collection('user_collections')
          .doc(user.uid) // Use the Firebase Auth UID as the document ID
          .set({
        'uid': user.uid,
        'email': email,
        'username': username ?? '', // Use provided username or an empty string
        'created_at': Timestamp.now(),
        'xp': 0, // Initialize XP
        'lessons_completed': [], // Initialize completed lessons
        if (dob != null) 'dob': Timestamp.fromDate(dob), // Add DOB if provided
        // Add other initial user data as needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  } on FirebaseAuthException catch (e) {
    print("Firebase Auth Exception during creation: $e");
    String errorMessage = "An error occurred while creating your account.";
    if (e.code == 'weak-password') {
      errorMessage = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The account already exists for that email.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    print("Generic Exception during creation: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Failed to create account. Please try again.")),
    );
  }

  return user;
}

Future<void> signInWithEmailAndPassword(
    String emailAddress, String password, BuildContext context) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
    //on successful login move to home page
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyApp()));
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    } else {
      print('An unexpected error occurred: ${e.code}');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateAccount()));
    }
  }
}
