import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'model.dart';
import '../math/vectors.dart';
import '../settings.dart';

int height = canvas_height.toInt();
int width = canvas_width.toInt();

class Sphere {
  final Vector3 origin;
  final double radius;
  final Vector3 color;
  final Vector3 lightPos;

  int id = 0;
  
  bool isVisible = true;
  bool isPhong = true; 

  Sphere(this.origin, this.radius, this.color, this.lightPos, {this.isPhong = true});

  RayHit? intersect(Ray ray) {
    final oc = ray.origin - origin;
    final a = ray.dir.dot(ray.dir);
    final b = 2.0 * oc.dot(ray.dir);
    final c = oc.dot(oc) - radius * radius;
    final discriminant = b * b - 4 * a * c;
    if (discriminant < 0) return null;
    final t = (-b - math.sqrt(discriminant)) / (2.0 * a);
    if (t < 0) return null;
    final position = ray.origin + ray.dir * t;
    final normal = (position - origin).normalized();
    return RayHit(position, normal);
  }

  int color_threshold(int color){
    if (color > 255){
      return 255;
    } 
    else if (color < 0){
      return 0;
    }
    return color;
  }

  void draw(Uint8List pixels, ui.Size size, ui.Color canvasColor) {
    for (int y = 0; y < size.height.toInt(); y++) {
      for (int x = 0; x < size.width.toInt(); x++) {
        final uv = ui.Offset(x / size.width, y / size.height);
        final color = render(uv, 0.0, canvasColor);
        final int index = (y * size.width.toInt() + x) * 4; 

        
        int x_color = color_threshold((color.x * 255).toInt());
        int y_color = color_threshold((color.y * 255).toInt());
        int z_color = color_threshold((color.z * 255).toInt());

        pixels[index] = x_color;
        pixels[index + 1] = y_color;
        pixels[index + 2] = z_color;

        pixels[index + 3] = 255;  // アルファチャンネル
      }
    }
  }

  Vector3 render(ui.Offset uv, double time, ui.Color canvasColor) {
    final look = Vector3(0.0, 0.0, 1.0);
    final aspectRatio = width / height;
    final coord = Vector3(
      (uv.dx * 2.0 - 1.0) * aspectRatio,
      uv.dy * 2.0 - 1.0,
      0.0,
    ) * 1.0;
    final origin = Vector3(0.0, 0.0, 0.0);
    final dir = look + coord;

    final ray = Ray(origin, dir.normalized());

    // final light = Vector3(0.0, 10.0, 5.0);
    // final light = Vector3(30.0, -80.0, 20.0);
    final hit = intersect(ray);

    if (hit != null) {
      final lightVec = (lightPos - hit.position).normalized();
      if (isPhong) {
        // Phongシェーディング
        final viewVec = (origin - hit.position).normalized();
        final reflectVec = (hit.normal * (2 * hit.normal.dot(lightVec)) - lightVec).normalized();
        final ambient = 0.2;
        final diffuse = math.max(hit.normal.dot(lightVec), 0.0);
        final specularStrength = 0.5;
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

class RayHit {
  final Vector3 position;
  final Vector3 normal;

  RayHit(this.position, this.normal);
}


