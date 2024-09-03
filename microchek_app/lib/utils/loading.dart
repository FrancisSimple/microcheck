// utils/loading.dart
import 'package:flutter/material.dart';import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SpinKitRipple(
          color: Colors.amber,
          size: 0.5 * MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}

Future<T?> loadingDialog<T>(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => LoadingScreen(),
    barrierDismissible: false,
  );
}
