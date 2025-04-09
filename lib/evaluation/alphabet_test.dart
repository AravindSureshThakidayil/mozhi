import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mozhi/components/camera.dart'; // Assuming CameraApp is in this file

class Evaluator {
  String alphabet;
  XFile image;
  Evaluator({required this.alphabet, required this.image});
}

class AlphabetTestScreen extends StatefulWidget {
  const AlphabetTestScreen({super.key});

  @override
  _AlphabetTestScreenState createState() => _AlphabetTestScreenState();
}

class _AlphabetTestScreenState extends State<AlphabetTestScreen> {
  String _currentLetter = 'B'; // Initial letter
  String _evaluationResult = ''; // Move the evaluation result state to parent

  void changeLetter(String newLetter) {
    setState(() {
      _currentLetter = newLetter;
      _evaluationResult = ''; // Reset result when letter changes
    });
  }

  // Method to update the evaluation result
  void updateEvaluationResult(String result) {
    setState(() {
      _evaluationResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet Test'),
      ),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 7,
              child: Alphabet(
                letter: _currentLetter,
                evaluationResult: _evaluationResult,
              ),
            ),
            Flexible(
              flex: 3,
              child: CameraApp(
                letter: _currentLetter,
                onEvaluationResult: updateEvaluationResult, // Pass the callback
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Change the letter (for example, cycle through letters)
          changeLetter(_getNextLetter(_currentLetter));
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  String _getNextLetter(String currentLetter) {
    // Simple logic to cycle through letters (you can customize this)
    if (currentLetter == 'Z') {
      return 'A';
    } else {
      return String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
    }
  }
}

class Alphabet extends StatelessWidget {
  final String letter;
  final String evaluationResult;

  const Alphabet({
    super.key,
    required this.letter,
    required this.evaluationResult,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Letter: $letter",
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            "Result: $evaluationResult",
            style: const TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
