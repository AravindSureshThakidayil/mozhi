import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mozhi/components/sidebar.dart';
import 'package:mozhi/components/topbar.dart';
import 'package:mozhi/main.dart'; // Add this at the top of your file

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, this.chapter, this.lesson="A1"});

  final String? chapter;
  final String lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  bool isLearnActive = true;
  late VideoPlayerController _videoController;
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isVideoInitialized = false;
  String? _videoError;

  // Alphabet test related state
  late String _currentLetter; // Initial letter
  String _evaluationResult = ''; // Evaluation result
  int _timerSeconds = 5;
  int _timerstore = 5;
  Timer? _countdownTimer;
  bool _isTakingPicture = false;
  int _level = 1;
  late int score;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    //_initializeCamera();
    String alphabet = widget.lesson ?? 'A1';
    _currentLetter =
        alphabet.toUpperCase()[0]; // Default to 'A' if symbol is null
    int _level = int.parse(alphabet[1]);
    print("Level: $_level");
    if (_level == 1) {
      _timerstore = 5;
      _timerSeconds = _timerstore;
      
    } else if (_level == 2) {
      _timerstore = 3;
      _timerSeconds = _timerstore;
    } else if (_level == 3) {
      _timerstore = 2;
      _timerSeconds = _timerstore;
    }
    score=_level;
    // Default to 'A' if symbol is null
    if (widget.chapter != null) {
      print(
          'Symbol received: ${widget.lesson}, currentLetter set to: $_currentLetter');
      // Perform any actions based on the symbol
    } else {
      print('No symbol received, currentLetter defaulted to: $_currentLetter');
    }
  }

  void _navigateToNextLesson() {
  // Get the current lesson symbol
  String currentSymbol = widget.lesson ?? 'A1';
  
  // Extract the chapter (letter) and lesson number
  String currentLetter = currentSymbol[0];
  int currentLessonNumber = int.parse(currentSymbol.substring(1));
  
  // The chapter is passed as a string, so use that directly
  String chapterNumber = widget.chapter ?? '1';

  // Check if this is the last lesson in the chapter
  _isLastLessonInChapter(chapterNumber, currentLetter, currentLessonNumber)
      .then((isLastLesson) {
    if (isLastLesson) {
      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Congratulations! You completed all lessons in this chapter!'),
          duration: Duration(seconds: 3),
        ),
      );

      // Short delay before navigating back to home
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MyHomePage(title: 'MOZHI Demo Home Page'),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
          (route) => false, // This clears the navigation stack
        );
      });
    } else {
      // Navigate to the next lesson in this chapter
      int nextLessonNumber = currentLessonNumber + 1;

      // Construct the next lesson's symbol - keeping the same letter but incrementing the number
      String nextSymbol = '$currentLetter$nextLessonNumber';

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LessonScreen(chapter: chapterNumber, lesson: nextSymbol),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
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
  });
}

