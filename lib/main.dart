/*
 * File:   main.dart
 * Author: Rakul R Sampath
 *
 * Created on 07 June 2020, 17:25
 *
 * Flutter application to display temperature and to control LED
 */

import 'dart:async'; //asynchronous task
import 'dart:convert'; //conversion of data format
import 'dart:io';
import 'package:flutter/material.dart'; //contains flutter widget to implement material widgets and material theme widgets
import 'package:http/http.dart'
    as http; //contains functionality and classes to access http
import 'package:intl/intl.dart'; //provides internationalization and localization facilities including date and time formatting

void main() {
  //main function
  runApp(
      MyApp()); //function that takes any widget as an argument and created a layout which fills the screen
}

/*
* Extending a StatelessWidget class requires override the build method
* Build method takes content and returns widget
* context is a BuildContext instance which gets passed to the builder of a widget
*/

class MyApp extends StatelessWidget {
  //root widget of our application
  @override
  Widget build(BuildContext context) {
    //to find the location of the widget inside the Widget Tree of the app
    return MaterialApp(
      //returns a class that make use of developing theme for the app
      home: MyHomePage(),
    );
  }
}

/*
* Part of UI changes dynamically so we are extending StatefulWidget class
* i.e, we are using Material app and for some UI changes requirements we extend widget class
*/

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() =>
      _MyHomePageState(); //widget class has a createState() method that returns the State
}

/*
* State class holds the variables and tells the StatefulWidget class when and how to build itself
* GlobalKey ensures that the key is unique across the whole application
* This key provide access to other objects that are associated with BuildContext. StatefulWidgets and a State
*/

class _MyHomePageState extends State<MyHomePage> {
  final String url = "http://3.17.60.171/";
  List<String> data;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<
      ScaffoldState>(); //create a Global key instance and assign it to the Scaffold Widget
  String currentTemp = ''; //temperature value initializing
  String _timeString; //declaring time

  @override
  void initState() {
    // method that do not return value and called first
    super.initState();
    // forwards to the default implementation of the State class of your widget.
    _timeString = _formatDateTime(DateTime.now());
    // current date time format is assigned to a variable
    this.data = [];
    Timer.periodic(
        Duration(minutes: 1),
        (Timer t) =>
            _getTime()); // time duration updation should be performed using this function
  }

  Future getJsonData() async {
    var response = await http.get(Uri.encodeFull(url),
        //only accepts json response
        headers: {"Accept": "application/json"});
    print(response.body);
    List<String> newData =
        response.body.toString().trim().toString().split(",");
    List<String> tempData = [];
    for (String s in newData) {
      s = s.replaceAll("[", "").trim();
      s = s.replaceAll("\'", "").trim();
      s = s.replaceAll("{", "").trim();
      s = s.replaceAll("}", "").trim();
      s = s.replaceAll("]", "").trim();
      s = s.replaceAll("each_vehicele:", "").trim();
      s = s.replaceAll("Total_Vehicle :", "").trim();
      s = s.replaceAll("Waiting time:", "").trim();
      print(s);
      tempData.add(s);
    }
    data = tempData;
  }

  /*
  * build method is called to build the widget whenever the State object is changed
  * */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //returns Scaffold widgets
      key: _scaffoldKey, //mentioning unique key for this scaffold
      body: Center(
        //aligning all the widget to the center position
        child: Container(
          //container widget
          height: double.maxFinite, //maximum height the widget can be stretched
          width: double.maxFinite, //maximum width the widget can be stretched
          decoration: BoxDecoration(
            //decoration shape of the widget
            image: DecorationImage(
              //decoration for the image widget
              image: AssetImage("images/background.jpg"),
              fit: BoxFit.cover, //fits the widget
            ),
          ),
          child: Column(
            //widget alignment should be in vertical
            mainAxisAlignment: MainAxisAlignment.center, //main axis alignment
            children: [
              Icon(
                //assigning icon to the widget
                Icons.timer, //icon type
                color: Colors.white, //icon color
                size: 50.0, //icon size
              ),
              //sub widget of Column widget
              Text(
                _timeString, //time value assign
                textAlign: TextAlign.center, //text alignment of time
                style: TextStyle(
                    //text style
                    color: Colors.black, //font color
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold
                    //font size
                    ),
              ),
              SizedBox(
                  height:
                      50.0), //spacing between first widget to the next widget
              Text(
                currentTemp == ''
                    ? ''
                    : 'Temperature is $currentTemp °C', //displaying temperature in text
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                //assigning icon to the widget
                Icons.time_to_leave, //icon type
                color: Colors.white, //icon color
                size: 50.0, //icon size
              ),
              SizedBox(height: 20.0),
              Container(
                child: data.length == 0
                    ? Text("")
                    : Column(
                        children: <Widget>[
                          Text(
                            "Average waiting time of X traffic signal",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            data[0].substring(0, 3) + " min",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                            child: Divider(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Total No. of vehicle already standing",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(data[1],
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
              ),
              //Text(data),
              RaisedButton(
                  //adding button widget
                  shape: RoundedRectangleBorder(
                    //button shape
                    borderRadius:
                        BorderRadius.circular(20.0), //button border radius
                  ),
                  color: Colors.redAccent.shade100, //button color
                  child: Text(
                    'Click to view',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    //button event and async function
                    try {
                      setState(() {
                        this.getJsonData();
                      });
                    } catch (exception) {
                      //handles exception and display error at snackbar(bottom of the app)
                      _scaffoldKey.currentState.showSnackBar(
                          SnackBar(content: Text(exception.toString())));
                    }
                  }),
              //   SizedBox(height: 10.0),
              //   Icon(
              //     Icons.flash_on,
              //     color: Colors.white,
              //     size: 50.0,
              //   ),
              //   RaisedButton(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //     color: Colors.redAccent.shade100,
              //     child: Text(
              //       'LED ON',
              //       style: TextStyle(
              //         color: Colors.white,
              //       ),
              //     ),
              //     onPressed: () async {
              //       try {
              //         http.Response ledOn = await http.get(
              //             'http://node-red-obgco.eu-gb.mybluemix.net/led-on');
              //       } catch (exception) {
              //         _scaffoldKey.currentState.showSnackBar(
              //             SnackBar(content: Text(exception.toString())));
              //       }
              //     },
              //   ),
              //   SizedBox(height: 10.0),
              //   Icon(
              //     Icons.flash_off,
              //     color: Colors.white,
              //     size: 50.0,
              //   ),
              //   RaisedButton(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //     color: Colors.redAccent.shade100,
              //     child: Text(
              //       'LED OFF',
              //       style: TextStyle(
              //         color: Colors.white,
              //       ),
              //     ),
              //     onPressed: () async {
              //       try {
              //         http.Response ledOff = await http.get(
              //             'http://node-red-obgco.eu-gb.mybluemix.net/led-off');
              //       } catch (exception) {
              //         _scaffoldKey.currentState.showSnackBar(
              //             SnackBar(content: Text(exception.toString())));
              //       }
              //     },
              //   ),
              //
            ],
          ),
        ),
      ),
    );
  }

/*
* _getTime function to display the current time
*/
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

/*
* _formatDateTime function to display the current time in a format
 */
  String _formatDateTime(DateTime dateTime) {
    return (DateFormat('h:mm a').format(dateTime) +
        '\n' +
        DateFormat('EEE, MMM d, yyyy').format(dateTime));
  }
}
