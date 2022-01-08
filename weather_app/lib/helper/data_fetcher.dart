//below is the data that we need from the weather api ..ie it is the information about the weather so created a class for that
import 'dart:convert';
import 'package:http/http.dart';
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
    try {
      final res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&exclude=hourly,minutely&appid=b4029e59bdf0e4627acfa8a7e6be66ef"));
      Map data = json.decode(res.body);
      for (int i = 0; i <= 7; i++) {
        forcastMin.add((data["daily"][i]["temp"]["min"] - 273.15).toString());
        forcastMax.add((data["daily"][i]["temp"]["max"] - 273.15).toString());
        forcastType.add(data["daily"][i]["weather"][0]["description"]);
        forcastIcon.add(data["daily"][i]["weather"][0]["icon"]);
      }
      moonrise = data["daily"][0]["moonrise"].toString(); //aaj ka moonrise
      moonset = data["daily"][0]["moonset"].toString();
      sunrise = data["daily"][0]["sunrise"].toString();
      sunset = data["daily"][0]["sunset"].toString();
      // print(data["daily"][0]["weather"][0]["description"]);
      // print(data["daily"][0]["weather"][0]["icon"]);
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
  Map<String, String> _FavCities = {};
  // ignore: non_constant_identifier_names
  Map<String, String> get Fav {
    return {
      ..._FavCities //returning the copy of the _Favcities list so that can use the copy where ever we want in any of the widgets
    };
  }

  bool doesContain(String city) {
    if (_FavCities.containsKey(city)) {
      return true;
    }
    return false;
  }

  void addFavCity(String city, String temp) {
    if (_FavCities.containsKey(city)) {
      return;
    }
    _FavCities.putIfAbsent(
        city,
        () =>
            temp); //if city is not currently in the Map of fav cities then we will add that in there otherwise we will just return from the method without doing any thing
    notifyListeners();
    DbManage.insertInDataBase("Places", {
      //giving vales for each row of 2 columns in table places ...to insert
      "city": city,
      "temp": temp
    });
  }

  void removeFavCity(String city) {
    if (_FavCities.containsKey(city)) {
      _FavCities.remove(city);
      notifyListeners();
      DbManage.removeFromdb(city, "Places");
    }
  }

  Future<void> fetchAndSetDataFromDb() async {
    final dataList = await DbManage.fetchDataFromDb(
        "places"); //as we are always sending the data to the Places table in data base so retrieving the data from that table only
    //the data list here will now be a list having each index as a map having data of each row of the table places from data base like [{city : delhi , temp : 12},{},{}....] like this
    for (int i = 0; i < dataList.length; i++) {
      _FavCities.putIfAbsent(dataList[i]["city"], () => dataList[i]["temp"]);
    }
    // _places = dataList;
    // print(dataList);
    notifyListeners();
  }
}
