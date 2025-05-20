import 'package:flutter/material.dart';

class SlowScrollPhysics extends ClampingScrollPhysics {
  final double speedFactor;

  const SlowScrollPhysics({this.speedFactor = 0.5, ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(speedFactor: speedFactor, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * speedFactor);
  }
}
