import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'model.dart';
import '../math/vectors.dart';
import '../settings.dart';

int height = canvas_height.toInt();
int width = canvas_width.toInt();

class Sphere {

  // properties
  final Vector3 origin;
  final double radius;
  final Vector3 color;
  final Vector3 lightPos;

  int id = 0;
  
  bool isVisible = true;
  bool isPhong = true; 

  Sphere(this.origin, this.radius, this.color, this.lightPos, {this.isPhong = true});

  // check if it hits the sphere or not
  RayHit? intersect(Ray ray) {

    // vector ray.origin to sphere origin
    final oc = ray.origin - origin;

    // math forms for the location between ray and sphere
    final a = ray.dir.dot(ray.dir);
    final b = 2.0 * oc.dot(ray.dir);
    final c = oc.dot(oc) - radius * radius;

    final discriminant = b * b - 4 * a * c;  // 判別式
    if (discriminant < 0) return null; // ray won't hit the sphere

    // distance ray hits the sphere
    final t = (-b - math.sqrt(discriminant)) / (2.0 * a); 
    if (t < 0) return null;

    final position = ray.origin + ray.dir * t;         // 光線が球と交差する点の座標
    final normal = (position - origin).normalized();
    return RayHit(position, normal);
  }

  // draw pixcels
  void draw(Uint8List pixels, ui.Size size, ui.Color canvasColor) {

    // iterate each pixcel
    for (int y = 0; y < size.height.toInt(); y++) {
      for (int x = 0; x < size.width.toInt(); x++) {
        final uv = ui.Offset(x / size.width, y / size.height); 
        final color = render(uv, 0.0, canvasColor);
        final int index = (y * size.width.toInt() + x) * 4; 
        pixels[index] = (color.x * 255).toInt();
        pixels[index + 1] = (color.y * 255).toInt();
        pixels[index + 2] = (color.z * 255).toInt();
        pixels[index + 3] = 255;  // アルファチャンネル
      }
    }
  }

  // 
  Vector3 render(ui.Offset uv, double time, ui.Color canvasColor) {

    // uvは画面上の点の座標
    final look = Vector3(0.0, 0.0, 1.0);  // camera
    final aspectRatio = width / height;

    // 3D空間での座標
    final coord = Vector3(
      (uv.dx * 2.0 - 1.0) * aspectRatio,
      uv.dy * 2.0 - 1.0,
      0.0,
    ) * 1.0;

    final origin = Vector3(0.0, 0.0, 0.0);  // start point of ray
    final dir = look + coord;               // カメラからスクリーン上のピクセルに向かう方向ベクトル。

    final ray = Ray(origin, dir.normalized());

    // final light = Vector3(0.0, 10.0, 5.0);
    // final light = Vector3(30.0, -80.0, 20.0);
    final hit = intersect(ray);

    if (hit != null) {
      final lightVec = (lightPos - hit.position).normalized();  // 光源から交点までの方向ベクトル
      if (isPhong) {
        // Phongシェーディング
        final viewVec = (origin - hit.position).normalized();  // カメラから交点までのベクトル
        final reflectVec = (hit.normal * (2 * hit.normal.dot(lightVec)) - lightVec).normalized(); // 反射ベクトル
        final ambient = 0.2;  // 環境光の強さ
        final diffuse = math.max(hit.normal.dot(lightVec), 0.0);  // 拡散光の強さ
        final specularStrength = 0.5;  // 鏡面反射の強さ
        final shininess = 32.0;
        final specular = math.pow(math.max(viewVec.dot(reflectVec), 0.0), shininess) * specularStrength;
        final lighting = ambient + diffuse + specular;
        return color * lighting;

      } else {
        // Lambertian shading for debug
        final cos = lightVec.dot(hit.normal);
        return color * cos;
      }
    } else {
      return Vector3(canvasColor.red / 255.0, canvasColor.green / 255.0, canvasColor.blue / 255.0);
    }
  }

  // DEBUG
  @override
  String toString() {
    return 'Sphere(id: $id, origin: $origin, radius: $radius, color: $color, isVisible: $isVisible)';
  }
}

class Ray {
  final Vector3 origin;
  final Vector3 dir;

  Ray(this.origin, this.dir);
}

// RayHitクラスを使って、レイが物体に当たった場合の詳細情報（どこで当たったか、その当たった点の表面の向きなど）
// を保持する。これにより、光の反射や影の計算が可能になる。
class RayHit {
  final Vector3 position;
  final Vector3 normal;

  RayHit(this.position, this.normal);
}


