import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_snake/model/actions/game_actions.dart';
import 'package:flutter_snake/model/game_state.dart';
import 'package:flutter_snake/model/utils/store_provider.dart';

class GameScene extends StatefulWidget {
  final bool internalControl;

  const GameScene({Key? key, this.internalControl = true}) : super(key: key);

  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> with StoreProvider {
  Timer? gameLooper;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    var d1 = store.gameState.indices.addHotListener(() {
      setState(() {});
    });
    disposables.addAll([d1]);
    if (widget.internalControl) {
      gameLooper = Timer.periodic(Duration(milliseconds: 400), (t) {
        store.sendAction(Loop());
      });
      store.sendAction(InitGame());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKey: (k) {
        SnakeDirection? direction;
        if (k.logicalKey == LogicalKeyboardKey.arrowLeft) {
          direction = SnakeDirection.left;
        } else if (k.logicalKey == LogicalKeyboardKey.arrowUp) {
          direction = SnakeDirection.up;
        } else if (k.logicalKey == LogicalKeyboardKey.arrowRight) {
          direction = SnakeDirection.right;
        } else if (k.logicalKey == LogicalKeyboardKey.arrowDown) {
          direction = SnakeDirection.down;
        } else if (k.logicalKey == LogicalKeyboardKey.space) {}
        if (direction != null && widget.internalControl) {
          store.sendAction(ControlDirection(direction));
        }
      },
      child: CustomPaint(
        child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
          );
        }),
        painter: _SnakePainter(store.gameState.indices, store.gameState.size,
            store.gameState.snake.first),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final Map<SnakeOffset, OccupiedType> content;
  final SnakeOffset head;
  final BoardSize boardSize;

  _SnakePainter(this.content, this.boardSize, this.head, {Listenable? repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    Paint bg = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);
    Size gridSize =
        Size(size.width / boardSize.width, size.height / boardSize.height);
    content.forEach((key, value) {
      Paint paint = Paint();
      Rect rect = Rect.fromLTWH(key.x * gridSize.width, key.y * gridSize.height,
          gridSize.width, gridSize.height);
      switch (value) {
        case OccupiedType.snake:
          if (key == head) {
            paint.color = Colors.lightBlue;
          } else {
            paint.color = Colors.grey;
          }
          break;
        case OccupiedType.food:
          paint.color = Colors.red;
          break;
      }
      paint.style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SnakePainter oldDelegate) {
    return true;
  }
}
