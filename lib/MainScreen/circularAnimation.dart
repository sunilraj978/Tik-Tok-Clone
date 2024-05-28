import 'package:flutter/material.dart';

class CircularAnimation extends StatefulWidget {

  final Widget child;

  const CircularAnimation( {Key key, this.child}) : super(key: key);

  @override
  _CircularAnimationState createState() => _CircularAnimationState();
}

class _CircularAnimationState extends State<CircularAnimation>  with SingleTickerProviderStateMixin {
  AnimationController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new AnimationController(vsync: this,duration: new Duration(milliseconds: 5000));
    controller.forward();
    controller.repeat();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: new Tween(begin: 0.0,end: 1.0).animate(controller),
      child: widget.child,
    );
  }
}
