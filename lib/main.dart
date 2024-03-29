import 'package:flutter/material.dart';
import 'musicplayer.dart' as musicplayer;
import 'permissions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    musicplayer.hideAppBar();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetPermissions(),
    );
  }
}