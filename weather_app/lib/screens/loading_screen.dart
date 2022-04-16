import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../screens/home_scr.dart';
import '../helper/data_fetcher.dart';

class Loading extends StatefulWidget {
  static const routeName = "/loading";

  const Loading({Key? key}) : super(key: key);
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool isFirst = true;
  Position mylocation = Position(
      longitude: 0.0,
      latitude: 0.0,
      timestamp: DateTime(2002),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  var city = "Delhi"; //initially jab app start hogi to delhi he rakhenge
  void fetchData(String cityName) async {
    await Provider.of<Data>(context,
            listen:
                false) //jaise he kuch search krta to loading scree chalti or yaha dobara data fetch hota to isliye...jo ye method h data fetcher me..usme pehle jo tha _Favcities me usse clear karna jaruri h
        .fetchAndSetDataFromDb(); //taki home.dart me harame pass jo favki list ho usme updated ho sab kuch jisse ham isFav check kr rahe h
    Data instance = Data(location: city);
    await instance.getData(mylocation.longitude, mylocation.latitude);
    await instance.getForcast();
    await instance.getAQI();
    // await instance.getHourlyForcast();
    // Future.delayed(
    //     const Duration(seconds: 1),
    //     () => {
    //intentionally delaying the navigation to home page so that we can see the loading page for at least 3 seconds
    Navigator.pushReplacementNamed(context, HomeScreen.routeName, arguments: {
      //this is not a good way to pass data around...rather i should use provider (ie by making the Data class a provider to access its data anywhere)
      "temperature_val": instance.temperature,
      "feelsLike_val": instance.feelslike,
      "humidity_val": instance.humidity,
      "windSpeed_val": instance.windSpeed,
      "windDirection_val": instance.windDirection,
      "typeOfweather_val": instance.typeOfweather,
      "iconWeather_val": instance.iconWeather,
      "CCode_val": instance.Countrycode,
      "cityName_val": isFirst ? instance.cityName : city,
      "forcastMax_val": instance
          .forcastMax, //if dont want to do it by provider that conventional method of passing like this can always be used
      "forcastMin_val": instance.forcastMin,
      "forcastType_val": instance.forcastType,
      "forcastIcon_val": instance.forcastIcon,
      "pm2_val": instance.pm2,
      "pm10_val": instance.pm10,
      "o3_val": instance.o3,
      "so2_val": instance.so2,
      "no2_val": instance.no2,
      "moonrise_val": instance.moonrise,
      "moonset_val": instance.moonset,
      "sunrise_val": instance.sunrise,
      "sunset_val": instance.sunset,
      "hourlytime_val": instance.HourlyForcastTime,
      "hourlytemp_val": instance.HourlyForcastTemp,
      "hourlylogo_val": instance.HourlyForcastLogo
    });
    //});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled; //to store if the servicese are provided or not
    LocationPermission permission; //to give permission related actions

    serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); //if the location service is enabled for this app then i will get it here..we have to do these in the build.gradle

    if (!serviceEnabled) {
      //if not then i will show an error
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator
        .checkPermission(); //checking if permisiion for location is given or not

    if (permission == LocationPermission.denied) {
      //if user denies the permisiion then i will request for the permisioon again
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        //if denied i can show error but in this case will....just return position with 0 lati and longitude
        // return Future.error("Location permission denied");
        return Position(
            longitude: 0.0,
            latitude: 0.0,
            timestamp: DateTime(2002),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //if denied forever then i will give error saying locations are permanently denied
      // return Future.error('Location permissions are permanently denied');
      return Position(
          longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime(2002),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    }

    Position position = await Geolocator
        .getCurrentPosition(); //otherwise if permisiion and location services are enabled then i will get the position using the geolocator package

    return position; //and will return the position
  }

  void getMYLocation() async {
    //print("Yo bro");
    mylocation =
        await _determinePosition(); //below statement will wait till this location will come
    fetchData(city);
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
      city = searchInfo["Text"];
      isFirst = searchInfo["isfirst"];
    }

    if (isFirst) {
      getMYLocation();
    } else {
      fetchData(city);
    }
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
