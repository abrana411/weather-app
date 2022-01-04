import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/helper/data_fetcher.dart';
import './screens/home_scr.dart';
import './screens/loading_screen.dart';
import './forcast.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (ctx) => Data(location: "Delhi"),
    child: MaterialApp(
      title: "vatavaran",
      routes: {
        "/": (ctx) => const Loading(),
        forcastView.routeName: (ctx) => forcastView(
              forcastIcon: [],
              forcastMax: [],
              forcastMin: [],
              forcastType: [],
            ),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        Loading.routeName: (ctx) => const Loading(),
      },
    ),
  ));
}
