import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'emplacement.dart';

enum Direction { left, right, up, down }

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int food;
  Timer timer;
  int score = 0;
  bool gameOver = false;
  int moveDuration = 500;
  static final random = Random();
  static final rowItemCount = 20;
  Direction direction = Direction.right;
  Direction prevDirection = Direction.right;
  static final totalSqaure = rowItemCount * 30;
  List<int> snake = [random.nextInt(totalSqaure)];

  final style = TextStyle(
    fontSize: 24,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // ignore: missing_return
  int _moveHead() {
    switch (direction) {
      case Direction.right:
        if ((snake.last + 1) % rowItemCount == 0)
          return snake.last - rowItemCount + 1;
        return snake.last + 1;

      case Direction.left:
        if (snake.last % rowItemCount - 1 < 0)
          return snake.last + rowItemCount - 1;
        return snake.last - 1;

      case Direction.up:
        if (snake.last - rowItemCount < 0)
          return snake.last % rowItemCount + totalSqaure;
        return snake.last - rowItemCount;

      case Direction.down:
        if (snake.last + rowItemCount > totalSqaure - 1)
          return snake.last % rowItemCount;
        return snake.last + rowItemCount;
    }
  }

  void _toggleGameStatus() {
    if (timer != null && timer.isActive) return setState(() => timer.cancel());

    timer = Timer.periodic(Duration(milliseconds: moveDuration), (_) {
      setState(() {
        final newHead = _moveHead();
        if (newHead == food) {
          score++;
          snake.add(newHead);
          return _showNewFood();
        }
        if (snake.sublist(0, snake.length - 1).contains(newHead)) {
          gameOver = true;
          return timer.cancel();
        }

        if (snake.length > 2) {
          for (int i = 0; i < snake.length - 2; i++) {
            snake[i] = snake[i + 1];
          }
        }
        if (snake.length > 1) snake[snake.length - 2] = snake.last;
        snake[snake.length - 1] = newHead;
      });
    });
  }

  void _restart() {
    _showNewFood();
    setState(() {
      score = 0;
      timer = null;
      snake.clear();
      gameOver = false;
      moveDuration = 500;
      direction = Direction.right;
      prevDirection = Direction.right;
      snake.add(random.nextInt(totalSqaure));
    });
    _toggleGameStatus();
  }

  void _showNewFood() {
    food = null;

    final freeSquare = [];
    for (int i = 0; i < totalSqaure; i++) {
      if (!snake.contains(i)) freeSquare.add(i);
    }
    final foodIndex = random.nextInt(freeSquare.length);
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        food = freeSquare[foodIndex];
      });
    });
  }

  void _horizontalDirectionHandler(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      setState(() {
        prevDirection = direction;
        direction = Direction.right;
      });
    }
    if (details.delta.dx < 0) {
      setState(() {
        prevDirection = direction;
        direction = Direction.left;
      });
    }
    if ((direction == Direction.left && prevDirection == Direction.right) ||
        (direction == Direction.right && prevDirection == Direction.left)) {
      snake = snake.reversed.toList();
    }
  }

  void verticalDirectionHandler(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      setState(() {
        prevDirection = direction;
        direction = Direction.up;
      });
    }
    if (details.delta.dy > 0) {
      setState(() {
        prevDirection = direction;
        direction = Direction.down;
      });
    }
    if ((direction == Direction.up && prevDirection == Direction.down) ||
        (direction == Direction.down && prevDirection == Direction.up)) {
      snake = snake.reversed.toList();
    }
  }

  @override
  void initState() {
    _showNewFood();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = timer != null && timer.isActive;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  // padding: EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                    onHorizontalDragUpdate:
                        isPlaying ? _horizontalDirectionHandler : null,
                    onVerticalDragUpdate:
                        isPlaying ? verticalDirectionHandler : null,
                    child: GridView.builder(
                      itemCount: totalSqaure,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowItemCount,
                      ),
                      itemBuilder: (context, index) {
                        if (snake.contains(index))
                          return Emplacement(color: Colors.white);
                        if (index == food)
                          return Emplacement(color: Colors.red);
                        return Emplacement(color: Colors.grey[800]);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    // color: Colors.blueGrey,
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Score : $score', style: style),
                    SizedBox(
                      width: 170,
                      child: FlatButton(
                        color: isPlaying ? Colors.red : Colors.green,
                        onPressed: _toggleGameStatus,
                        child: Text(
                          timer == null
                              ? 'P L A Y'
                              : isPlaying ? 'S T O P' : 'R E S U M E',
                          style: style,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
          gameOver ? _buildGameOverPopUp() : SizedBox()
        ],
      ),
    );
  }

  _buildGameOverPopUp() {
    return Container(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment(0, -0.4),
        child: SizedBox(
          height: 260,
          width: 300,
          child: Card(
            elevation: 38,
            // shape:(),
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Game Over !', style: style.apply(color: Colors.red)),
                  SizedBox(height: 18),
                  Text(
                    'Score : $score',
                    style: style.apply(color: Colors.black),
                  ),
                  SizedBox(height: 28),
                  FlatButton(
                    onPressed: _restart,
                    child: Text(
                      'R E S T A R T',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
