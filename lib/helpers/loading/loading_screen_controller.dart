import 'package:flutter/material.dart';

typedef CloseLOadingScreen = bool Function();
typedef UpdateLoadingScreens = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLOadingScreen close;
  final UpdateLoadingScreens update;

  const LoadingScreenController({required this.close, required this.update});
}
