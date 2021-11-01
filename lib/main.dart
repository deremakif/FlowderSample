import 'dart:io';

import 'package:flowder/flowder.dart';
import 'package:flowder_sample/file_models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flowder Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FileModel> fileList = [];

  late DownloaderUtils options;
  late DownloaderCore core;
  late final String path;

  @override
  void initState() {
    super.initState();

    initPlatformState();
    generateFileList();
  }

  generateFileList() {
    fileList
      ..add(FileModel(
        fileName: "loremipsum.pdf",
        url:
            "https://assets.website-files.com/603d0d2db8ec32ba7d44fffe/603d0e327eb2748c8ab1053f_loremipsum.pdf",
        progress: 0.0,
      ))
      ..add(FileModel(
        fileName: "5MB.zip",
        url: "http://ipv4.download.thinkbroadband.com/5MB.zip",
        progress: 0.0,
      ))
      ..add(FileModel(
        fileName: "halloween.jpg",
        url:
            "https://png.pngtree.com/png-clipart/20210718/original/pngtree-cute-halloween-spooky-pumpkin-bat-png-image_6533837.jpg",
        progress: 0.0,
      ));
  }

  Future<void> initPlatformState() async {
    _setPath();
    if (!mounted) return;
  }

  void _setPath() async {
    Directory _path = await getApplicationDocumentsDirectory();

    String _localPath = _path.path + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    path = _localPath;
  }

  generateWidgetList() {
    List<Widget> widgetList = [];

    fileList.asMap().forEach((index, element) {
      widgetList.add(Row(
        children: [
          Container(
            width: 200,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text(fileList[index].fileName!),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () async {
              options = DownloaderUtils(
                progressCallback: (current, total) {
                  final progress = (current / total) * 100;
                  print('Downloading: $progress');

                  setState(() {
                    fileList[index].progress = (current / total);
                  });
                },
                file: File('$path/${fileList[index].fileName}'),
                progress: ProgressImplementation(),
                onDone: () {
                  setState(() {
                    fileList[index].progress = 0.0;
                  });
                  OpenFile.open('$path/${fileList[index].fileName}')
                      .then((value) {
                    // delete the file.
                    File f = File('$path/${fileList[index].fileName}');
                    f.delete();
                  });
                },
                deleteOnCancel: true,
              );
              core = await Flowder.download(
                fileList[index].url!,
                options,
              );
            },
            child: Column(
              children: [
                if (fileList[index].progress == 0.0)
                  Icon(
                    Icons.download,
                  ),
                if (fileList[index].progress != 0.0)
                  LinearPercentIndicator(
                    width: 100.0,
                    lineHeight: 14.0,
                    percent: fileList[index].progress!,
                    backgroundColor: Colors.blue,
                    progressColor: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ));
    });

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ...generateWidgetList(),
          ],
        ),
      ),
    );
  }
}
