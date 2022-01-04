//below is the data that we need from the weather api ..ie it is the information about the weather so created a class for that
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

class Data extends ChangeNotifier {
  String location = "";
  String temperature = "";
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
  String Pm2 = "";
  String Pm10 = "";
  String no2 = "";
  String o3 = "";
  String so2 = "";
  Data({required this.location});

  Future<void> getData() async {
    try {
      final res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=0845098f21354236ac51412680d05df7"));
      Map data = json.decode(res
          .body); //converting the json data to map so that we can target the keys accordingly
      temperature = (data["main"]["temp"] - 273.15)
          .toString(); //-273.15 to convert kelvin to celsius
      humidity = data["main"]["humidity"].toString(); //in percentage %
      windSpeed = (data["wind"]["speed"] * 18 / 5)
          .toString(); //in m/s so changed it into km/hr
      typeOfweather = data["weather"][0]["main"];
      iconWeather = data["weather"][0]["icon"];
      longitude = data["coord"]["lon"].toString();
      latitude = data["coord"]["lat"].toString();
      notifyListeners();
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
      for (int i = 0; i <= 6; i++) {
        forcastMin.add((data["daily"][i]["temp"]["min"] - 273.15).toString());
        forcastMax.add((data["daily"][i]["temp"]["max"] - 273.15).toString());
        forcastType.add(data["daily"][i]["weather"][0]["description"]);
        forcastIcon.add(data["daily"][i]["weather"][0]["icon"]);
      }
      // print(data["daily"][0]["weather"][0]["description"]);
      // print(data["daily"][0]["weather"][0]["icon"]);
      notifyListeners();
    } catch (err) {
      print(err);
    }
  }

  Future<void> getAQI() async {
    try {
      final res = await get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=b4029e59bdf0e4627acfa8a7e6be66ef"));
      Map data = json.decode(res.body);
      Pm2 = data["list"][0]["components"]["pm2_5"].toString();
      Pm10 = data["list"][0]["components"]["pm10"].toString();
      o3 = data["list"][0]["components"]["o3"].toString();
      so2 = data["list"][0]["components"]["so2"].toString();
      no2 = data["list"][0]["components"]["no2"].toString();
      print(Pm2);
    } catch (err) {
      print(err);
    }
  }
}
