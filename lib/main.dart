import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dart_tags/dart_tags.dart';

import 'package:path_provider/path_provider.dart';

import 'package:simple_permissions/simple_permissions.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'dart tag reader demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'dart tag reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<TagType, bool> _tagTypes = {TagType.id3v1: false, TagType.id3v2: false};

  List<Tag> _tags = [];

  final _textController = new TextEditingController(text: '');

  Future _loadTags() async {
    var file = new File(_textController.text); //DefaultAssetBundle.of(context).load('data/mp3.mp3');

    TagProcessor tp = new TagProcessor();

    List<TagType> tags = [];

    _tagTypes.forEach((k, v) {
      if (v) {
        tags.add(k);
      }
    });

    var l = await tp.getTagsFromByteArray(file.readAsBytes(), tags);

    setState(() {
      _tags = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    SimplePermissions.requestPermission(Permission.ReadExternalStorage).then((v) =>
      SimplePermissions.checkPermission(Permission.ReadExternalStorage).then((v) =>
        _loadMP3s().then((p) => _textController.text = p.first)));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new TextField(controller: _textController,),
          new Row(children: <Widget>[
            new Checkbox(
                value: _tagTypes[TagType.id3v1],
                onChanged: (bool value) {
                  setState(() {
                    _tagTypes[TagType.id3v1] = value;
                  });
                }),
            new Text('ID3v1.1')
          ]),
          new Row(children: <Widget>[
            new Checkbox(
                value: _tagTypes[TagType.id3v2],
                onChanged: (bool value) {
                  setState(() {
                    _tagTypes[TagType.id3v2] = value;
                  });
                }),
            new Text('ID3v2.4')
          ]),
          new ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) =>
                  new TagItem(_tags[index]),
              itemCount: _tags.length),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _loadTags,
        tooltip: 'read tag',
        child: new Icon(Icons.cached),
      ),
    );
  }
}

Future<List<String>> _loadMP3s() async {
  final dir = await getExternalStorageDirectory();
  final list = await dir.list(recursive: true, followLinks: false)
                        .where((FileSystemEntity entity) => entity.statSync().type == FileSystemEntityType.file && entity.path.endsWith('.mp3'))
                        .map((entry) => entry.path)
                        .toList();
  print(list);
  return list;
}

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class TagItem extends StatelessWidget {
  const TagItem(this.tag);

  final Tag tag;

  Widget _buildTiles(Tag root) {
    final img = new Uint8List.fromList(
        root.tags.containsKey('APIC') ? root.tags['APIC'].imageData : []);

    return new ExpansionTile(
      key: new PageStorageKey<Tag>(root),
      title: new Text('${root.type} v${root.version}'),
      children: <Widget>[
        new Text('tags:'),
        new Text(root.tags.toString()),
        new Image.memory(img)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(tag);
  }
}
