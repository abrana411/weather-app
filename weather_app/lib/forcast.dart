import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './helper/data_fetcher.dart';

class forcastView extends StatefulWidget {
  static const routeName = "/forcast";
  var forcastMin = [];
  var forcastMax = [];
  var forcastType = [];
  var forcastIcon = [];

  forcastView(
      {Key? key,
      required this.forcastMin,
      required this.forcastMax,
      required this.forcastType,
      required this.forcastIcon})
      : super(key: key);

  @override
  _forcastViewState createState() => _forcastViewState();
}

class _forcastViewState extends State<forcastView> {
  @override
  Widget build(BuildContext context) {
    // Data dataItems = Provider.of<Data>(context);
    // var forcastMin = dataItems.forcastMin;
    // var forcastMax = dataItems.forcastMax;
    // var forcastType = dataItems.forcastType;
    // var forcastIcon = dataItems.forcastIcon;
    // double.parse(weatherInfo["temperature_val"])
    //       .toStringAsFixed(1)
    //       .toString()
    return Container(
      height: 350,
      width: 370,
      child: ListView.builder(
        itemBuilder: (BuildContext ctx, index) {
          return Card(
            child: ListTile(
              title: Text(DateFormat('EEEE')
                  .format(DateTime.now().add(Duration(days: index)))),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "http://openweathermap.org/img/wn/${widget.forcastIcon[index]}@2x.png"),
              ),
              subtitle: Text(
                  "Max/Min :  ${double.parse(widget.forcastMax[index]).toStringAsFixed(1).toString()}/${double.parse(widget.forcastMin[index]).toStringAsFixed(1).toString()}"),
              trailing: Text(
                widget.forcastType[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        itemCount:
            7, //kisi bhi list ki length le sakte h ya direct 7 bhi kyunki vo constant h hame pata h
      ),
    );
  }
}
