// lib/components/chapter_card.dart
import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final String chapterNumber;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final Function onTap;

  const ChapterCard({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isActive = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isCompleted
                ? const Color.fromARGB(255, 133, 193, 135)
                : Colors.grey.shade300
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color.fromARGB(51, 0, 0, 0)
                  : Colors.white,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chapter $chapterNumber',
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 0, 0, 0))),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCompleted)
                  const Row(
                    children: [
                      Text('Completed', style: TextStyle(color: Colors.green)),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  )
                else if (isActive)
                  const Text('Start Now →',
                      style: TextStyle(fontWeight: FontWeight.bold))
                else if (isLocked)
                  const Text('Start Now →', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}