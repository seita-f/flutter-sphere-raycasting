import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' as ui;

// load file
import 'matrix.dart';


class Vector3 {
  final double x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 operator *(double scalar) => Vector3(x * scalar, y * scalar, z * scalar);

  Vector3 normalized() {
    final length = math.sqrt(x * x + y * y + z * z);
    return Vector3(x / length, y / length, z / length);
  }

  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;

  Vector3 lerp(Vector3 other, double t) {
    return this * (1.0 - t) + other * t;
  }

  @override
  String toString(){
    return "x: $x, y: $y, z: $z ";
  }
}

class Vector2 {
  final double x, y;

  Vector2(this.x, this.y);

  Vector3 extend(double z) => Vector3(x, y, z);

  static Vector2 fromPolar(double radius, double angle) {
    return Vector2(radius * math.cos(angle), radius * math.sin(angle));
  }
}

extension OffsetExt on ui.Offset {
  ui.Offset operator *(double scalar) => ui.Offset(dx * scalar, dy * scalar);
  ui.Offset operator -(ui.Offset other) => ui.Offset(dx - other.dx, dy - other.dy);
  Vector3 extend(double z) => Vector3(dx, dy, z);
}

extension Vector3Ext on Vector3 {
  Vector3 lerp(Vector3 other, double t) {
    return this * (1.0 - t) + other * t;
  }
}
