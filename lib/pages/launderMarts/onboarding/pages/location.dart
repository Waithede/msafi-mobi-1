import 'dart:async';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:msafi_mobi/providers/map.provider.dart';
import 'package:msafi_mobi/providers/mart.provider.dart';
import 'package:msafi_mobi/services/map.services.dart';
import 'package:provider/provider.dart';

class PickUpspotsSelection extends StatefulWidget {
  const PickUpspotsSelection({Key? key}) : super(key: key);

  @override
  State<PickUpspotsSelection> createState() => _PickUpspotsSelectiontate();
}

class _PickUpspotsSelectiontate extends State<PickUpspotsSelection> {
  Completer<GoogleMapController> _controller = Completer();

// toggle UI components we need
  bool searchToggle = false;
  bool radiusSlider = false;
  bool pressedNear = false;
  bool cardTapped = false;
  bool getDirection = false;

//  places url
  static const placesUrl =
      "https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters";

  // inputcontroller
  TextEditingController searchController = TextEditingController();

  // throttle async calls
  Timer? _debounce;

  // markers set
  Set<Marker> _markers = Set<Marker>();

// initialize map coordinates
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(0.28927317965072585, 35.29253462041064),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final searchResults = context.watch<PlacesResults>();
    final searchFlag = context.watch<SearchToggle>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: MapType.normal,
                markers: _markers,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            searchToggle
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 30,
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              border: InputBorder.none,
                              hintText: "Search",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchToggle = false;
                                    searchController.text = "";
                                  });
                                },
                                icon: Icon(Icons.close),
                              ),
                            ),
                            onChanged: (val) {
                              if (_debounce?.isActive ?? false)
                                _debounce?.cancel();
                              _debounce =
                                  Timer(Duration(milliseconds: 700), () async {
                                if (val.length > 2) {
                                  if (searchFlag.searchToggle) {
                                    searchFlag.toggleSearch();
                                    _markers = {};
                                  }
                                  List results =
                                      await MapServices().searchPlaces(val);

                                  searchResults.setResults(results);
                                } else {
                                  searchResults.setResults([]);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            searchFlag.searchToggle
                ? searchResults.allReturnedResults.length != 0
                    ? Positioned(
                        top: 100.0,
                        left: 15.0,
                        child: Container(
                          height: 200.0,
                          width: MediaQuery.of(context).size.width - 30.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white.withOpacity(.7),
                          ),
                          child: ListView(children: [
                            ...searchResults.allReturnedResults
                                .map((e) => buildListItem(e, searchFlag))
                          ]),
                        ),
                      )
                    : Positioned(
                        top: 100.0,
                        left: 15.0,
                        child: Container(
                            height: 200.0,
                            width: MediaQuery.of(context).size.width - 30.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white.withOpacity(.7),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "No results to display",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                SizedBox(
                                  width: 125.0,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Center(
                                      child: Text(
                                        "close this",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FabCircularMenu(
        alignment: Alignment.bottomLeft,
        fabColor: Colors.blue.shade50,
        fabOpenColor: Colors.red.shade100,
        ringDiameter: 250.0,
        ringWidth: 60.0,
        fabSize: 60.0,
        ringColor: Colors.blue.shade50,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                searchToggle = true;
                radiusSlider = false;
                pressedNear = false;
                cardTapped = false;
                getDirection = false;
              });
            },
            icon: Icon(
              Icons.search,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Widget buildListItem(placeItem, searchFlag) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          searchFlag.toggleSearch();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 25.0, color: Colors.green),
            SizedBox(
              width: 4.0,
            ),
            Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(placeItem["description"] ?? ""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
