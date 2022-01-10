import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../helper/data_fetcher.dart';
import '../screens/loading_screen.dart';

class Favcities extends StatefulWidget {
  static const routeName = "/fav";
  const Favcities({Key? key}) : super(key: key);

  @override
  State<Favcities> createState() => _FavcitiesState();
}

class _FavcitiesState extends State<Favcities> {
  //Map<String, String> cities = {};
  // @override
  // void didChangeDependencies() {
  //   cities =
  //       Provider.of<Data>(context).Fav; //getting the list of favourite cities
  //   Provider.of<Data>(context).fetchAndSetDataFromDb();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    Map currentCity = ModalRoute.of(context)!.settings.arguments
        as Map; //getting current city from home to go back to it
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text("Favourites"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Loading.routeName,
                      arguments: {"Text": currentCity["currentcity"]});
                },
                icon: const Icon(Icons.keyboard_backspace_sharp))
          ],
        ),
        body: FutureBuilder(
            future: Provider.of<Data>(context,
                    listen:
                        false) //not listening here as the notify listener inside this will make the below consumer listen itself and if i listen here then the fetch data will keep on running and running in a loop
                .fetchAndSetDataFromDb(), //since this returns a future so using this in future builder to fetch the data from our data bse...and once we have out _places list updated with the data..from databse(helpful when we closed the app and _places is empty initially so we will fetch the data which was there when the app was perviously working so fetching that data)
            builder: (ctx, datasnapshot) =>
                // datasnapshot.connectionState ==
                //         ConnectionState.waiting
                //     ? const Center(
                //         child:
                //             CircularProgressIndicator(), //showing loading indiator until gets the data and once i get it then showing the list of places via listView builder
                //       )
                //     :
                Consumer<Data>(
                  child: Stack(children: [
                    Container(
                        color: Colors.grey,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/nothing.png",
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: const Text("No Favourites yet",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              //decoration: TextDecoration.underline,
                              color: Colors.white,
                              fontSize:
                                  20)), //this is child of consumer which do not get re build we know that...and using this to show in body only if we don't have any places in the _places list in the provider userPlaces
                    ),
                  ]),
                  // ignore: non_constant_identifier_names
                  builder: (ctx, FavData, ch) => FavData.Fav.isEmpty
                      ? ch! //if no places are there then show that child ....have to do ch! for null safety
                      : Column(
                          children: [
                            Expanded(
                              child: Image.asset(
                                "assets/images/city.jpg",
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Container(
                              height: 500,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  //color: Colors.orange,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    // stops: [0.1, 0.9], //this means 0 to 10 % blue color then 10 to 90 % transition from blue to transparent and 90 to 100 % transparent
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.red.shade300
                                    ],
                                  ),
                                  // border: Border(
                                  //     right: BorderSide(
                                  //         width: 5, color: Colors.orange),
                                  //     left: BorderSide(
                                  //         width: 5, color: Colors.orange),
                                  //     bottom: BorderSide(
                                  //         width: 5, color: Colors.orange))
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.pink,
                                  )),
                              child: ListView.builder(
                                itemBuilder: (ctx, index) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    color: Colors.black,
                                    child: ListTile(
                                      title: Text(
                                        FavData.Fav.entries.toList()[index].key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white),
                                      ), //to get key
                                      leading: CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 2,
                                                  color: Colors.white)),
                                        ),
                                        width: 170,
                                        child: Row(
                                          children: [
                                            Text(
                                              double.parse(FavData.Fav.entries
                                                          .toList()[index]
                                                          .value)
                                                      .toStringAsFixed(
                                                          1) //to show 1 value after decimal point only
                                                      .toString() +
                                                  "°c",
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.blue),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Provider.of<Data>(context,
                                                        listen: false)
                                                    .removeFavCity(FavData
                                                        .Fav.entries
                                                        .toList()[index]
                                                        .key);
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red[400],
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                    context, Loading.routeName,
                                                    arguments: {
                                                      "Text": FavData
                                                          .Fav.entries
                                                          .toList()[index]
                                                          .key
                                                    });
                                              },
                                              child: const Icon(
                                                Icons.double_arrow_rounded,
                                                color: Colors.pink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: FavData.Fav.length,
                              ),
                            ),
                          ],
                        ),
                )));
  }
}