// Add this method to check if the current lesson is the last one in the chapter
  Future<bool> _isLastLessonInChapter(
    String chapterNumber, String letterSymbol, int lessonNumber) async {
  try {
    // Get the chapter document from Firestore
    DocumentSnapshot chapterDoc = await FirebaseFirestore.instance
        .collection("chapters")
        .doc(chapterNumber)
        .get();

    if (!chapterDoc.exists) {
      print("Chapter document doesn't exist: $chapterNumber");
      return false;
    }

    // Get the lessons data from the chapter
    Map<String, dynamic> chapterData =
        chapterDoc.data() as Map<String, dynamic>;

    print("Chapter data retrieved: $chapterData");

    // Check if lessons field exists and get the count of lessons
    if (chapterData.containsKey('lessonCount')) {
      int totalLessons = chapterData['lessonCount'];
      return lessonNumber >= totalLessons;
    } else if (chapterData.containsKey('lessons')) {
      // Alternative way: if lessons are stored as a map or array
      var lessons = chapterData['lessons'];
      if (lessons is List) {
        return lessonNumber >= lessons.length;
      } else if (lessons is Map) {
        return lessonNumber >= lessons.length;
      }
    }

    // If we can't determine the lesson count, default behavior
    // You might want to adjust this based on your specific data structure
    return lessonNumber >= 3; // Assuming 3 lessons per chapter as fallback
  } catch (e) {
    print("Error checking if last lesson: $e");
    return false;
  }
}
  Future<void> _initializeVideo() async {
    // Use asset-based approach instead of file path
    try {
      _videoController =
          VideoPlayerController.asset('../../assets/lesson1.mp4');

      // Add listener to update UI when video status changes
      _videoController.addListener(() {
        if (mounted) setState(() {});
      });

      await _videoController.initialize();

      // Configure video to loop
      await _videoController.setLooping(true);

      // Set volume
      await _videoController.setVolume(1.0);

      if (isLearnActive) {
        await _videoController.play();
      }

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _videoError = e.toString();
        print('Error initializing video: $_videoError');
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (!isLearnActive) {
      // Only initialize if in test mode
      try {
        cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras[0],
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }
      } catch (e) {
        print('Error initializing camera: $e');
      }
    }
  }

  String _getNextLetter(String currentLetter) {
    // Simple logic to cycle through letters
    if (currentLetter == 'Z') {
      return 'A';
    } else {
      return String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
    }
  }

  void _toggleMode(bool learnMode) {
    setState(() {
      if (isLearnActive != learnMode) {
        isLearnActive = learnMode;

        if (isLearnActive) {
          // If switching to learn mode, play video and dispose camera
          if (_isVideoInitialized) {
            _videoController.play();
          }

          // Dispose camera controller if it exists
          if (_cameraController != null &&
              _cameraController!.value.isInitialized) {
            _cameraController!.dispose();
            _cameraController = null;
            _isCameraInitialized = false;
          }

          // Cancel any ongoing timers
          _countdownTimer?.cancel();
          _isTakingPicture = false;
        } else {
          // If switching to test mode, pause video and initialize camera
          if (_isVideoInitialized) {
            _videoController.pause();
          }

          // Initialize camera if not already initialized
          if (_cameraController == null ||
              !_cameraController!.value.isInitialized) {
            _initializeCamera();
          } else {
            _cameraController?.resumePreview();
          }

          // Reset the evaluation result
          _evaluationResult = '';
        }
      }
    });
  }

  void _changeLetter() {
    setState(() {
      _currentLetter = _getNextLetter(_currentLetter);
      _evaluationResult = ''; // Reset result when letter changes
    });
  }

  void _updateEvaluationResult(String result,
      {String chapterNumber = '1', String lessonNumber = '1'}) {
    // Get current user ID from Firebase Auth
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print("Chapter number:$chapterNumber, Lesson number:$lessonNumber");

    // Check if user is logged in
    if (userId.isEmpty) {
      print("Error: No user is logged in");
      setState(() {
        _evaluationResult = result;
        _isTakingPicture = false;
      });
      return;
    }

    print(_currentLetter);
    print(result);

    if (_currentLetter == result) {
      print("Correct letter detected");

      // Create a lesson completion data object with dynamic chapter and lesson numbers
      // Use DateTime.now() instead of FieldValue.serverTimestamp()
      Map<String, dynamic> lessonData = {
        "lessonid": "chapters/$chapterNumber/lessons/$lessonNumber",
        "completed": DateTime.now().toIso8601String()
      };

      // Update the user document by adding to the lessons_completed array
      FirebaseFirestore.instance
          .collection("user_collections")
          .doc(userId)
          .update({
        "lessons_completed": FieldValue.arrayUnion([lessonData]),
        "xp": FieldValue.increment(score),
      }).then((_) {
        print("Database updated successfully");
      }).catchError((error) {
        print("Error updating database: $error");
      });
    }

    setState(() {
      _evaluationResult = result;
      _isTakingPicture = false;
    });
  }

  void _startCountdown() {
    if (_isTakingPicture) return;

    setState(() {
      _timerSeconds = _timerstore;
      _isTakingPicture = true;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          timer.cancel();
          _takePicture();
        }
      });
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not initialized')));
      setState(() {
        _isTakingPicture = false;
      });
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      // A capture is already pending
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      _processImage(file);
    } on CameraException catch (e) {
      _showCameraException(e);
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> _processImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('http://localhost:8001/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imagedata': base64Image}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image sent successfully')));

        var decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        _updateEvaluationResult(decodedResponse['predicted'].toString(),
            chapterNumber: widget.chapter ?? '1',
            lessonNumber: widget.lesson ?? '1');
        print(decodedResponse);
        print("Current letter: $_currentLetter");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send image')));
        setState(() {
          _isTakingPicture = false;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void _showCameraException(CameraException e) {
    print('Error: ${e.code}\n${e.description}');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.code}\n${e.description}')));
  }

  Widget sidebarElement(String title, IconData icon, bool isActive,
      [VoidCallback? method]) {
    return GestureDetector(
      onTap: method,
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
  void dispose() {
    _videoController.dispose();
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_videoError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            const Text(
              "Video error",
              style: TextStyle(color: Colors.white),
            ),
            // Debug button to retry loading
            TextButton(
              onPressed: () {
                setState(() {
                  _videoError = null;
                  _isVideoInitialized = false;
                });
                _initializeVideo();
              },
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (!_isVideoInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: VideoPlayer(_videoController),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 8),
            Text(
              "Initializing camera...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CameraPreview(_cameraController!),
        if (_isTakingPicture)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                "$_timerSeconds",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Replace the _buildAlphabetTestInstructions method with this updated version
  Widget _buildAlphabetTestInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Show the sign for:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF5DFD2),
              borderRadius: BorderRadius.circular(80),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _currentLetter,
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        if (_evaluationResult.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: _evaluationResult == _currentLetter
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _evaluationResult == _currentLetter
                    ? Colors.green
                    : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              _evaluationResult == _currentLetter
                  ? "Correct! You signed $_evaluationResult"
                  : "That looks like $_evaluationResult. Try again!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _evaluationResult == _currentLetter
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
          ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            // Check if there's enough width for horizontal buttons
            if (constraints.maxWidth >= 350) {
              // Enough space - use horizontal layout
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button to take a picture
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5DFD2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isTakingPicture ? null : _startCountdown,
                    icon: const Icon(Icons.camera_alt, color: Colors.black87),
                    label: Text(
                      _isTakingPicture ? "Taking picture..." : "Take picture",
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Button to navigate to next lesson (only enabled when current letter is correct)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: (_evaluationResult == _currentLetter)
                        ? _navigateToNextLesson
                        : null,
                    icon:
                        const Icon(Icons.arrow_forward, color: Colors.black87),
                    label: const Text(
                      "Next Lesson",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ],
              );
            } else {
              // Not enough space - use vertical layout
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Button to take a picture
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5DFD2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isTakingPicture ? null : _startCountdown,
                      icon: const Icon(Icons.camera_alt, color: Colors.black87),
                      label: Text(
                        _isTakingPicture ? "Taking picture..." : "Take picture",
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Button to navigate to next lesson (only enabled when current letter is correct)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: (_evaluationResult == _currentLetter)
                          ? _navigateToNextLesson
                          : null,
                      icon: const Icon(Icons.arrow_forward,
                          color: Colors.black87),
                      label: const Text(
                        "Next Lesson",
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
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
                  // Top Bar with streak and profile
                  const TopBar(),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Color.fromARGB(255, 163, 163, 163),
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),

                  // Lesson content
                  Expanded(
                    child: Row(
                      children: [
                        // Main content area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Learn/Test button row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                     Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                             "Lesson ${widget.lesson[1] ?? '1'}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Basic Hand Signs",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => _toggleMode(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isLearnActive
                                              ? const Color(0xFFF5DFD2)
                                              : Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          "Learn",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () async {
                                        // Initialize camera when switching to test mode
                                        await _initializeCamera();
                                        _toggleMode(false);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !isLearnActive
                                              ? const Color(0xFFF5DFD2)
                                              : Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          "Take Test",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Video player in learn mode / Split view in test mode
                                Expanded(
                                  child: isLearnActive
                                      // LEARN MODE: Full video player
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            width: double.maxFinite,
                                            color: Colors.black,
                                            child: _buildVideoPlayer(),
                                          ),
                                        )
                                      // TEST MODE: Split view with instructions on left, camera on right
                                      : Row(
                                          children: [
                                            // Left side: Letter instructions
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child:
                                                    _buildAlphabetTestInstructions(),
                                              ),
                                            ),
                                            // Spacing
                                            const SizedBox(width: 15),
                                            // Right side: Camera view
                                            Expanded(
                                              flex: 6,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  color: Colors.black,
                                                  child: _buildCameraPreview(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),

                                // Video controls (only in learn mode)
                                if (isLearnActive && _isVideoInitialized)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _videoController.value.position
                                                        .inSeconds <=
                                                    0
                                                ? Icons.replay_5
                                                : Icons.replay_10,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            final newPosition = _videoController
                                                    .value.position -
                                                const Duration(seconds: 10);
                                            _videoController
                                                .seekTo(newPosition);
                                          },
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          iconSize: 50,
                                          icon: Icon(
                                            _videoController.value.isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _videoController.value.isPlaying
                                                  ? _videoController.pause()
                                                  : _videoController.play();
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.forward_10,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            final newPosition = _videoController
                                                    .value.position +
                                                const Duration(seconds: 10);
                                            _videoController
                                                .seekTo(newPosition);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Right sidebar with hand signs
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
}
