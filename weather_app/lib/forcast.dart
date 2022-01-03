import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class forcastView extends StatefulWidget {
  static const routeName = "/forcast";
  const forcastView({Key? key}) : super(key: key);

  @override
  _forcastViewState createState() => _forcastViewState();
}

class _forcastViewState extends State<forcastView> {
  String day =
      DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 1)));
  @override
  Widget build(BuildContext context) {
    return
        // ListView.builder(
        //   itemBuilder: (BuildContext ctx, index) {
        //     return Card(
        //       child: ListTile(title: Text(DateTime.now().day.toString()),
        //                  leading: const CircleAvatar(backgroundImage: NetworkImage("http://openweathermap.org/img/wn/09d@2x.png"),),
        //                  subtitle: const Text("Max/Min :  12/13"),
        //              ),
        //     );
        //   },
        //   itemCount: 4,
        // );
        Container(
      height: 350,
      width: 350,
      child: ListView(
        children: [
          Card(
            color: Colors.grey[500],
            child: ListTile(
              title: Text(DateFormat('EEEE').format(DateTime.now())),
              leading: const CircleAvatar(
                backgroundImage:
                    NetworkImage("http://openweathermap.org/img/wn/09d@2x.png"),
              ),
              subtitle: const Text("Max/Min :  12/13"),
              trailing: Text("humid"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(DateFormat('EEEE')
                  .format(DateTime.now().add(const Duration(days: 1)))),
              leading: const CircleAvatar(
                backgroundImage:
                    NetworkImage("http://openweathermap.org/img/wn/09d@2x.png"),
              ),
              subtitle: const Text("Max/Min :  12/13"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(DateTime.now().day.toString()),
              leading: const CircleAvatar(
                backgroundImage:
                    NetworkImage("http://openweathermap.org/img/wn/09d@2x.png"),
              ),
              subtitle: const Text("Max/Min :  12/13"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(DateTime.now().day.toString()),
              leading: const CircleAvatar(
                backgroundImage:
                    NetworkImage("http://openweathermap.org/img/wn/09d@2x.png"),
              ),
              subtitle: const Text("Max/Min :  12/13"),
            ),
          ),
        ],
      ),
    );
  }
}
