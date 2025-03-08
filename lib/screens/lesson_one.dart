import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool isLearnActive = true;
  late VideoPlayerController _videoController;
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isVideoInitialized = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeCamera();
  }

  Future<void> _initializeVideo() async {
    // Use asset-based approach instead of file path
    try {
      _videoController = VideoPlayerController.asset('../../assets/lesson1.mp4');
      
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
      
      // Try network source as fallback
      
    }
  }

  Future<void> _initializeCamera() async {
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

  void _toggleMode(bool learnMode) {
    setState(() {
      if (isLearnActive != learnMode) {
        isLearnActive = learnMode;
        
        if (isLearnActive) {
          // If switching to learn mode, play video and pause camera
          if (_isVideoInitialized) {
            _videoController.play();
          }
          _cameraController?.pausePreview();
        } else {
          // If switching to test mode, pause video and resume camera
          if (_isVideoInitialized) {
            _videoController.pause();
          }
          _cameraController?.resumePreview();
        }
      }
    });
  }

  Widget sidebarElement(String title, IconData icon, bool isActive, [VoidCallback? method]) {
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
    _cameraController?.dispose();
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
            Text(
              "Video error",
              style: const TextStyle(color: Colors.white),
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
    
    return CameraPreview(_cameraController!);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Row(
        children: [
          Container(
            // left sidebar
            padding: const EdgeInsets.all(10),
            color: Colors.black,
            width: 200,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
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
                        ),
                      ),
                    ],
                  ),
                ),
                sidebarElement("Home", Icons.home, true, _goBack),
                const SizedBox(height: 10),
                sidebarElement("Rankings", Icons.bar_chart, false),
                const SizedBox(height: 10),
                sidebarElement("Profile", Icons.person_outline, false),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      sidebarElement("Settings", Icons.settings, false),
                      sidebarElement("Logout", Icons.logout, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
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
                          horizontal: 16, 
                          vertical: 8,
                        ),
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Lesson 1",
                                        style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                        "Basic Hand Signs",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),
                                  const Spacer(), 
                                    
                                const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () => _toggleMode(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isLearnActive 
                                              ? const Color(0xFFF5DFD2) 
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(20),
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
                                      onTap: () => _toggleMode(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !isLearnActive 
                                              ? const Color(0xFFF5DFD2) 
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(20),
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
                                
                                // Video/Camera area
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: double.maxFinite,
                                      color: Colors.black,
                                      child: isLearnActive
                                          ? _buildVideoPlayer()
                                          : _buildCameraPreview(),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Camera button (only in test mode)
                                if (!isLearnActive)
                                  GestureDetector(
                                    onTap: () async {
                                      if (_cameraController != null && 
                                          _cameraController!.value.isInitialized) {
                                        try {
                                          final image = await _cameraController!.takePicture();
                                          print('Picture saved to: ${image.path}');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Picture saved to: ${image.path}'),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        } catch (e) {
                                          print('Error taking picture: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error taking picture: $e'),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF5DFD2),
                                      ),
                                      child: const Icon(Icons.videocam, size: 30),
                                    ),
                                  ),
                                
                                // Video controls (only in learn mode)
                                if (isLearnActive && _isVideoInitialized)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _videoController.value.position.inSeconds <= 0 
                                                ? Icons.replay_5
                                                : Icons.replay_10,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            final newPosition = _videoController.value.position - 
                                                const Duration(seconds: 10);
                                            _videoController.seekTo(newPosition);
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
                                          icon: Icon(
                                            Icons.forward_10,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            final newPosition = _videoController.value.position + 
                                                const Duration(seconds: 10);
                                            _videoController.seekTo(newPosition);
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