import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
  bool _isTakingPicture = false; // 写真撮影中かどうかを管理する変数
  List<String> _imagePaths = []; // 写真のパスを保存するリスト

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
    print('_onShutterPressed()が実行されました');
    if (_isTakingPicture) return; // 写真撮影中の場合は処理を中断
    _isTakingPicture = true; // 写真撮影を開始
    if (_count > 0) {
      try {
        await _initializeControllerFuture; // コントローラーが初期化されるまで待つ

        // 写真を撮影
        final XFile image = await _controller.takePicture();
        print('写真の撮影に成功しました');
        if (!kIsWeb) {
          print('kIsWeb: $kIsWeb');
          // 保存先のディレクトリを取得
          final directory = await getExternalStorageDirectory();
          print('getExternalStorageDirectory()が実行されました');
          if (directory != null) {
            // 保存先のファイルパスを生成
            final String filePath =
            path.join(directory.path, '${DateTime.now()}.png');
            // 写真を指定した場所に保存
            await image.saveTo(filePath);
            print('写真の保存に成功しました: $filePath');
            _imagePaths.add(filePath); // 写真のパスをリストに追加
            print('_imagePathsに追加しました: $filePath');
          } else {
            print('directoryがnullです');
          }
        }
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
      } finally {
        _isTakingPicture = false; // 写真撮影を終了
      }
    }
  }

  void _onFilmChangePressed() {
    setState(() {
      _count = 27;
    });
  }

  void _onTestButtonPressed() {
    print('_onTestButtonPressed()が実行されました');
    print('_imagePathsの内容: $_imagePaths');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageListScreen(imagePaths: _imagePaths),
      ),
    );
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
            onPressed: _count > 0 && !_isTakingPicture ? _onShutterPressed : null,
            child: const Text('シャッター'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _count == 27 ? null : _onFilmChangePressed,
            child: const Text('フィルム交換'),
          ),
          const SizedBox(height: 20), // ここから追加
          ElevatedButton(
            onPressed: _onTestButtonPressed,
            child: const Text('写真フォルダ'),
          ), // ここまで追加
        ],
      ),
    );
  }
}

// 写真一覧を表示する画面
class ImageListScreen extends StatelessWidget {
  final List<String> imagePaths;

  const ImageListScreen({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('撮影した写真一覧'),
      ),
      body: ListView.builder(
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(imagePaths[index])),
          );
        },
      ),
    );
  }
}