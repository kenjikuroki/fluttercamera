import 'dart:io';
import 'package:flutter/material.dart';

// フォルダの中身を表示する画面
class FolderContentScreen extends StatefulWidget {
  final FileSystemEntity folder;

  const FolderContentScreen({Key? key, required this.folder}) : super(key: key);

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  List<FileSystemEntity> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages(); // 画像を読み込む
  }

  // 画像を読み込む関数
  Future<void> _loadImages() async {
    if (widget.folder is Directory) {
      final directory = widget.folder as Directory;
      final List<FileSystemEntity> imageFiles = directory.listSync();

      setState(() {
        _images = imageFiles.where((file) => file.path.endsWith('.png')).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フォルダ: ${widget.folder.path.split('/').last}'),
      ),
      body: ListView.builder(
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final imageFile = _images[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(imageFile.path)),
          );
        },
      ),
    );
  }
}