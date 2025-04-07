import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/widgets.dart';

// Global variable to store the number of chapters
int? chapterCount;

Future<void> initializeChapterCount() async {
  // Set the chapter count only if it's currently null
  if (chapterCount == null) {
    try {
      // Get the list of chapter document IDs from the 'chapters' collection
      QuerySnapshot<Map<String, dynamic>> chaptersSnapshot =
          await FirebaseFirestore.instance.collection('chapters').get();

      // The number of documents in the snapshot is the number of chapters
      chapterCount = chaptersSnapshot.size;

      if (kDebugMode) {
        print('Chapter count initialized to: $chapterCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chapter count: $e');
      }
      // Optionally set a default value or handle the error as needed
      chapterCount = 0;
    }
  } else {
    if (kDebugMode) {
      print('Chapter count is already initialized: $chapterCount');
    }
  }
}

// Example of how you might use this in your Flutter app:

void main() async {
  // Ensure Flutter is initialized if calling from outside a widget
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the chapter count when the app starts
  await initializeChapterCount();

  // Now you can access the global chapterCount variable
  if (chapterCount != null) {
    print('Number of chapters available: $chapterCount');
    // Use chapterCount in your application logic
  } else {
    print('Chapter count could not be determined.');
  }
}

