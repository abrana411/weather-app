//below is the data that we need from the weather api ..ie it is the information about the weather so created a class for that
import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import './db_manager.dart';

class Data extends ChangeNotifier {
  String location = "";
  String temperature = "";
  String feelslike = "";
  String humidity = "";
  String windSpeed = "";
  String typeOfweather = "";
  String iconWeather = "";
  String longitude = "";
  String latitude = "";
  var forcastMin = [];
  var forcastMax = [];
  var forcastType = [];
  var forcastIcon = [];
  String pm2 = "";
  String pm10 = "";
  String no2 = "";
  String o3 = "";
  String so2 = "";
  String moonrise = "";
  String moonset = "";
  String sunrise = "";
  String sunset = "";
  // ignore: non_constant_identifier_names
  var HourlyForcastTime = [];
  // ignore: non_constant_identifier_names
  var HourlyForcastTemp = [];
  // ignore: non_constant_identifier_names
  var HourlyForcastLogo = [];
  Data({required this.location});

  Future<void> getData() async {
    try {
      final res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=0845098f21354236ac51412680d05df7"));
      Map data = json.decode(res
          .body); //converting the json data to map so that we can target the keys accordingly
      temperature = (data["main"]["temp"] - 273.15)
          .toString(); //-273.15 to convert kelvin to celsius
      feelslike = (data["main"]["feels_like"] - 273.15).toString();
      humidity = data["main"]["humidity"].toString(); //in percentage %
      windSpeed = (data["wind"]["speed"] * 18 / 5)
          .toString(); //in m/s so changed it into km/hr
      typeOfweather = data["weather"][0]["main"];
      iconWeather = data["weather"][0]["icon"];
      longitude = data["coord"]["lon"].toString();
      latitude = data["coord"]["lat"].toString();
    } catch (err) {
      //print(err);
      temperature = "NA";
      humidity = "NA";
      windSpeed = "NA";
      typeOfweather = "NA";
      longitude = "NA";
      latitude = "NA";
      iconWeather = "09d";
    }
  }

