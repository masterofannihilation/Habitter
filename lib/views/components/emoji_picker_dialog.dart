import 'package:flutter/material.dart';
import 'package:itu_habitter/constants.dart';

// Emoji picker dialog
class EmojiPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose an emoji:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 100, // Number of items
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Return the selected emoji
                    Navigator.of(context)
                        .pop(String.fromCharCode(0x1F600 + index));
                  },
                  child: Text(
                    String.fromCharCode(0x1F600 + index),
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
