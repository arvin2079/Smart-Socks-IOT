import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:smart_socks_iot/theme_data.dart';
import 'package:smart_socks_iot/states/app_state.dart' as appState;

import './MainPage.dart';

void main() {
  ErrorWidget.builder = (details) {
    return const Center(child: Text('check the connection, or reload please!'));
  };
  runApp(IOTApp());
}

class IOTApp extends StatelessWidget {
  const IOTApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: appState.singletonInstance.themeMode,
        home: MainPage(),
      ),
    );
  }
}
