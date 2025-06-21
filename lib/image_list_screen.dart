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

  // フォルダ内を表示する関数
  void _navigateToFolder(FileSystemEntity folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentScreen(folder: folder),
      ),
    );
  }

  // 長押しで出すボトムメニュー
  Widget _buildBottomSheet(FileSystemEntity folder) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.black),
            title: const Text('ゴミ箱へ移動'),
            onTap: () {
              Navigator.pop(context); // ボトムシート閉じる
              _confirmDeleteFolder(folder);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('共有'),
            onTap: () {
              Navigator.pop(context);
              // 共有機能は必要なら実装してください
            },
          ),
        ],
      ),
    );
  }

  // 削除確認ダイアログ
  void _confirmDeleteFolder(FileSystemEntity folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('フォルダ「${path.basename(folder.path)}」をゴミ箱へ移動しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // ダイアログ閉じる
              await _deleteFolder(folder);
            },
            child: const Text('ゴミ箱に移動'),
          ),
        ],
      ),
    );
  }

  // フォルダ削除処理
  Future<void> _deleteFolder(FileSystemEntity folder) async {
    try {
      if (await folder.exists()) {
        await folder.delete(recursive: true);
      }
      await _loadFolders(); // 削除後にフォルダ一覧更新
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('フォルダ「${path.basename(folder.path)}」を削除しました。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フォルダ削除に失敗しました。')),
      );
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
          return GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildBottomSheet(folder),
              );
            },
            child: ListTile(
              title: Text(path.basename(folder.path)), // フォルダ名を表示
              leading: const Icon(Icons.folder), // フォルダアイコン
              onTap: () {
                // フォルダがクリックされた時の処理
                _navigateToFolder(folder);
              },
            ),
          );
        },
      ),
    );
  }
}
