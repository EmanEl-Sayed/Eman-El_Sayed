import 'package:flutter/material.dart';
import 'package:test/Home.dart';

void main() {
  runApp(Project());
}

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _TestState();
}

class _TestState extends State<Project> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
