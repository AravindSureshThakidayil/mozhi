import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './video.dart';

void main() {
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
  Widget sidebarElement(String title, IconData icon, Color background) {
    return Container(
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
        ]));
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    sidebarElement("Settings", Icons.settings, Colors.black),
                    sidebarElement("Log out", Icons.logout, Colors.black),
                  ],
                ))
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