  Future<void> getForcast() async {
    var url1 =
        "https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&exclude=minutely&appid=b4029e59bdf0e4627acfa8a7e6be66ef";
    try {
      final res1 = await get(Uri.parse(url1));
      Map data1 = json.decode(res1.body);
      for (int i = 0; i < 24; i++) {
        var timeSinceEpoch = data1["hourly"][i]["dt"];
        var time = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(
            timeSinceEpoch * 1000)); //will give hour
        var temp = (data1["hourly"][i]["temp"] - 273.15).toString();
        var logo = data1["hourly"][i]["weather"][0]["icon"];

        HourlyForcastTemp.add(temp);
        HourlyForcastLogo.add(logo);
        HourlyForcastTime.add(time);
      }
      for (int i = 0; i <= 7; i++) {
        forcastMin.add((data1["daily"][i]["temp"]["min"] - 273.15).toString());
        forcastMax.add((data1["daily"][i]["temp"]["max"] - 273.15).toString());
        forcastType.add(data1["daily"][i]["weather"][0]["description"]);
        forcastIcon.add(data1["daily"][i]["weather"][0]["icon"]);
      }
      moonrise = data1["daily"][0]["moonrise"].toString(); //aaj ka moonrise
      moonset = data1["daily"][0]["moonset"].toString();
      sunrise = data1["daily"][0]["sunrise"].toString();
      sunset = data1["daily"][0]["sunset"].toString();
      // print(data["daily"][0]["weather"][0]["description"]);
      // print(data["daily"][0]["weather"][0]["icon"]);

      notifyListeners();
    } catch (err) {
      // print(err);
    }
  }

  Future<void> getAQI() async {
    try {
      final res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=b4029e59bdf0e4627acfa8a7e6be66ef"));
      Map data = json.decode(res.body);
      pm2 = data["list"][0]["components"]["pm2_5"].toString();
      pm10 = data["list"][0]["components"]["pm10"].toString();
      o3 = data["list"][0]["components"]["o3"].toString();
      so2 = data["list"][0]["components"]["so2"].toString();
      no2 = data["list"][0]["components"]["no2"].toString();
      // print(Pm2);
    } catch (err) {
      // print(err);
    }
  }

  // ignore: non_constant_identifier_names, prefer_final_fields
  // Map<String, String> _FavCities =
  //     {}; //here i dont even need this to be a map now..as i dont need temp..and only need city name so will change it later
  // // ignore: non_constant_identifier_names
  // Map<String, String> get Fav {
  //   return {
  //     ..._FavCities //returning the copy of the _Favcities list so that can use the copy where ever we want in any of the widgets
  //   };
  // }
  List<String>
      // ignore: non_constant_identifier_names, prefer_final_fields
      _FavCities = //now i dont have a need to store the temp so creating list now instead of a map
      [];
  // ignore: non_constant_identifier_names
  List<String> get Fav {
    return [..._FavCities];
  }

  // ignore: non_constant_identifier_names, prefer_final_fields
  List<String> _SuggesedCity = [];
  List<String> get suggestCity {
    return [..._SuggesedCity];
  }

  bool doesContain(String city) {
    // if (_FavCities.containsKey(city)) {
    //   return true;
    // }

    if (_FavCities.contains(city)) {
      //since favcities is list now so the method changes to test the presence
      return true;
    }
    return false;
  }

  void addFavCity(String city) {
    // if (_FavCities.containsKey(city)) {
    //   return;
    // }
    if (_FavCities.contains(city)) {
      return;
    }
    // _FavCities.putIfAbsent(
    //     city,
    //     () =>
    //         temp); //if city is not currently in the Map of fav cities then we will add that in there otherwise we will just return from the method without doing any thing

    //print("hello");
    _FavCities.add(
        city); //adding th city in list if it is not there..note now method changes since dont need temp to be stored now
    //print(_FavCities);
    notifyListeners();
    DbManage.insertInDataBase("Places", {
      //giving vales for each row of 2 columns in table places ...to insert
      "city": city,
      // "temp": temp  //dont have temp column now in the table
    });
  }

  void removeFavCity(String city, int index) {
    // if (_FavCities.containsKey(city)) {
    if (_FavCities.contains(city)) {
      //for favcities when its a list
      //("hello2");
      _FavCities.remove(city);
      //print(_FavCities);
      if (index !=
          -1) //-1 tabhi hoga jab star pe click krke chala rahe ho isko...to tab hame delete nhi karna favcitiestemp list se...tab o bs favcities list or data base se karna h
      {
        _FavCitiesTemp.removeAt(
            index); //removing he temperature f the city that got deleted
      }
      notifyListeners();
      DbManage.removeFromdbCiy(city, "Places");
    }
  }

  // ignore: non_constant_identifier_names
  void AddAndRemoveSuggest(String newSuggest) {
    //  if (_SuggesedCity.contains(newSuggest) || newSuggest.isEmpty) {
    //    return; //agar pehle se he h  kuch nhi karna
    //  }
    if (newSuggest.isEmpty) {
      return;
    }
    if (_SuggesedCity.contains(
        newSuggest)) //agar pehle se bhi hua to bhi add kr denge niche vala remove krke..matlab dusre vala remove krke
    {
      int toremove = _SuggesedCity.lastIndexOf(newSuggest);
      String toremovename = _SuggesedCity[toremove];
      DbManage.removeFromdbSuggest(toremovename,
          "Suggestions"); //purana jha tha usse remove krke add kr denge...dbara isi k aki ab jab fetch kare data loading ke time to suggesed lis me pe aaye
      DbManage.insertInDataBase("Suggestions", {
        "suggestion": newSuggest.trim(),
      });
      return;
    }

    if (_SuggesedCity.length >
        15) //15 se jada ho gayi  last ko remove krenge or fir add krenge new
    {
      String toremove = _SuggesedCity[_SuggesedCity.length - 1]; //last value
      DbManage.removeFromdbSuggest(toremove, "Suggestions");
    }

    //add to hamesha karna he h
    // _SuggesedCity.insert(  //isme add krne ki jarurat he nhi kunki ..jaise he search krenge to fech dobara chalega r vaha se hamehsha dobara list me data jayega ..to isme aha add krne ki jarura nhi..kunki har bar add ya remve hne pe loading ke time fetch ho jayega
    //     0,
    //     newSuggest
    //         .trim()); //saring me new add krenge ...agar normal add use krenge to end me add ho jayega vo..trim krke add krenge
    // _SuggesedCity.add(newSuggest);
    notifyListeners();
    // print(_SuggesedCity);
    DbManage.insertInDataBase("Suggestions", {
      "suggestion": newSuggest.trim(),
    });
  }

  Future<void> fetchAndSetDataFromDb() async {
    _FavCities.clear(); //It was causing troubles...as
    _SuggesedCity.clear();
    final dataList = await DbManage.fetchDataFromDb(
        "places"); //as we are always sending the data to the Places table in data base so retrieving the data from that table only
    //the data list here will now be a list having each index as a map having data of each row of the table places from data base like [{city : delhi , temp : 12},{},{}....] like this
    for (int i = 0; i < dataList.length; i++) {
      // _FavCities.putIfAbsent(
      //     dataList[i]["city"],
      //     () => dataList[i][
      //         "temp"]); //dont need temp now though...as we only need name of the city

      //no need of temp now...so i will use a list to store city instead of a map
      _FavCities.add(dataList[i]["city"]); //adding simply the city in the list
    }

    final dataSuggest = await DbManage.fetchDataFromDb("Suggestions");
    for (int i = 0; i < dataSuggest.length; i++) {
      // _SuggesedCity.add(dataSuggest[i]
      //     ["suggestion"]); //adding simply the suggestion place in the list
      _SuggesedCity.insert(0,
          dataSuggest[i]["suggestion"]); //har element starting me islie insert
    }
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
  final List<String> _FavCitiesTemp =
      []; //creating list that will hold the temperatures for the fav cities
  // ignore: non_constant_identifier_names
  List<String> get FavCitiesTemp {
    return [..._FavCitiesTemp];
  }

  Future<void> getFavCitiesTemp(List<String> cities) async {
    _FavCitiesTemp.clear();
    try {
      for (var element in cities) {
        final res = await get(Uri.parse(
            "https://api.openweathermap.org/data/2.5/weather?q=$element&appid=0845098f21354236ac51412680d05df7"));
        Map data = json.decode(res.body);
        String t = (data["main"]["temp"] - 273.15).toString();
        _FavCitiesTemp.add(
            t); //adding the temp afetr getting it for each fav city
      }

      notifyListeners();
    } catch (err) {
      // print(err);
    }
  }
}
