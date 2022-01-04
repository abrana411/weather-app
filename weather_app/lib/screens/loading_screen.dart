import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../screens/home_scr.dart';
import '../helper/data_fetcher.dart';

class Loading extends StatefulWidget {
  static const routeName = "/loading";

  const Loading({Key? key}) : super(key: key);
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  var city = "Delhi"; //initially jab app start hogi to delhi he rakhenge
  void fetchData(String cityName) async {
    Data instance = Data(location: city);
    await instance.getData();
    await instance.getForcast();
    await instance.getAQI();
    Future.delayed(
        const Duration(seconds: 3),
        () => {
              //intentionally delaying the navigation to home page so that we can see the loading page for at least 3 seconds
              Navigator.pushReplacementNamed(context, HomeScreen.routeName,
                  arguments: {
                    //this is not a good way to pass data around...rather i should use provider (ie by making the Data class a provider to access its data anywhere)
                    "temperature_val": instance.temperature,
                    "humidity_val": instance.humidity,
                    "windSpeed_val": instance.windSpeed,
                    "typeOfweather_val": instance.typeOfweather,
                    "iconWeather_val": instance.iconWeather,
                    "cityName_val": cityName,
                    "forcastMax_val": instance
                        .forcastMax, //if dont want to do it by provider that conventional method of passing like this can always be used
                    "forcastMin_val": instance.forcastMin,
                    "forcastType_val": instance.forcastType,
                    "forcastIcon_val": instance.forcastIcon,
                    "pm2_val": instance.Pm2,
                    "pm10_val": instance.Pm10,
                    "o3_val": instance.o3,
                    "so2_val": instance.so2,
                    "no2_val": instance.no2,
                  })
            });
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    Map searchInfo = {};
    if (ModalRoute.of(context)!.settings.arguments != null) {
      searchInfo = ModalRoute.of(context)!.settings.arguments as Map;
    }
    if (searchInfo.isNotEmpty) {
      city = searchInfo["SearchedText"];
    }
    fetchData(city);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/images/Logo.png",
            fit: BoxFit.cover,
            width: 215,
            height: 200,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "VataVaran App",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Created By Abhay Rana",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red),
          ),
          const SizedBox(
            height: 50,
          ),
          const SpinKitPouringHourGlassRefined(
            color: Colors.black,
            size: 50.0,
          ),
        ]),
      ),
    );
  }
}
