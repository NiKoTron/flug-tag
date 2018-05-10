import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dart_tags/dart_tags.dart';


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
  Uint8List _imageData = new Uint8List(0);
  String _artist = "";
  String _title = "";
  String _comment = "";

  Future _incrementCounter() async {
    
    var d = await DefaultAssetBundle.of(context).load('data/mp3.mp3');

      TagProcessor tp = new TagProcessor();
      var l = await tp.getTagsFromByteData(d, [TagType.id3v2]);

      AttachedPicture ai = l[0].tags['APIC'];

    setState(() {
      _artist = l[0].tags['artist'];
      _title = l[0].tags['title'];
      _comment = l[0].tags['comment'];
      _imageData = new Uint8List.fromList(ai.imageData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('artist:$_artist\ntitle:$_title\ncomment:$_comment\n'),
            new Image.memory(_imageData),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'read tag',
        child: new Icon(Icons.cached),
      ), 
    );
  }
}
