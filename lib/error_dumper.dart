import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void dumpError(FlutterErrorDetails details) {
  try {
    final file = File('d:\\Workspace\\FPTU_documents\\Ky_8_SU26\\PRM393\\Mobile_Project\\prm393-group4-mobile-app\\error_dump.txt');
    file.writeAsStringSync('${DateTime.now()}\\n${details.exceptionAsString()}\\n${details.stack}\\n\\n', mode: FileMode.append);
  } catch (e) {
    // ignore
  }
}

void setupErrorCatcher() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    dumpError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      final file = File('d:\\Workspace\\FPTU_documents\\Ky_8_SU26\\PRM393\\Mobile_Project\\prm393-group4-mobile-app\\error_dump.txt');
      file.writeAsStringSync('${DateTime.now()}\\n$error\\n$stack\\n\\n', mode: FileMode.append);
    } catch (e) {}
    return true;
  };
}
