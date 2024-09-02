// microfinance.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyMicroPage extends StatefulWidget {
  const MyMicroPage({super.key});

  @override
  State<MyMicroPage> createState() => _MyMicroPageState();
}

class _MyMicroPageState extends State<MyMicroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Microfinance'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('My Microfinance Page'),
      ),
    );
  }
}