import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fluttercamera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // カウント数を27からスタート
  int _count = 27;

  // シャッターボタンが押された時にカウントを減らす
  void _onShutterPressed() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });
  }

  // フィルム交換ボタンが押された時にカウントを27に戻す
  void _onFilmChangePressed() {
    setState(() {
      _count = 27;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('fluttercamera'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // カウント数を表示
          Text(
            '残り枚数: $_count',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          // シャッターボタン
          ElevatedButton(
            onPressed: _count > 0 ? _onShutterPressed : null,  // 0枚ならボタンを無効化
            child: const Text('シャッター'),
          ),
          const SizedBox(height: 20),
          // フィルム交換ボタン
          ElevatedButton(
            onPressed: _count == 27 ? null : _onFilmChangePressed,  // 27枚ならボタンを無効化
            child: const Text('フィルム交換'),
          ),
        ],
      ),
    );
  }
}
