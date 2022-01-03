//below is the data that we need from the weather api ..ie it is the information about the weather so created a class for that
import 'dart:convert';
import 'package:http/http.dart';

class Data {
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
    } catch (err) {
      print(err);
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
      for (int i = 0; i < 6; i++) {
        forcastMin[i] = data["daily"][i]["temp"]["min"];
        forcastMax[i] = data["daily"][i]["temp"]["max"];
        forcastType[i] = data["daily"][i]["weather"]["description"];
        forcastIcon[i] = data["daily"][i]["weather"]["icon"];
      }
    } catch (err) {
      print(err);
    }
  }
}
