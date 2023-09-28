import 'package:flutter/material.dart';
import 'package:indexed/indexed.dart';

class CubeWidget extends AnimatedWidget implements IndexedInterface {
  final AnimationController controller;
  final int itemIndex;
  final List<bool> itemStatus;
  final List<Color> itemColors;
  final double left;
  final double bottom;
  const CubeWidget(this.controller,
      {super.key,
      required this.itemIndex,
      required this.itemStatus,
      required this.itemColors,
      required this.left,
      required this.bottom})
      : super(listenable: controller);
  Animation<double> get _progress => listenable as Animation<double>;
  @override
  Widget build(BuildContext context) {
    if (itemStatus[itemIndex] && controller.status != AnimationStatus.completed) {
      controller.forward();
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: itemStatus[itemIndex] ? 200 : 200),
      curve: Curves.linear,
      left: itemStatus[itemIndex] ? left + 25 : left,
      bottom: itemStatus[itemIndex] ? bottom + 25 : bottom,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: itemStatus[itemIndex] ? itemColors[itemIndex] : const Color(0xff28282B),
          boxShadow: [
            BoxShadow(
                color: (itemStatus[itemIndex] ? itemColors[itemIndex] : const Color(0xff28282B)).withOpacity(0.1),
                blurRadius: 40,
                offset: Offset.zero,
                spreadRadius: 5),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: [
            if (itemStatus[itemIndex])
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  painter: LinePainter(animation: _progress.value, color: itemColors[itemIndex]),
                  size: const Size(50, 50),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 40, offset: Offset.zero, spreadRadius: 5),
                ],
              ),
              // child: Center(child: Text(itemIndex.toString(),style: const TextStyle(color: Colors.white),)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  int get index => itemStatus[itemIndex] ? itemStatus.length + itemStatus.length - itemIndex + 1 : itemIndex + 1;
}

class LinePainter extends CustomPainter {
  final double animation;
  final Color? color;
  LinePainter({required this.animation, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    //Fill
    Paint paint2 = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.fill;

    Path path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width - 25 * animation, size.height + 25 * animation);

    path2.lineTo(size.width - 75 * animation, size.height + 25 * animation);
    path2.lineTo(size.width - 75 * animation, size.height + -25 * animation);
    path2.lineTo(0 * animation, 0 * animation);
    path2.close();

    canvas.drawPath(path2, paint2);

    //Lines

    Paint paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width - 25 * animation, size.height + 25 * animation);

    path.moveTo(0, size.height);
    path.lineTo(-25 * animation, size.height + 25 * animation);
    path.moveTo(0, 0);
    path.lineTo(-25 * animation, 25 * animation);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
