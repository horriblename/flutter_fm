import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'dart:io' as io;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppView(title: 'Flutter Demo Home Page'),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AppView> createState() => _AppState();
}

class _AppState extends State<AppView> {
  io.Directory currentDir = io.Directory.current;
  List<io.FileSystemEntity> files = [];

  _AppState() {
    _updateFiles;
  }

  void _chdir(io.Directory dir) {
    setState(() {
      currentDir = dir;
      _updateFiles();
    });
  }

  void _open(io.FileSystemEntity file) {
    switch (file.statSync().type) {
      case io.FileSystemEntityType.directory:
        _chdir(file as io.Directory);
        break;
      case io.FileSystemEntityType.file:
        break;
      default:
    }
  }

  void refresh() {
    setState(() {
      _updateFiles();
    });
  }

  void _updateFiles() {
    files = currentDir.listSync();
    files.sort(
        (f1, f2) => path.basename(f1.path).compareTo(path.basename(f2.path)));
  }

  List<Widget> _addressWidget(io.FileSystemEntity directory) {
    var paths = path.split(directory.path);

    for (var i = 1; i < paths.length; i++) {
      paths[i] = path.join(paths[i - 1], paths[i]);
    }

    return paths
        .map((fpath) => TextButton(
            onPressed: () => _chdir(io.Directory(fpath)),
            child: Text(path.basename(fpath))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: _addressWidget(currentDir),
        ),
      ),
      body: Center(
        child: ListView(
            children: files
                .map((file) => TextButton(
                    onPressed: () => _open(file),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            path.basename(file.path),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    )))
                .toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
