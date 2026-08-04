import 'package:flutter/material.dart';

class DawayApp extends StatelessWidget {
  const DawayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دوائي',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('دَوائي')),
      ),
    );
  }
}