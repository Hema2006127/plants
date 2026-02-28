import 'package:flutter/material.dart';

class DownText extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback fun;

  const DownText({required this.text1, required this.text2, required this.fun});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$text1 ",
          style: const TextStyle(
            color: const Color(0xFF6E6E6E),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: fun,
          child: Text(
            text2,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF399B25),
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF399B25),
            ),
          ),
        ),
      ],
    );
  }
}
