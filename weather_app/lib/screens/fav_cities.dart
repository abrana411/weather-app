import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../helper/data_fetcher.dart';
import '../screens/loading_screen.dart';

class Favcities extends StatefulWidget {
  static const routeName = "/fav";
  // ignore: non_constant_identifier_names
  final String Currentcity;
  final List<String> favCities;
  const Favcities(
      // ignore: non_constant_identifier_names
      {Key? key,
      // ignore: non_constant_identifier_names
      required this.Currentcity,
      required this.favCities})
      : super(key: key);

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
  var _hasInitialized = false;
  var _isLoading = true;

  @override
  void didChangeDependencies() {
    if (_hasInitialized == false) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(Duration.zero, () async {
        //was throwing an error otherwise..this will delay some time in starting
        Provider.of<Data>(context, listen: false)
            .getFavCitiesTemp(widget.favCities)
            .then((_) {
          //the listening is done in the consumer belwo..if done here too then it will keep on going on...in a loop
          setState(() {
            _isLoading = false;
          });
        });
      });
    }
    _hasInitialized = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // Map currentCity = ModalRoute.of(context)!.settings.arguments
    //     as Map; //getting current city from home to go back to it
    //if (!_isLoading) {
    // var Tempdata=Provider.of<Data>(context, listen: false).FavCitiesTemp;
    //}
    return Scaffold(
        extendBodyBehindAppBar:
            true, //this make the content of body behind appbar too..and making it true as want to show rounded brder in appbar so...have to make color behind appbar same with body i will exend body from top itself

        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Loading.routeName,
                      arguments: {
                        "Text": widget.Currentcity,
                        "isfirst": false
                      });
                },
                icon: const Icon(Icons.arrow_back_ios_new_outlined));
          }),
          title: Title(color: Colors.black, child: const Text("Favourites")),
          centerTitle: true, //will make title appear on center
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: Container(
            //to give gradient we can use flexible
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                gradient: LinearGradient(
                  colors: [Colors.black45, Colors.green],
                )),
          ),
        ),
        body:
            // FutureBuilder(
            //     future: Provider.of<Data>(context,
            //             listen:
            //                 false) //not listening here as the notify listener inside this will make the below consumer listen itself and if i listen here then the fetch data will keep on running and running in a loop
            //         .fetchAndSetDataFromDb(), //since this returns a future so using this in future builder to fetch the data from our data bse...and once we have out _places list updated with the data..from databse(helpful when we closed the app and _places is empty initially so we will fetch the data which was there when the app was perviously working so fetching that data)
            //     builder: (ctx, datasnapshot) => datasnapshot.connectionState ==
            //             ConnectionState.waiting
            //         ? const Center(
            //             child:
            //                 CircularProgressIndicator(), //showing loading indiator until gets the data and once i get it then showing the list of places via listView builder
            //           )
            //         :
            _isLoading
                ? const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 50.0,
                    ),
                  )
                : Consumer<Data>(
                    child: Stack(children: [
                      Container(
                          color: Colors.black87,
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
                    // builder: (ctx, FavData, ch) => FavData.Fav.isEmpty
                    // ignore: non_constant_identifier_names
                    builder: (ctx, FavData, ch) => FavData.FavCitiesTemp.isEmpty
                        ? ch! //if no places are there then show that child ....have to do ch! for null safety
                        : SingleChildScrollView(
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                  gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.green],
                                      begin: Alignment.topRight,
                                      end: Alignment.topLeft)),
                              child: Column(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 100),
                                      child: Image.asset(
                                        "assets/images/starlogo1.png",
                                        width: 130,
                                        height: 130,
                                      )),
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    width: screenSize.width,
                                    // decoration: BoxDecoration(
                                    //     //color: Colors.orange,
                                    //     gradient: LinearGradient(
                                    //       begin: Alignment.topLeft,
                                    //       end: Alignment.bottomRight,
                                    //       // stops: [0.1, 0.9], //this means 0 to 10 % blue color then 10 to 90 % transition from blue to transparent and 90 to 100 % transparent
                                    //       colors: [
                                    //         Colors.orange.shade400,
                                    //         Colors.red.shade300
                                    //       ],
                                    //     ),
                                    //     // border: Border(
                                    //     //     right: BorderSide(
                                    //     //         width: 5, color: Colors.orange),
                                    //     //     left: BorderSide(
                                    //     //         width: 5, color: Colors.orange),
                                    //     //     bottom: BorderSide(
                                    //     //         width: 5, color: Colors.orange))
                                    //     border: Border.all(
                                    //       width: 3,
                                    //       color: Colors.pink,
                                    //     )),
                                    child: ListView.builder(
                                      padding: EdgeInsets
                                          .zero, //default padding hat jayegi list view ki
                                      itemBuilder: (ctx, index) {
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          margin:
                                              const EdgeInsets.only(bottom: 5),
                                          color: Colors.black,
                                          child: ListTile(
                                            title: Text(
                                              // FavData.Fav.entries
                                              //     .toList()[index]
                                              //     .key,
                                              FavData.Fav[
                                                  index], //simply now as Fav gives us list having city names only now
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            trailing: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                        width: 2,
                                                        color: Colors.white)),
                                              ),
                                              width: screenSize.width * 0.45,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    double.parse(FavData
                                                                    .FavCitiesTemp[
                                                                index])
                                                            .toStringAsFixed(
                                                                1) //to show 1 value after decimal point only
                                                            .toString() +
                                                        "°c",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Provider.of<Data>(context,
                                                              listen: false)
                                                          .removeFavCity(
                                                              // FavData.Fav.entries
                                                              //     .toList()[index]
                                                              //     .key,
                                                              FavData
                                                                  .Fav[index],
                                                              index); //passing the index too..as we want this index to be removed from the favCitiesTemp list too in the data fetcher file
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red[400],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context,
                                                              Loading.routeName,
                                                              arguments: {
                                                            // "Text": FavData
                                                            //     .Fav.entries
                                                            //     .toList()[index]
                                                            //     .key
                                                            "Text": FavData.Fav[
                                                                index], //as Fav gives us list of city names only and not the temp
                                                            "isfirst": false
                                                          });
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .double_arrow_rounded,
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
                            ),
                          ),
                  ));
  }
}
