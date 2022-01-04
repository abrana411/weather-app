import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/helper/data_fetcher.dart';
import './loading_screen.dart';

import '../forcast.dart';

// import 'dart:convert';
// import 'package:http/http.dart';
import 'package:weather_icons/weather_icons.dart';
//api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var showForcast = false;
  var temp = "";
  var windSpeed = "";
  var loading = false;
  String pmcheck = "";
  String pm10check = "";
  String no2check = "";
  String o3check = "";
  var c1;
  var c2;
  var c3;
  var c4;
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var exampleCities = ["delhi", "mumbai", "chennai", "london", "new york"];
    final random = Random(); //creating instance of random class
    var excity = exampleCities[random.nextInt(exampleCities
        .length)]; //this random.nextInt(exampleCities.length) will give random number from length of list and that we are putting in list[rando no.] so we are getting a random city name from above cities in list everytime

    //since need context here so making this inside the build method
    Map weatherInfo = ModalRoute.of(context)!.settings.arguments
        as Map; //using !. as null safety feature since the value of ModalRoute.of(context) can be null

    if (weatherInfo["temperature_val"].toString() != "NA") {
      temp = double.parse(weatherInfo["temperature_val"])
          .toStringAsFixed(1)
          .toString();
    } else {
      temp = weatherInfo["temperature_val"];
    }
    if (weatherInfo["windSpeed_val"].toString() != "NA") {
      windSpeed = double.parse(weatherInfo["windSpeed_val"])
          .toStringAsFixed(1)
          .toString();
    } else {
      windSpeed = weatherInfo["windSpeed_val"];
    }
    //for pm2.5
    if (double.parse(weatherInfo["pm2_val"]) <= 55) {
      pmcheck = "Good";
      c1 = Colors.green;
    } else if (double.parse(weatherInfo["pm2_val"]) > 55 &&
        double.parse(weatherInfo["pm2_val"]) < 200) {
      pmcheck = "Moderate";
      c1 = Colors.yellow;
    } else {
      pmcheck = "very-poor";
      c1 = Colors.red;
    }
    //for pm10
    if (double.parse(weatherInfo["pm10_val"]) <= 55) {
      pm10check = "Good";
      c2 = Colors.green;
    } else if (double.parse(weatherInfo["pm10_val"]) > 55 &&
        double.parse(weatherInfo["pm10_val"]) < 200) {
      pm10check = "Moderate";
      c2 = Colors.yellow;
    } else {
      pm10check = "very-poor";
      c2 = Colors.red;
    }
    //for no2
    if (double.parse(weatherInfo["no2_val"]) <= 100) {
      no2check = "Good";
      c3 = Colors.green;
    } else if (double.parse(weatherInfo["no2_val"]) > 100 &&
        double.parse(weatherInfo["no2_val"]) < 200) {
      no2check = "Moderate";
      c3 = Colors.yellow;
    } else {
      no2check = "very-poor";
      c3 = Colors.red;
    }
    //for o3
    if (double.parse(weatherInfo["o3_val"]) <= 100) {
      o3check = "Good";
      c4 = Colors.green;
    } else if (double.parse(weatherInfo["o3_val"]) > 100 &&
        double.parse(weatherInfo["o3_val"]) < 180) {
      o3check = "Moderate";
      c4 = Colors.yellow;
    } else {
      o3check = "very-poor";
      c4 = Colors.red;
    }

    //since not using provider so below method is not used
    // void ForcastGet() async {
    //   loading = true;
    //   await Provider.of<Data>(context, listen: false).getForcast();
    //   setState(() {
    //     loading = false;
    //   });
    //}

    return Scaffold(
      resizeToAvoidBottomInset:
          false, //isse jab tex field me click kare h to j keyboard h vo screen ke uper he aa jata h to padding nhi lete hm keyboard se to sizing problem nhi hoti
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
            0), //making the app bar with 0 height so that we cant see it as we dont need it
        child: AppBar(
          backgroundColor: Colors
              .blue, //but doing this ie giving background colour to the AppBar widget also changes the colour of the status bar above so we change that to blue without creating appbar but using app bar widget and property
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            //taki phone me jo uper vali bar hoti h uske niche se aaye text as we dont want app bar here
            child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // stops: [0.1, 0.9], //this means 0 to 10 % blue color then 10 to 90 % transition from blue to transparent and 90 to 100 % transparent
            colors: [Colors.blue, Colors.transparent],
          )),
          child: Column(
            children: [
              //1st container (search bar)
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (searchTextController.text == "") {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Write some valid place name in search bar!")));
                        } else {
                          Navigator.pushReplacementNamed(
                              context, Loading.routeName, arguments: {
                            "SearchedText": searchTextController.text.trim()
                          });
                        }
                      },
                      child: const Icon(Icons.search),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        //textfield should be kept in expanded if used inside a row
                        child: TextField(
                      controller:
                          searchTextController, //assigning controller and the text in extfield will be stored in this controller now
                      decoration: InputDecoration(
                          // label: Text("Search a place..."),
                          hintText:
                              "search a place eg, $excity", //this is a placeholder which fades away when we starts typing
                          border: InputBorder.none),
                    )),
                  ],
                ),
              ),

              //2nd container:-
              Row(
                children: [
                  Expanded(
                    //expanded iske aander ke child ko expand kar deta h iske parent ke main axis allignment ke hesab se(abhi to prent column h to ye iske aander vale container ko container ka main axis matlab vertically expand kar dega par ham horizontally chahte h to row se bind kr denge expanded ko)
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          Image.network(
                              "http://openweathermap.org/img/wn/${weatherInfo["iconWeather_val"]}@2x.png",
                              width: 80,
                              height: 80),
                          const SizedBox(
                            width: 80,
                          ),
                          Column(
                            children: [
                              Text(weatherInfo["typeOfweather_val"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                "in ${weatherInfo["cityName_val"]}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.refresh,
                              size: 30,
                            ),
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, Loading.routeName, arguments: {
                                "SearchedText": weatherInfo["cityName_val"]
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //3rd container
              Row(
                children: [
                  Expanded(
                    //expanded iske aander ke child ko expand kar deta h iske parent ke main axis allignment ke hesab se(abhi to prent column h to ye iske aander vale container ko container ka main axis matlab vertically expand kar dega par ham horizontally chahte h to row se bind kr denge expanded ko)
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      height: 250,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, //horizonatally starting
                        children: [
                          const Icon(
                            WeatherIcons.thermometer,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 100,
                              ),
                              Text(
                                temp,
                                style: const TextStyle(fontSize: 70),
                              ),
                              const Text(
                                "c",
                                style: TextStyle(fontSize: 35),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //4th and 5th containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(
                                WeatherIcons.windy,
                                color: Colors.blueGrey,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Text(
                            windSpeed,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const Text("km/hr")
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                WeatherIcons.humidity,
                                color: Colors.red[300],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 45,
                          ),
                          Text(
                            "${weatherInfo["humidity_val"]}",
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "%",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black26),
                    width: 120,
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                showForcast = !showForcast;
                              });
                              //ForcastGet();
                            },
                            child: const Text(
                              // !showForcast ? "More" : "less",
                              "Forcast",
                              style: TextStyle(color: Colors.white),
                            )),
                        !showForcast
                            ? const Icon(Icons.expand_more_outlined)
                            : const Icon(Icons.expand_less_outlined),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 50),
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 300,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 250,
                                      child: ListView(
                                        children: [
                                          Card(
                                            child: ListTile(
                                              leading:
                                                  const Icon(Icons.forward),
                                              title:
                                                  const Text("PM 2.5 Level:"),
                                              subtitle:
                                                  Text(weatherInfo["pm2_val"]),
                                              trailing: Text(
                                                pmcheck,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: c1),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            child: ListTile(
                                                leading:
                                                    const Icon(Icons.forward),
                                                title:
                                                    const Text("PM 10 Level:"),
                                                subtitle: Text(
                                                    weatherInfo["pm10_val"]),
                                                trailing: Text(
                                                  pm10check,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: c2,
                                                  ),
                                                )),
                                          ),
                                          Card(
                                            child: ListTile(
                                              leading:
                                                  const Icon(Icons.forward),
                                              title:
                                                  const Text("PM NO2 Level:"),
                                              subtitle:
                                                  Text(weatherInfo["no2_val"]),
                                              trailing: Text(
                                                no2check,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: c3),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            child: ListTile(
                                              leading:
                                                  const Icon(Icons.forward),
                                              title: const Text("PM O3 Level:"),
                                              subtitle:
                                                  Text(weatherInfo["o3_val"]),
                                              trailing: Text(
                                                o3check,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: c4),
                                              ),
                                            ),
                                          ),
                                          Card(
                                              child: ListTile(
                                            leading: const Icon(Icons.forward),
                                            title: const Text("PM SO2 Level:"),
                                            subtitle:
                                                Text(weatherInfo["so2_val"]),
                                            trailing: double.parse(weatherInfo[
                                                        "so2_val"]) <
                                                    100
                                                ? const Text(
                                                    "Good",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green),
                                                  )
                                                : const Text(
                                                    "Poor",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 17,
                                        ),
                                        label: const Text("Close"))
                                  ],
                                ),
                              );
                            });
                      },
                      child: const Text("AQI"),
                    ),
                  ),
                ],
              ),
              if (showForcast &&
                  (weatherInfo["temperature_val"].toString() != "NA"))
                forcastView(
                  forcastMax: weatherInfo["forcastMax_val"],
                  forcastMin: weatherInfo["forcastMin_val"],
                  forcastType: weatherInfo["forcastType_val"],
                  forcastIcon: weatherInfo["forcastIcon_val"],
                ),
              if (showForcast &&
                  (weatherInfo["temperature_val"].toString() == "NA"))
                const Center(
                    child: Text(
                  "Enter a valid place to get forcast!!",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              //if (showForcast && !loading) const forcastView(),
              // if (showForcast && loading)
              //   const Center(
              //     child: CircularProgressIndicator(),
              //   ),

              Container(
                margin: const EdgeInsets.all(13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Made By Abhay"),
                    Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 17,
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
