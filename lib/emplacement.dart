import 'package:flutter/material.dart';

class Emplacement extends StatelessWidget {
  const Emplacement({Key key, this.child, this.color}) : super(key: key);
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
