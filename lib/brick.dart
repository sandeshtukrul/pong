import 'package:flutter/material.dart';

class MyBrick extends StatelessWidget {
  final double x;
  final double y;
  final double brickWidth;
  final bool thisIsEnemy;

  const MyBrick(
      {super.key,
      required this.x,
      required this.y,
      required this.brickWidth,
      required this.thisIsEnemy});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: thisIsEnemy ? Colors.deepPurple[300] : Colors.white,
          height: 20,
          width: MediaQuery.of(context).size.width * brickWidth / 2,
        ),
      ),
    );
  }
}
