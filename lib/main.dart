import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

// import files
import 'settings.dart';
import 'object/model.dart';
import 'object/sphere.dart';
import 'math/vectors.dart';
import 'widget/slider_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Graphics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // Color sphereColor = Colors.cyan;  // 初期値を青色に設定  
  // // Vector3 defaultColor = Vector3(0.3137254901960784, 0.6196078431372549, 0.615686274509804); // blue ish
  // Sphere sphere = Sphere(Vector3(0.0, 0.0, 10.0), 3.0, Vector3(0.3137254901960784, 0.6196078431372549, 0.615686274509804));
  Vector3 defaultColor = Vector3(0.3137254901960784, 0.6196078431372549, 0.615686274509804); // blue-ish
  Vector3 defaultLightPos = Vector3(30.0, -80.0, 20.0);

  late Sphere sphere;
  Color sphereColor = Color.fromRGBO(
    (0.3137254901960784 * 255).toInt(),
    (0.6196078431372549 * 255).toInt(),
    (0.615686274509804 * 255).toInt(),
    1.0,
  );

  // red, blue, green
  List<Vector3> colors = [Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)];

  double radius = 3.0;  // 初期値
  bool isVisible = true;  // 初期値
  bool isPhong = true;

  int shape_id = 1;
  Color canvasColor = Color(0xFFF5F5F5);
  List<Sphere> sphereList = [];
  List<Sphere> objects = [];

  @override
  void initState() {
    super.initState();
    sphere = Sphere(Vector3(0.0, 0.0, 10.0), radius, defaultColor, defaultLightPos);
    // objects.add(Sphere(Vector3(0.0, 0.0, 10.0), 3.0, Vector3(1.0, 0.0, 0.0)));
    // Sphere sphere = Sphere(Vector3(0.0, 0.0, 10.0), 3.0, Vector3(0.0, 0.0, 0.0));
  }

  void startDrawing(DragStartDetails details) {
    print("startDrawing() is called!");
    setState(() {});
  }

  void stopDrawing(DragEndDetails details) {
    print("stopDrawing() is called!");
    setState(() {});
  }

  Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;  
  }

  @override
  Widget build(BuildContext context) {
    // screen size
    Size size = MediaQuery.of(context).size;  

    Uint8List toBytes(List<Sphere> objects) {
      final pixels = Uint8List(size.width.toInt() * size.height.toInt() * 4);

      // default 
      for (var i = 0; i < pixels.length; i += 4) {
        pixels[i] = canvasColor.red;
        pixels[i + 1] = canvasColor.green;
        pixels[i + 2] = canvasColor.blue;
        pixels[i + 3] = canvasColor.alpha;
      }

      if (sphere.isVisible){
        sphere.draw(pixels, size, canvasColor);
        print(sphere);
      }

      return pixels;
    }

    Future<ui.Image> toImage() {
      final pixels = toBytes(objects);
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(), ui.PixelFormat.rgba8888, completer.complete);
      return completer.future;
    }

    // Use a ValueNotifier to trigger a rebuild when the image changes
    ValueNotifier<Future<ui.Image>> imageFuture = ValueNotifier<Future<ui.Image>>(toImage());

    //---------------------------

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("3D Graphics"),
    //   ),
    //   body: Row(
    //     children: [
    //       Expanded(
    //         flex: 8,
    //         child: GestureDetector(
    //           onTapUp: (details) {
    //             print("Screen tapped");
    //             print(details.localPosition);
    //             // print("$_cameraX, $_cameraY, $_cameraZ \n");
    //           },
    //           onPanStart: (details) { startDrawing(details); },
    //           onPanEnd: (details) { stopDrawing(details); },
    //           child: Container(
    //             color: canvasColor,  // canvas color
    //             child: ValueListenableBuilder<Future<ui.Image>>(
    //               valueListenable: imageFuture,
    //               builder: (context, future, _) {
    //                 return FutureBuilder<ui.Image>(
    //                   key: UniqueKey(), 
    //                   future: future,
    //                   builder: (context, snapshot) {
    //                     if (snapshot.hasData) {
    //                       return Stack(children: [
    //                         RawImage(
    //                           alignment: Alignment.topLeft,
    //                           fit: BoxFit.none,
    //                           image: snapshot.data!,
    //                           width: size.width,
    //                           height: size.height,
    //                           filterQuality: FilterQuality.none,
    //                         ),
    //                       ]);
    //                     } else {
    //                       return const SizedBox();
    //                     }
    //                   },
    //                 );
    //               },
    //             ),  
    //           ), 
    //         ),
    //       ),
    //       Expanded(
    //         flex: 2,
    //         child: Container(
    //           padding: EdgeInsets.all(8.0),
    //           color: Colors.white,
    //           child: Column(

    //             children: [
    //               Text('Light', style: TextStyle(fontWeight: FontWeight.bold)),
    //               // X-axis slider
    //               // value: sphere.origin.x,
    //               //   min: -10,
    //               //   max: 10,
    //               //   onChanged: (value) {
    //               //     setState(() {
    //               //       sphere = Sphere(Vector3(value, sphere.origin.y, sphere.origin.z), sphere.radius, sphere.color, isPhong: sphere.isPhong);
    //               //     });
    //               //   },
    //               Row(
    //                 children: [
    //                   Text('X: '), 
    //                   Expanded(
    //                     child: SliderWidget(
    //                       // value: _camera.zoom,
    //                       label: 'X:', 
    //                       initialValue: 90,
    //                       minValue: 1,
    //                       maxValue: 180,
    //                       onChanged: (value) {
    //                         setState(() {
    //                         });
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               // Y-axis slider
    //               Row(
    //                 children: [
    //                   Text('Y: '), 
    //                   Expanded(
    //                     child: SliderWidget(
    //                       label: 'Camera Y', 
    //                       initialValue: 0,
    //                       // value: _camera.height,
    //                       minValue: -360,
    //                       maxValue: 360,
    //                       onChanged: (value) {
    //                         setState(() {
    //                         });
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               // Z-axis slider
    //               Row(
    //                 children: [
    //                   Text('Z: '), 
    //                   Expanded(
    //                     child: SliderWidget(
    //                       label: 'Camera Z', 
    //                       initialValue: 0,
    //                       // value: _camera.yaw,
    //                       minValue: -360,
    //                       maxValue: 360,
    //                       onChanged: (value) {
    //                         setState(() {
    //                         });
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               SizedBox(height: 16),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text("3D Graphics"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 8,
            child: GestureDetector(
              onTapUp: (details) {
                print("Screen tapped");
                print(details.localPosition);
              },
              onPanStart: (details) {
                startDrawing(details);
              },
              onPanEnd: (details) {
                stopDrawing(details);
              },
              child: Container(
                color: canvasColor, // canvas color
                child: ValueListenableBuilder<Future<ui.Image>>(
                  valueListenable: imageFuture,
                  builder: (context, future, _) {
                    return FutureBuilder<ui.Image>(
                      key: UniqueKey(),
                      future: future,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(children: [
                            RawImage(
                              alignment: Alignment.topLeft,
                              fit: BoxFit.none,
                              image: snapshot.data!,
                              width: size.width,
                              height: size.height,
                              filterQuality: FilterQuality.none,
                            ),
                          ]);
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.white,
              child: Column(
                children: [
                  Text('Light Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('X Position: '),
                      Expanded(
                        child: Slider(
                          value: sphere.lightPos.x,
                          min: -360,
                          max: 360,
                          onChanged: (value) {
                            setState(() {
                              sphere = Sphere(sphere.origin, sphere.radius, sphere.color, Vector3(value, sphere.lightPos.y, sphere.lightPos.z) , isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Y Position: '),
                      Expanded(
                        child: Slider(
                          value: sphere.lightPos.y,
                          min: -360,
                          max: 360,
                          onChanged: (value) {
                            setState(() {
                              sphere = Sphere(sphere.origin, sphere.radius, sphere.color, Vector3(sphere.lightPos.x, value, sphere.lightPos.z), isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Z Position: '),
                      Expanded(
                        child: Slider(
                          value: sphere.lightPos.z,
                          min: -360,
                          max: 360,
                          onChanged: (value) {
                            setState(() {
                              sphere = Sphere(sphere.origin, sphere.radius, sphere.color, Vector3(sphere.lightPos.x, sphere.lightPos.y, value) , isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Sphere Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Color',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        color: sphereColor,
                        margin: EdgeInsets.only(right: 10),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Pick a color!'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: sphereColor,
                                    onColorChanged: (Color color) {
                                      setState(() {
                                        sphereColor = color;
                                        sphere = Sphere(sphere.origin, sphere.radius, Vector3(color.red / 255, color.green / 255, color.blue / 255), sphere.lightPos, isPhong: sphere.isPhong);
                                      });
                                    },
                                    showLabel: true,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text('Got it'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Select Color'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Radius: '),
                      Expanded(
                        child: Slider(
                          value: radius,
                          min: 1,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              radius = value;
                              sphere = Sphere(Vector3(sphere.origin.x, sphere.origin.y, sphere.origin.z), radius, sphere.color, sphere.lightPos, isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('X Position: '),
                      Expanded(
                        child: Slider(
                          value: sphere.origin.x,
                          min: -10,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              sphere = Sphere(Vector3(value, sphere.origin.y, sphere.origin.z), sphere.radius, sphere.color, sphere.lightPos, isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Y Position: '),
                      Expanded(
                        child: Slider(
                          value: sphere.origin.y,
                          min: -10,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              sphere = Sphere(Vector3(sphere.origin.x, value, sphere.origin.z), sphere.radius, sphere.color, sphere.lightPos, isPhong: sphere.isPhong);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Visible: '),
                      Switch(
                        value: isVisible,
                        onChanged: (value) {
                          setState(() {
                            isVisible = value;
                            sphere = Sphere(sphere.origin, sphere.radius, sphere.color, sphere.lightPos, isPhong: sphere.isPhong);
                            sphere.isVisible = isVisible;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Row(
                  //   children: [
                  //     Text('Phong: '),
                  //     Switch(
                  //       value: isPhong,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           isPhong = value;
                  //           sphere = Sphere(sphere.origin, sphere.radius, sphere.color, isPhong: sphere.isPhong);
                  //           sphere.isPhong = isPhong;
                  //         });
                  //       },
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
