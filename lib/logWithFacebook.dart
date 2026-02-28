import 'package:flutter/material.dart';

class LoginWithFaceBook extends StatelessWidget {
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Color(0xFFC7C7C7),
                width: size.width * 0.32,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.015,
              ),
              child:
              Column(children: [
              Text(
                "Or login with",
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF399B25),
                  fontWeight: FontWeight.w400,
                ),
              ),
                SizedBox(height: size.height * 0.0296),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/facebook_logo.png',
                        height: size.height * 0.0296,
                        width: size.width * 0.064,
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/google_logo.png',
                        height: size.height * 0.0296,
                        width: size.width * 0.064,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Color(0xFFC7C7C7),
                width: size.width * 0.32,

              ),
            ),
          ],
        ),
      ],
    );
  }
}