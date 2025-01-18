import 'package:flutter/material.dart';

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
    double progressValue = 0.3;
    return Scaffold(
      body: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black,
            width: width * 0.2,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
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
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Squada One",
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    sidebarElement("Home", Icons.home, background1),
                    sidebarElement("Rankings", Icons.sports, background1),
                    sidebarElement("Profile", Icons.person_sharp, background1),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      sidebarElement("Settings", Icons.settings, Colors.black),
                      sidebarElement("Log out", Icons.logout, Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 0.8 * width,
            color: Colors.black,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    height: 2.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    width: double.infinity,
                    height: 2.0,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: 0.6 * width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Chapter 2",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "FINGER SPELL IT",
                                style: TextStyle(
                                  fontSize: 40,
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
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Progress: ${(progressValue * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 20,
                                color: Colors.green[500],
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 250,
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            width: 230,
                            margin: const EdgeInsets.only(top: 20, right: 10),
                            height: 570,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5DFD2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/i.png',
                                    height: 190,
                                  ),
                                ),
                                Positioned(
                                  top: 200,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/s.png',
                                    height: 190,
                                  ),
                                ),
                                Positioned(
                                  top: 380,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/l.png',
                                    height: 190,
                                  ),
                                ),
                              ],
                            ),
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
}
