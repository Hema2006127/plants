import 'package:flutter/material.dart';
class UpGreenPlantPulse extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height * 0.191,
      decoration: const BoxDecoration(
        color: const Color(0x47A4D19B),
        borderRadius: const BorderRadius.only(
          bottomRight: const Radius.circular(256),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/leaf.png'),
          Image.asset('assets/plantpulse.png'),
        ],
      ),
    );
  }
}