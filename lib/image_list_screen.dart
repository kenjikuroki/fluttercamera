import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'folder_content_screen.dart'; // folder_content_screen.dartをインポート

class ImageListScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ImageListScreen({Key? key, required this.imagePaths}) : super(key: key);

  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  String _appFolderName = "MyCameraApp";
  List<FileSystemEntity> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders(); // フォルダを読み込む
  }

  // フォルダを読み込む関数
  Future<void> _loadFolders() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final appFolder = Directory(path.join(directory.path, _appFolderName));
      if (await appFolder.exists()) {
        setState(() {
          _folders = [appFolder]; // フォルダをリストに追加
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写真フォルダ一覧'),
      ),
      body: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            title: Text(path.basename(folder.path)), // フォルダ名を表示
            leading: const Icon(Icons.folder), // フォルダアイコン
            onTap: () {
              // フォルダがクリックされた時の処理
              _navigateToFolder(folder);
            },
          );
        },
      ),
    );
  }

  // フォルダ内を表示する関数
  void _navigateToFolder(FileSystemEntity folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentScreen(folder: folder),
      ),
    );
  }
}