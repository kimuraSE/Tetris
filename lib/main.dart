import 'package:flutter/material.dart';
import 'package:tetris/ui/home/home_view.dart';

void main() {
  runApp(const MissionPackApp());
}

class MissionPackApp extends StatelessWidget {
  const MissionPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ミッションパック',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
