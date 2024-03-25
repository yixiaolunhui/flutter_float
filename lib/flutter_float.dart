import 'package:flutter/material.dart';

///悬浮按钮Demo
class FloatingView extends StatefulWidget {
  FloatingView({
    Key? key,
    required this.child,
    this.offset = Offset.infinite,
    this.backEdge = true,
    this.animTime = 500,
  }) : super(key: key);

  Widget child;
  Offset offset;
  bool backEdge;
  int animTime;

  @override
  State<StatefulWidget> createState() {
    return FloatingViewState();
  }
}

class FloatingViewState extends State<FloatingView>
    with SingleTickerProviderStateMixin {
  Offset offset = Offset.infinite;
  GlobalKey floatingKey = GlobalKey();
  late AnimationController controller;
  Animation<double>? animation;
  double? width, height;
  double? screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      duration: Duration(milliseconds: widget.animTime),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      width = floatingKey.currentContext?.size?.width ?? 0;
      height = floatingKey.currentContext?.size?.height ?? 0;
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;
      offset = overflow(widget.offset);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: _floatingWindow(),
    );
  }

  Widget _floatingWindow() {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanDown: (details) {},
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          offset = offset + details.delta;
          offset = overflow(offset);
        });
      },
      onPanEnd: (details) {
        if (widget.backEdge) {
          double oldX = offset.dx;
          if (offset.dx <= (screenWidth ?? 0) / 2 - (width ?? 0) / 2) {
            offset = Offset(0, offset.dy);
          } else {
            offset = Offset((screenWidth ?? 0) - (width ?? 0), offset.dy);
          }
          double newX = offset.dx;
          animation = new Tween(begin: oldX, end: newX).animate(controller)
            ..addListener(() {
              setState(() {
                offset = Offset(animation?.value ?? 0, offset.dy);
              });
            });
          controller.reset();
          controller.forward();
        }
      },
      child: Material(
        color: Colors.transparent,
        key: floatingKey,
        child: widget.child,
      ),
    );
  }

  Offset overflow(Offset offset) {
    if (offset.dx <= 0) {
      offset = Offset(0, offset.dy);
    }
    if (offset.dx >= (screenWidth ?? 0) - (width ?? 0)) {
      offset = Offset((screenWidth ?? 0) - (width ?? 0), offset.dy);
    }
    if (offset.dy <= 0) {
      offset = Offset(offset.dx, 0);
    }
    if (offset.dy >= (screenHeight ?? 0) - (height ?? 0)) {
      offset = Offset(offset.dx, (screenHeight ?? 0) - (height ?? 0));
    }
    return offset;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
