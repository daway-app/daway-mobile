import 'package:flutter/material.dart';
class DawayApp extends StatelessWidget {
  const DawayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'دوائي',
      debugShowCheckedModeBanner: false,
    );
  }
}