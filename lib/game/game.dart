import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_tetris/game/cube_widget.dart';
import 'package:flutter_3d_tetris/game/enum.dart';
import 'package:indexed/indexed.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late double width = MediaQuery.of(context).size.width;
  late double height = MediaQuery.of(context).size.height;
  List<bool> itemStatus = [];
  List<Color> itemColors = [];
  List<AnimationController> controllers = [];
  int left = 1;
  int rotation = 0;
  int space = 0;
  TetrominoType tetromino = TetrominoType.values[Random().nextInt(TetrominoType.values.length)];
  late final verticalCubeCount = (((height - height % 50) / 50).ceil());
  late final horizontalCubeCount = (((width - width % 50) / 50).ceil());
  late final cubeCount = (((width - width % 50) / 50).truncate()) * (((height - height % 50) / 50).truncate());

  List<List<bool>> get shape => tetromino.getShape(rotation);

  void _onTap(details) {
    final isLeft = details.globalPosition.dx < width / 2;
    if (details.globalPosition.dy < height / 2) {
      rotateShape();
    } else {
      moveShape(isLeft ? Direction.left : Direction.right);
    }
  }

  bool _canChangeDirection(bool isLeft) {
    bool canChangeDirection = true;

    for (int i = 0; i < shape.length; i++) {
      final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * (space + i));

      if (itemStatus[base +
          (isLeft
              ? shape[i].indexWhere((element) => element) - 1
              : shape[i].lastIndexWhere((element) => element) + 1)]) {
        canChangeDirection = false;
      }
    }

    if (!(isLeft
            ? (left < ((horizontalCubeCount - 1) / 2).ceil())
            : (left - shape[0].length + 1) > -((horizontalCubeCount - 1) / 2).truncate()) &&
        canChangeDirection) {
      canChangeDirection = false;
    }

    return canChangeDirection;
  }

  bool _canRotate() {
    bool canRotate = true;
    List<int> indexes = [];
    final newShape = tetromino.getShape(rotation + 1);

    for (int i = 0; i < shape.length; i++) {
      for (int y = 0; y < shape[i].length; y++) {
        final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * space);
        if (itemStatus[base - (horizontalCubeCount * i) + y]) {
          indexes.add(base - (horizontalCubeCount * i) + y);
        }
      }
    }

    for (int i = 0; i < newShape.length; i++) {
      for (int y = 0; y < newShape[i].length; y++) {
        final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * space);
        if (itemStatus[base - (horizontalCubeCount * i) + y] &&
            !indexes.contains(base - (horizontalCubeCount * i) + y)) {
          canRotate = false;
        }
      }
    }

    if (left - shape.length + 1 < -((horizontalCubeCount - 1) / 2).truncate()) {
      canRotate = false;
    }

    return canRotate;
  }

  bool _canFall() {
    bool canFall = true;
    final i = shape.length - 1;
    for (int y = 0; y < shape[i].length; y++) {
      final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * (space + 1));
      if (base - (horizontalCubeCount * i) + y > 0) {
        if ((itemStatus[base - (horizontalCubeCount * i) + y] && (shape[i][y])) ||
            (!shape[i][y] && itemStatus[base + y] && itemStatus[base - (horizontalCubeCount * (i - 1)) + y])) {
          canFall = false;
        }
      }
    }

    if (!(space < verticalCubeCount - shape.length) && canFall) {
      canFall = false;
    }

    return canFall;
  }

  void _resetShapeAndCheckForFilledRows() {
    space = 0;
    left = 1;
    rotation = 0;
    tetromino = TetrominoType.values[Random().nextInt(TetrominoType.values.length)];

    final List<List<bool>> itemRows = [];
    final List<List<Color>> colorRows = [];

    for (int i = 0; i < itemStatus.length; i += horizontalCubeCount) {
      List<bool> sublist = itemStatus.sublist(i, i + horizontalCubeCount);
      itemRows.add(sublist);
    }
    for (int i = 0; i < itemColors.length; i += horizontalCubeCount) {
      List<Color> sublist = itemColors.sublist(i, i + horizontalCubeCount);
      colorRows.add(sublist);
    }

    for (int i = 0; i < itemRows.length; i++) {
      if (itemRows[i].every((element) => element)) {
        itemRows.removeAt(i);
        colorRows.removeAt(i);
        itemRows.add(List.generate(horizontalCubeCount, (index) => false));
        colorRows.add(List.generate(horizontalCubeCount, (index) => Colors.black));
        itemStatus = itemRows.expand((element) => element).toList();
        itemColors = colorRows.expand((element) => element).toList();
        i--;
      }
    }
  }

  void rotateShape() {
    if (_canRotate()) {
      for (int i = 0; i < shape.length; i++) {
        for (int y = 0; y < shape[i].length; y++) {
          final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * space);
          if (shape[i][y]) {
            itemStatus[base - (horizontalCubeCount * i) + y] = false;
            itemColors[base - (horizontalCubeCount * i) + y] = Colors.black;
          }
        }
      }
      rotation++;
      setState(() {});
      moveShape(Direction.up);
    }
  }

  void moveShape(Direction direction) {
    if ((direction == Direction.down) ||
        ((direction == Direction.left || direction == Direction.right) &&
            _canChangeDirection(Direction.left == direction)) ||
        direction == Direction.up) {
      for (int i = 0; i < shape.length; i++) {
        for (int y = 0; y < shape[i].length; y++) {
          final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * space);
          if (shape[i][y]) {
            itemStatus[base - (horizontalCubeCount * i) + y] = false;
            itemColors[base - (horizontalCubeCount * i) + y] = Colors.black;
          }
        }
      }

      switch (direction) {
        case Direction.down:
          space++;
        case Direction.right:
          left--;
        case Direction.left:
          left++;
        case Direction.up:
      }

      for (int i = 0; i < shape.length; i++) {
        for (int y = 0; y < shape[i].length; y++) {
          final base = (cubeCount - horizontalCubeCount / 2.toInt()).toInt() - left - (horizontalCubeCount * space);
          if (shape[i][y]) {
            itemStatus[base - (horizontalCubeCount * i) + y] = shape[i][y];
            itemColors[base - (horizontalCubeCount * i) + y] = tetromino.color;
          }
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_canFall()) {
        moveShape(Direction.down);
      } else {
        _resetShapeAndCheckForFilledRows();
      }
    });

    RawKeyboard.instance.addListener((RawKeyEvent value) {
      if (value is RawKeyDownEvent) {
        switch (value.logicalKey) {
          case LogicalKeyboardKey.arrowRight:
            moveShape(Direction.right);
          case LogicalKeyboardKey.arrowLeft:
            moveShape(Direction.left);
          case LogicalKeyboardKey.arrowUp:
            rotateShape();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28282B),
      body: OrientationBuilder(
        builder: (_, orientation) {
          width = MediaQuery.of(context).size.width;
          height = MediaQuery.of(context).size.height;
          late final count = (((width - width % 50) / 50).truncate()) * (((height - height % 50) / 50).truncate());
          if (itemStatus.length > count) {
            for (int i = 0; i < itemStatus.length - count; i++) {
              itemStatus.removeAt(itemStatus.length - 1);
              itemColors.removeAt(itemStatus.length - 1);
              controllers.removeAt(controllers.length - 1);
            }
          }
          if (itemStatus.length < count) {
            itemStatus.addAll([for (int i = 0; i < count - itemStatus.length; i++) false]);
            itemColors.addAll([for (int i = 0; i < count - 0; i++) Colors.black]);
            controllers.addAll([
              for (int i = 0; i < count - controllers.length; i++)
                AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 200),
                )
            ]);
          }

          return GestureDetector(
            onTapDown: _onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width % 50 / 2,
                vertical: height % 50 / 2,
              ),
              child: Indexer(
                fit: StackFit.passthrough,
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  for (int index = 0; index < count; index++)
                    CubeWidget(
                      controllers[index],
                      itemIndex: index,
                      key: Key(index.toString()),
                      itemStatus: itemStatus,
                      itemColors: itemColors,
                      left: (index % horizontalCubeCount) * 50,
                      bottom: ((index / horizontalCubeCount).truncate() % verticalCubeCount) * 50,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
