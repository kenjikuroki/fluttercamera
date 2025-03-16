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
  List<FileSystemEntity> _folders = [];
  List<String> _folderNames = []; // フォルダ名を保持するリストを追加

  @override
  void initState() {
    super.initState();
    _loadFolders(); // フォルダを読み込む
  }

  // フォルダを読み込む関数
  Future<void> _loadFolders() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      // 全てのサブディレクトリを取得
      final List<FileSystemEntity> entities = directory.listSync();
      final List<Directory> subDirectories = entities.whereType<Directory>().toList();

      // MyCameraAppで始まるフォルダだけを抽出
      final List<Directory> appFolders = subDirectories.where((dir) => path.basename(dir.path).startsWith('MyCameraApp_')).toList();

      setState(() {
        _folders = appFolders; // フォルダをリストに追加
      });
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