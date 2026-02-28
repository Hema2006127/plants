import 'package:flutter/material.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;

  const GreenButton({required this.text, required this.onPress});

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.0591;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF399B25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        onPressed: onPress,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
