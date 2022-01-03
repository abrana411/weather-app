import 'package:flutter/material.dart';
import './screens/home_scr.dart';
import './screens/loading_screen.dart';
import './forcast.dart';

void main() {
  runApp(MaterialApp(
    title: "vatavaran",
    routes: {
      "/": (ctx) => const Loading(),
      forcastView.routeName: (ctx) => const forcastView(),
      HomeScreen.routeName: (ctx) => const HomeScreen(),
      Loading.routeName: (ctx) => const Loading(),
    },
  ));
}
