import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_activities/suggestion_itinerary.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/custom_colors.dart';
import 'package:provider/provider.dart';

class FormSuggestion extends StatefulWidget {
  final List<DateTime> selectedDays;

  const FormSuggestion({super.key, required this.selectedDays});

  @override
  FormSuggestionState createState() => FormSuggestionState();
}

class FormSuggestionState extends State<FormSuggestion> {
  // Daftar lokasi statis untuk dropdown
  final List<String> _locations = [
    "Surabaya",
    "Mojokerto",
    "Malang",
  ];

  String? _selectedDepartureLocation; // Lokasi Berangkat terpilih
  String? _selectedDestinationLocation; // Lokasi Tujuan terpilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.surface,
      appBar: AppBar(
        backgroundColor: CustomColor.surface,
        title: Column(
          children: [
            const Text(
              "Form Rekomendasi",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'poppins_bold',
                fontSize: 30,
                color: CustomColor.buttonColor,
              ),
            ),
            Text(widget.selectedDays.toString()),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Berangkat",
                          style: TextStyle(
                            fontFamily: 'poppins_bold',
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedDepartureLocation,
                          isExpanded: true,
                          dropdownColor: CustomColor.surface,
                          items: _locations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedDepartureLocation = value;
                              },
                            );
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Tujuan",
                          style: TextStyle(
                            fontFamily: 'poppins_bold',
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedDestinationLocation,
                          isExpanded: true,
                          dropdownColor: CustomColor.surface,
                          items: _locations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDestinationLocation = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: (_selectedDepartureLocation != null &&
                              _selectedDestinationLocation != null)
                          ? CustomColor.buttonColor
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    onPressed: (_selectedDepartureLocation != null &&
                            _selectedDestinationLocation != null)
                        ? () async {
                            log('message');
                            // final _rawData = await rootBundle
                            //     .loadString('assets/pepekk.csv');
                            // List<List<dynamic>> _listData =
                            //     CsvToListConverter().convert(_rawData);
                            // log("DATA CSV $_listData");
                            List<Itinerary> result = await context
                                .read<ItineraryProvider>()
                                .parseJsonToItinerary(
                                    _selectedDepartureLocation!,
                                    _selectedDestinationLocation!,
                                    widget.selectedDays.length);
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SuggestionItinerary(
                                  itineraries: result,
                                  selectedDays: widget.selectedDays,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        fontSize: 20,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
