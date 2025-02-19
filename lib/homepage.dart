import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pong/ball.dart';
import 'package:pong/brick.dart';
import 'package:pong/coverscreen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

enum Direction { up, down, left, right }

class _HomepageState extends State<Homepage> {
  // game state
  bool gameHasStarted = false;
  int playerScore = 0;
  int enemyScore = 0;
  Timer? gameTimer;

  // ball variables
  double ballX = 0;
  double ballY = 0;
  var ballYDirection = Direction.down;
  var ballXDirection = Direction.left;
  final double ballSpeed = 0.02;

  // paddle variables
  double playerX = -0.2;
  double enemyX = -0.2;
  final double paddleWidth = 0.4;
  final double paddleSpeed = 0.03;

  void resetBall({bool serveToPlayer = true}) {
    ballX = 0;
    ballY = 0;
    ballYDirection = serveToPlayer ? Direction.up : Direction.down;
    ballXDirection = (DateTime.now().millisecond % 2 == 0)
        ? Direction.left
        : Direction.right;
  }

  void updateGame() {
    updateBallPosition();
    checkCollisions();
    moveEnemy();
    if (isOutOfBounds()) {
      gameTimer?.cancel();
      _showResult();
    }
  }

  void updateBallPosition() {
    setState(() {
      // vertical movement
      ballY += ballYDirection == Direction.down ? ballSpeed : -ballSpeed;

      // horizontal movement
      ballX += ballXDirection == Direction.right ? ballSpeed : -ballSpeed;
    });
  }

  void checkCollisions() {
    // paddle collision
    final bool isPlayerCollision = ballY >= 0.8 &&
        ballX >= playerX - paddleWidth / 2 &&
        ballX <= playerX + paddleWidth / 2;

    final bool isEnemyCollision = ballY <= -0.8 &&
        ballX >= enemyX - paddleWidth / 2 &&
        ballX <= enemyX + paddleWidth / 2;

    // wall collisions left and right
    final bool isLeftWall = ballX <= -1.0;
    final bool isRightWall = ballX >= 1.0;

    setState(() {
      if (isPlayerCollision) ballYDirection = Direction.up;
      if (isEnemyCollision) ballYDirection = Direction.down;
      if (isLeftWall || isRightWall) {
        ballXDirection = isLeftWall ? Direction.right : Direction.left;
      }
    });
  }

  bool isOutOfBounds() {
    // wall collisions top and bottom
    final bool isTopWall = ballY <= -1.0;
    final bool isBottomWall = ballY >= 1.0;
    if (isTopWall) {
      playerScore++;
      return true;
    }
    if (isBottomWall) {
      enemyScore++;
      return true;
    }
    return false;
  }

  void moveEnemy() {
    final double enemyCenter = enemyX + paddleWidth / 2;
    setState(() {
      if (enemyCenter < ballX - 0.1) {
        enemyX += paddleSpeed;
      } else if (enemyCenter > ballX + 0.1) {
        enemyX -= paddleSpeed;
      }
      enemyX = enemyX.clamp(-1 + paddleWidth / 2, 1 - paddleWidth / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _startGame(),
      onHorizontalDragUpdate: (details) {
        setState(() {
          playerX += details.delta.dx / MediaQuery.of(context).size.width * 2;
          playerX = playerX.clamp(-1 + paddleWidth / 2, 1 - paddleWidth / 2);
        });
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Stack(
            children: [
              // tap to play
              CoverScreen(
                gameHasStarted: gameHasStarted,
              ),

              // top brick
              MyBrick(
                x: enemyX,
                y: -0.8,
                brickWidth: paddleWidth,
                thisIsEnemy: true,
              ),

              // bottom brick
              MyBrick(
                x: playerX,
                y: 0.8,
                brickWidth: paddleWidth,
                thisIsEnemy: false,
              ),

              // ball
              MyBall(x: ballX, y: ballY),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    if (!gameHasStarted) {
      gameHasStarted = true;
      resetBall(serveToPlayer: enemyScore > playerScore);
      gameTimer =
          Timer.periodic(const Duration(milliseconds: 16), (_) => updateGame());
    }
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      gameHasStarted = false;
      playerScore = 0;
      enemyScore = 0;
      resetBall();
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor:
            playerScore > enemyScore ? Colors.deepPurple : Colors.red,
        title: Center(
          child: Text(
            playerScore > enemyScore ? 'VICTORY!' : 'DEFEAT!',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: resetGame,
            child:
                const Text('PLAY AGAIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
