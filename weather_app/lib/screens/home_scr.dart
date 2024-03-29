import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/helper/data_fetcher.dart';
import './loading_screen.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../forcast.dart';
import '../screens/fav_cities.dart';

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
  //var _isforcastShow = false;
  var isFav = false;
  var showForcast = false;
  var temp = "";
  // ignore: non_constant_identifier_names
  var feels_like = "";
  var windSpeed = "";
  var loading = false;
  String pmcheck = "";
  String pm10check = "";
  String no2check = "";
  String o3check = "";
  var c1 = Colors.black;
  var c2 = Colors.black;
  var c3 = Colors.black;
  var c4 = Colors.black;
  String moonRise = "NIL";
  String sunRise = "NIL";
  String moonSet = "NIL";
  String sunSet = "NIL";
  String imageToShowInBG = "Thunderstorm";
  IconData windDir = WeatherIcons.wind_deg_0;
  // String isAmMoonRise = "AM";
  // String isAmMoonSet = "AM";
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    var SuggestData = Provider.of<Data>(context, listen: false).suggestCity;
    //print(SuggestData);
    var exampleCities = ["delhi", "mumbai", "chennai", "london", "new york"];
    final random = Random(); //creating instance of random class
    var excity = exampleCities[random.nextInt(exampleCities
        .length)]; //this random.nextInt(exampleCities.length) will give random number from length of list and that we are putting in list[rando no.] so we are getting a random city name from above cities in list everytime

    //since need context here so making this inside the build method
    Map weatherInfo = ModalRoute.of(context)!.settings.arguments
        as Map; //using !. as null safety feature since the value of ModalRoute.of(context) can be null
    // print(weatherInfo["hourlytime_val"]);
    if (weatherInfo["temperature_val"].toString() != "NA") {
      temp = double.parse(weatherInfo["temperature_val"])
          .toStringAsFixed(1)
          .toString();
      feels_like = double.parse(weatherInfo["feelsLike_val"])
          .toStringAsFixed(1)
          .toString();
    } else {
      temp = weatherInfo["temperature_val"];
      feels_like = "NA";
    }
    if (weatherInfo["windSpeed_val"].toString() != "NA") {
      windSpeed = double.parse(weatherInfo["windSpeed_val"])
          .toStringAsFixed(1)
          .toString();
    } else {
      windSpeed = weatherInfo["windSpeed_val"];
    }
    if (weatherInfo["temperature_val"].toString() != "NA") {
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
    }

    if (Provider.of<Data>(context, listen: false)
        .doesContain(weatherInfo["cityName_val"])) {
      isFav = true;
    }

    String capitalize(String s) {
      return (s[0].toUpperCase() +
          s
              .substring(1)
              .toLowerCase()); //will return string s where only first letter will be capital
    }

    Future<bool> _checkForstatus(String txt) async {
      final Response res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$txt&appid=0845098f21354236ac51412680d05df7"));
      Map data = json.decode(res.body);
      if (data["cod"] == "404") {
        return false;
      }
      return true;
    }

    //when we submit the textfield or click on the search icon then this below method will be triggered
    void onSearched() async {
      if (searchTextController.text == "") {
        // if (str == "") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Write some valid place name in search bar!",
                style: TextStyle(color: Colors.red))));
      } else {
        //before doing anything i will check if ...the status is ok or not ie if i get the data or not for this place
        bool isAlright = await _checkForstatus(searchTextController.text);
        if (isAlright) {
          Provider.of<Data>(context, listen: false)
              .AddAndRemoveSuggest(searchTextController.text.trim());
          Navigator.pushReplacementNamed(context, Loading.routeName,
              arguments: {
                "Text": capitalize(searchTextController.text.trim()),
                "isfirst": false
              });
          // arguments: {"Text": capitalize(str.trim())});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Could not fetch data for this location!",
            style: TextStyle(color: Colors.red),
          )));
        }
      }
    }

    if (weatherInfo["temperature_val"].toString() != "NA") {
      //only if valid place is there
      //assigning the sunrise,moonrise,sunset and moonset dates by converting the epoch(time in sec given from start to now) and using date formatter
      moonRise = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(weatherInfo["moonrise_val"]) * 1000));
      sunRise = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(weatherInfo["sunrise_val"]) * 1000));
      moonSet = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(weatherInfo["moonset_val"]) * 1000));
      sunSet = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(
          int.parse(weatherInfo["sunset_val"]) * 1000));
    }

    // if (DateTime.fromMillisecondsSinceEpoch( //no need since using international clock
    //             int.parse(weatherInfo["moonrise_val"]) * 1000)
    //         .hour >
    //     12) {
    //   isAmMoonRise = "PM";
    // }
    // if (DateTime.fromMillisecondsSinceEpoch(
    //             int.parse(weatherInfo["moonset_val"]) * 1000)
    //         .hour >
    //     12) {
    //   isAmMoonSet = "PM";
    // }

    //since not using provider so below method is not used
    // void ForcastGet() async {
    //   loading = true;
    //   await Provider.of<Data>(context, listen: false).getForcast();
    //   setState(() {
    //     loading = false;
    //   });
    //}

    // Future.delayed(Duration(seconds: 3), () {
    //   _isforcastShow = true;
    // });

    //Assigning the wind direction Icon:-
    if (weatherInfo["windDirection_val"] == "N") {
      windDir = WeatherIcons.wind_deg_0;
    } else if (weatherInfo["windDirection_val"] == "NNE" ||
        weatherInfo["windDirection_val"] == "NE" ||
        weatherInfo["windDirection_val"] == "ENE") {
      windDir = WeatherIcons.wind_deg_45;
    } else if (weatherInfo["windDirection_val"] == "E") {
      windDir = WeatherIcons.wind_deg_90;
    } else if (weatherInfo["windDirection_val"] == "ESE" ||
        weatherInfo["windDirection_val"] == "SE" ||
        weatherInfo["windDirection_val"] == "SSE") {
      windDir = WeatherIcons.wind_deg_135;
    } else if (weatherInfo["windDirection_val"] == "S") {
      windDir = WeatherIcons.wind_deg_180;
    } else if (weatherInfo["windDirection_val"] == "SSW" ||
        weatherInfo["windDirection_val"] == "SW" ||
        weatherInfo["windDirection_val"] == "WSW") {
      windDir = WeatherIcons.wind_deg_225;
    } else if (weatherInfo["windDirection_val"] == "W") {
      windDir = WeatherIcons.wind_deg_270;
    } else if (weatherInfo["windDirection_val"] == "WNW" ||
        weatherInfo["windDirection_val"] == "NW" ||
        weatherInfo["windDirection_val"] == "NNW") {
      windDir = WeatherIcons.wind_deg_315;
    }

    //Selecting image to show in background:-
    if (weatherInfo["typeOfweather_val"] == "Sand" ||
        weatherInfo["typeOfweather_val"] == "Ash" ||
        weatherInfo["typeOfweather_val"] == "Dust" ||
        weatherInfo["typeOfweather_val"] == "Smoke") {
      imageToShowInBG = "Dust";
    } else if (weatherInfo["typeOfweather_val"] != "NA") {
      imageToShowInBG = weatherInfo["typeOfweather_val"];
    }

    return Scaffold(
      resizeToAvoidBottomInset:
          false, //isse jab tex field me click kare h to j keyboard h vo screen ke uper he aa jata h to padding nhi lete hm keyboard se to sizing problem nhi hoti
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
            0), //making the app bar with 0 height so that we cant see it as we dont need it
        child: AppBar(
          backgroundColor: Colors
              .black45, //by doing this ie giving background colour to the AppBar widget also changes the colour of the status bar above so we change that to blue without creating appbar but using app bar widget and property
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            //taki phone me jo uper vali bar hoti h uske niche se aaye text as we dont want app bar here
            child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // stops: [0.1, 0.9], //this means 0 to 10 % blue color then 10 to 90 % transition from blue to transparent and 90 to 100 % transparent
              colors: [Colors.blue, Colors.transparent],
            ),
            image: DecorationImage(
                image: AssetImage("assets/images/$imageToShowInBG.jpg"),
                fit: BoxFit.cover),
          ),
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
                        onSearched();
                      },
                      child: const Icon(Icons.search),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        //textfield should be kept in expanded if used inside a row
                        child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        //here TexEdiingValue is he query r he thing we are writing in the field
                        if (textEditingValue.text.isEmpty) {
                          return []; //returning an empty list if nothing is written in the text field inside autocomplete.so that we can get rid of the suggestions by removing everything from the field...otherwise if i dont add this then i will get the suggestions even after i dont have anything written in the field
                        } else //agar kuch likha h field me to ...jitna part match hoga kisi list ke item se...us list ke item ko bhej denge
                        {
                          return SuggestData.where((place) => place
                              .toLowerCase()
                              .contains(textEditingValue
                                  .text)); //matlab jo ham likh rahe h vo jis place me aate h wrds unhe he shw krenge bs
                        }
                      },
                      // onSelected: (selectedSuggestion) {
                      //   onSearched(selectedSuggestion
                      //       as String); //agar hamne suggestion me se kisi pe click kr diya to
                      // },

                      // optionsMaxHeight:
                      //     350, //heigh of the sheet which has suggestions
                      optionsViewBuilder:
                          (context, Function(String) onSelected, options) {
                        //here have to specify he type of argumen n seleceted will take
                        //options is the things in the suggestions..it is iterabke bject not a list particularly
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            //have to wrap lisview seperated in a material here
                            child: Container(
                              width: 250,
                              //height: 200,
                              decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  border: Border(
                                      left: BorderSide(color: Colors.white),
                                      right: BorderSide(color: Colors.white),
                                      bottom: BorderSide(color: Colors.white))),
                              child: ListView.builder(
                                  shrinkWrap:
                                      true, //height will be based on the number of elements of this list tile
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    //har ek option kaise dikhega
                                    return ListTile(
                                      onTap: () {
                                        onSelected(options
                                            .elementAt(index)
                                            .toString()); //so that it gets seleced when we click on it..by default if we dont write optionviewbuilder ..then it will have automatic nSelecetd function
                                      },
                                      // title: Text(options
                                      //     .elementAt(index)
                                      //     .toString()), //this is how we can give each element for iterable options to title
                                      title: SubstringHighlight(
                                        text:
                                            options.elementAt(index).toString(),
                                        term: searchTextController.text,
                                        textStyle: const TextStyle(
                                            color: Colors.white),
                                        textStyleHighlight: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                      //this is a widget from substring highlight package and here text is the total text which i want to show and the term is the text which i want to highlight
                                    );
                                  },
                                  itemCount: options.length),
                            ),
                          ),
                        );
                      },
                      fieldViewBuilder: (context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        searchTextController = fieldTextEditingController;
                        return TextField(
                            //field view ke aander reurn kar sake h ext field agar ki sling deni h to AuCmplee tex field ko
                            focusNode: fieldFocusNode,
                            onSubmitted: (str) {
                              onSearched();
                            },
                            controller: fieldTextEditingController,
                            // controller:
                            //     searchTextController, //assigning controller and the text in extfield will be stored in this controller now
                            decoration: InputDecoration(
                              // label: Text("Search a place..."),
                              hintText:
                                  "search a place eg, $excity", //this is a placeholder which fades away when we starts typing
                              border: InputBorder.none,
                              // prefixIcon: Icon(Icons.search)),
                            ));
                      },
                    )),
                    PopupMenuButton(
                        shape: const OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                          width: 3,
                        )),
                        offset: const Offset(30, 40),
                        child: const SizedBox(
                            width: 20, child: Icon(Icons.settings)),
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "My Favourite cities",
                                      style: TextStyle(fontSize: 15),
                                    )
                                  ],
                                ),
                                value: 1,
                              ),
                            ],
                        onSelected: (val) {
                          if (val == 1) {
                            // Navigator.pushReplacementNamed(
                            //     context, Favcities.routeName,
                            //     arguments: {
                            //       "currentcity": weatherInfo["cityName_val"],
                            //       "citiesFav": Provider.of<Data>(
                            //         context,
                            //         listen: false,
                            //       ).Fav.keys.toList()
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Favcities(
                                          Currentcity:
                                              weatherInfo["cityName_val"],
                                          favCities: Provider.of<Data>(
                                            context,
                                            listen: false,
                                            // ).Fav.keys.toList(),
                                          ).Fav, //only Fav now
                                        )));
                          }
                        })
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
                        color: Colors.white38,
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
                            height: 80,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                  "assets/images/defaultcloud.png",
                                  width: 80,
                                  height: 80);
                            },
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Text(weatherInfo["typeOfweather_val"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                "in ${weatherInfo["cityName_val"]} (${weatherInfo["CCode_val"]})",
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
                                "Text": weatherInfo["cityName_val"],
                                "isfirst": false
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
                        color: Colors.white38,
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
                            size: 30,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 100,
                                  ),
                                  Text(
                                    temp,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                  const Text(
                                    "°c",
                                    style: TextStyle(fontSize: 35),
                                  )
                                ],
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 80),
                                  child: Text(
                                      "Feels Like : " + feels_like + "°c")),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 15, top: 23),
                                child: PopupMenuButton(
                                  shape: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  )),
                                  offset: const Offset(30, 40),
                                  child: const SizedBox(
                                      width: 20,
                                      child: Icon(
                                        Icons.wb_sunny_rounded,
                                        color: Colors.orange,
                                        size: 27,
                                      )),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                WeatherIcons.sunrise,
                                                color: Colors.red[300],
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                // sunRise + " AM",
                                                sunRise,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          // const SizedBox(
                                          //   height: 20,
                                          // ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              Icon(
                                                WeatherIcons.sunset,
                                                color: Colors.red[300],
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                // sunSet + " PM",
                                                sunSet,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      ),
                                      value: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                margin:
                                    const EdgeInsets.only(right: 15, top: 23),
                                child: PopupMenuButton(
                                  shape: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  )),
                                  offset: const Offset(-30, 40),
                                  child: const SizedBox(
                                      width: 20,
                                      child: Icon(
                                        WeatherIcons.moon_alt_third_quarter,
                                        size: 27,
                                      )),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(WeatherIcons.moonrise,
                                                  color: Colors.blueGrey),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                // moonRise + " " + isAmMoonRise,
                                                moonRise,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          // const SizedBox(
                                          //   height: 20,
                                          // ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              const Icon(WeatherIcons.moonset,
                                                  color: Colors.blueGrey),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                // moonSet + " " + isAmMoonSet, //dont need am or pm since using international clock
                                                moonSet,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      ),
                                      value: 1,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //6th (will have hourly forcast)
              Row(
                children: [
                  Expanded(
                      child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    height: 100,
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap:
                          true, //such that the contents of the list wrap will nly take that much space which is needed and dont try to fill the container parent's space if is extra
                      scrollDirection: Axis
                          .horizontal, //horizontal direction de di scroll ke liye
                      itemBuilder: (ctx, index) {
                        String temp = weatherInfo["temperature_val"] == "NA"
                            ? "NIL"
                            : double.parse(weatherInfo["hourlytemp_val"][index])
                                .toStringAsFixed(1)
                                .toString();
                        return GestureDetector(
                          child: Container(
                              width: 100,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              margin: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  // border:
                                  //     Border.all(width: 3, color: Colors.black),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "$temp °c",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                weatherInfo["temperature_val"] == "NA"
                                    ? Image.network(
                                        "http://openweathermap.org/img/wn/o9d@2x.png",
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                              "assets/images/defaultcloud.png",
                                              width: 40,
                                              height: 40);
                                        },
                                      )
                                    : Image.network(
                                        "http://openweathermap.org/img/wn/${weatherInfo["hourlylogo_val"][index]}@2x.png",
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                              "assets/images/defaultcloud.png",
                                              width: 40,
                                              height: 40);
                                        },
                                      ),
                                Text(
                                  weatherInfo["hourlytime_val"][index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ])),
                        );
                      },
                      // itemCount: weatherInfo["hourlytime_val"].length, //not working have to give the number
                      itemCount:
                          weatherInfo["temperature_val"] == "NA" ? 0 : 24,
                    ),
                  ))
                ],
              ),
              //4th and 5th containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      height: 200,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                WeatherIcons.windy,
                                color: Color.fromARGB(255, 57, 157, 206),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "(" +
                                        weatherInfo["windDirection_val"] +
                                        ")",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Icon(windDir),
                                ],
                              ),
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
                        color: Colors.white38,
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
                  GestureDetector(
                    onTap: () {
                      if (weatherInfo["temperature_val"].toString() == "NA") {
                        null;
                      } else {
                        setState(() {
                          showForcast = !showForcast;
                        });
                      }
                      //ForcastGet();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black26),
                      width: 150,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TextButton(
                              onPressed: null,
                              child: Text(
                                // !showForcast ? "More" : "less",
                                "Daily Forecast",
                                style: TextStyle(color: Colors.white),
                              )),
                          !showForcast
                              ? const Icon(Icons.expand_more_outlined)
                              : const Icon(Icons.expand_less_outlined),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 30),
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.amber[500],
                      heroTag: "bt1",
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return weatherInfo["temperature_val"]
                                          .toString() !=
                                      "NA"
                                  ? SizedBox(
                                      height: 300,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 250,
                                            child: ListView(
                                              children: [
                                                Card(
                                                  child: ListTile(
                                                    leading: const Icon(
                                                        Icons.forward),
                                                    title: const Text(
                                                        "PM 2.5 Level:"),
                                                    subtitle: Text(
                                                        weatherInfo["pm2_val"] +
                                                            "μg/m3"),
                                                    trailing: Text(
                                                      pmcheck,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c1),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  child: ListTile(
                                                      leading: const Icon(
                                                          Icons.forward),
                                                      title: const Text(
                                                          "PM 10 Level:"),
                                                      subtitle: Text(
                                                          weatherInfo[
                                                                  "pm10_val"] +
                                                              "μg/m3"),
                                                      trailing: Text(
                                                        pm10check,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c2,
                                                        ),
                                                      )),
                                                ),
                                                Card(
                                                  child: ListTile(
                                                    leading: const Icon(
                                                        Icons.forward),
                                                    title: const Text(
                                                        "NO2 Level:"),
                                                    subtitle: Text(
                                                        weatherInfo["no2_val"] +
                                                            "μg/m3"),
                                                    trailing: Text(
                                                      no2check,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c3),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  child: ListTile(
                                                    leading: const Icon(
                                                        Icons.forward),
                                                    title:
                                                        const Text("O3 Level:"),
                                                    subtitle: Text(
                                                        weatherInfo["o3_val"] +
                                                            "μg/m3"),
                                                    trailing: Text(
                                                      o3check,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c4),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                    child: ListTile(
                                                  leading:
                                                      const Icon(Icons.forward),
                                                  title:
                                                      const Text("SO2 Level:"),
                                                  subtitle: Text(
                                                      weatherInfo["so2_val"] +
                                                          "μg/m3"),
                                                  trailing: double.parse(
                                                              weatherInfo[
                                                                  "so2_val"]) <
                                                          100
                                                      ? const Text(
                                                          "Good",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.green),
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
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(
                                                Icons.close,
                                                size: 17,
                                              ),
                                              label: const Text("Close"))
                                        ],
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                          "Sorry Could not fetch the data!!"),
                                    );
                            });
                      },
                      child: const Text(
                        "AQI",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 40),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blueGrey[700],
                      heroTag:
                          "bt2", //if we use multiple floating action button then we have to use this tag to differentite both
                      onPressed: () {
                        if (weatherInfo["temperature_val"].toString() != "NA") {
                          if (!isFav) {
                            Provider.of<Data>(context, listen: false)
                                .addFavCity(
                              weatherInfo["cityName_val"],
                            ); //temp store nhi kara rahe ab
                            // weatherInfo[
                            //     "temperature_val"]); //storing the temp along with city too now so using a map

                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Added To Favourites!!")));
                          } else {
                            Provider.of<Data>(context, listen: false).removeFavCity(
                                weatherInfo["cityName_val"],
                                -1); //here we dont need index as..the content of file FavCitiesTemp only gets creted when we click on the fav cities button..so clicking here on start button then we only have to remove the fav city from the data base not from that list s=as it is empy now...but we need  remve from it when we click on rash button inside the fav screen as we then have content in the list and have them reflected there..but here we dont need to do anything with the favcitiesTemp list as it only gets content when the fav cities button gets clicked
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Removed From Favourites!!")));
                          }
                          setState(() {
                            isFav = !isFav;
                          });
                        } else //cant set thisto favurie if this place is not in api
                        {
                          null;
                        }
                      },
                      child: !isFav
                          ? const Icon(
                              Icons.star_border_outlined,
                              color: Colors.orange,
                            )
                          : const Icon(
                              Icons.star_outlined,
                              color: Colors.orange,
                            ),
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
                    Text(
                      "Made By Abhay",
                      style: TextStyle(color: Colors.white54),
                    ),
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
