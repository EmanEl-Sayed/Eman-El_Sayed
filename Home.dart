import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dropdown_search/dropdown_search.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String locationMessage = "The site is not available";
  String? selectedTitle;
  List<String> dropdownItems = [];

  Future<List<String>> getdata() async {
    var response =
        await get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    var responseBody = jsonDecode(response.body);

    return responseBody
        .map<String>((item) => item['title'].toString())
        .toList();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are not activated";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Site permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Location permission has been permanently denied";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" To Try", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: Text("Locate me"),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(locationMessage, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FutureBuilder<List<String>>(
              future: getdata(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(labelText: "Search"),
                    ),
                  ),
                  items: snapshot.data!,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Choose a title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedTitle = value;
                    });
                  },
                  selectedItem: selectedTitle,
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: getdata(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(snapshot.data![i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
