// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'src/screens/collage_sample.dart';
import 'src/tranistions/fade_route_transition.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const MyApp()),
    blocObserver: AppBlocObserver(),
  );
}

// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final GlobalKey screenshotKey1 = GlobalKey();
  final GlobalKey screenshotKey2 = GlobalKey();
  final GlobalKey screenshotKey3 = GlobalKey();
  final GlobalKey screenshotKey4 = GlobalKey();

  List collageTypes = [
    "V-Split",
    "three vertical",
    "three horizontal",
    "Four left big"
  ];
  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> capturePng() async {
    try {
      Directory dir;
      RenderRepaintBoundary? boundary = selectedIndex == 0
          ? screenshotKey1.currentContext!.findRenderObject()
              as RenderRepaintBoundary?
          : selectedIndex == 1
              ? screenshotKey2.currentContext!.findRenderObject()
                  as RenderRepaintBoundary?
              : selectedIndex == 2
                  ? screenshotKey3.currentContext!.findRenderObject()
                      as RenderRepaintBoundary?
                  : screenshotKey4.currentContext!.findRenderObject()
                      as RenderRepaintBoundary?;
      await Future.delayed(const Duration(milliseconds: 2000));
      if (Platform.isIOS) {
        ///For iOS
        dir = await getApplicationDocumentsDirectory();
      } else {
        ///For Android
        dir = (await getExternalStorageDirectory())!;
      }
      var image = await boundary?.toImage();
      var byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      File screenshotImageFile =
          File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
      await screenshotImageFile.writeAsBytes(byteData!.buffer.asUint8List());
      shareScreenShot(screenshotImageFile.path);
      return byteData.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        print("Capture Image Exception Main : $e");
      }
      throw Exception();
    }
  }

  shareScreenShot(String imgpath) async {
    debugPrint("the imgpath is : $imgpath");
  }

  @override
  Widget build(BuildContext context) {
    ///Create multple shapes.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
        actions: [
          IconButton(
              onPressed: () {
                capturePng();
              },
              icon: const Text("Save"))
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 12,
          ),
          RepaintBoundary(
            key: selectedIndex == 0
                ? screenshotKey1
                : selectedIndex == 1
                    ? screenshotKey2
                    : selectedIndex == 2
                        ? screenshotKey3
                        : screenshotKey4,
            child: ImageCollageWidget(
              collageType: selectedIndex == 0
                  ? CollageType.vSplit
                  : selectedIndex == 1
                      ? CollageType.threeHorizontal
                      : selectedIndex == 2
                          ? CollageType.threeVertical
                          : CollageType.fourLeftBig,
              withImage: true,
            ),
          ),
          Center(
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: collageTypes.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          debugPrint("inndexxx:$selectedIndex");
                        });
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(left: 8, top: 16),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.5)),
                        child: Center(
                          child: Text("${index + 1}"),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  ///On click of perticular type of button show that type of widget
  pushImageWidget(CollageType type) async {
    await Navigator.of(context).push(
      FadeRouteTransition(page: CollageSample(type)),
    );
  }

  RoundedRectangleBorder buttonShape() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0));
  }
}
