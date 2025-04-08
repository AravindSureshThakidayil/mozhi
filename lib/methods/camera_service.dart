import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();
  
  CameraController? _cameraController;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  CameraController? get controller => _cameraController;
  
  Future<void> initializeCamera() async {
    if (_cameraController != null) {
      await disposeCamera(); // Dispose if already exists
    }
    
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _isInitialized = true;
        print('Camera initialized successfully');
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> disposeCamera() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isInitialized) {
        try {
          await _cameraController!.dispose();
          print('Camera disposed successfully');
        } catch (e) {
          print('Error disposing camera: $e');
        }
      }
      _cameraController = null;
      _isInitialized = false;
    }
  }
}