import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fluttercamera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _count = 27;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onShutterPressed() async {
    if (_count > 0) {
      try {
        await _initializeControllerFuture; // コントローラーが初期化されるまで待つ

        // 写真を撮影
        final XFile image = await _controller.takePicture();

        // 撮影した写真を表示する画面に遷移
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imageFile: image),
          ),
        );

        // 残り枚数を減らす
        setState(() {
          _count--;
        });
      } on CameraException catch (e) {
        // カメラ関連のエラー処理
        print('カメラエラー: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('カメラエラーが発生しました: $e')),
        );
      } catch (e) {
        // その他のエラー処理
        print('その他のエラー: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('写真の撮影に失敗しました: $e')),
        );
      }
    }
  }

  void _onFilmChangePressed() {
    setState(() {
      _count = 27;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('fluttercamera'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: screenHeight / 5,
                  child: CameraPreview(_controller),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(height: 20),
          Text(
            '残り枚数: $_count',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _count > 0 ? _onShutterPressed : null,
            child: const Text('シャッター'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _count == 27 ? null : _onFilmChangePressed,
            child: const Text('フィルム交換'),
          ),
        ],
      ),
    );
  }
}

// 撮影した写真を表示する画面
class DisplayPictureScreen extends StatelessWidget {
  final XFile imageFile;

  const DisplayPictureScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('撮影した写真')),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: imageFile.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Image.memory(snapshot.data!);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
