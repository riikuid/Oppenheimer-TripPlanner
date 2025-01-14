import 'package:flutter/material.dart';
// import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/add_activities/form_suggestion.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/custom_colors.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../provider/itinerary_provider.dart';

// ignore: must_be_immutable
class SelectDate extends StatefulWidget {
  final bool isNewItinerary;
  List<DateTime> initialDates;
  SelectDate(
      {Key? key, this.initialDates = const [], required this.isNewItinerary})
      : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  late ItineraryProvider itineraryProvider;

  late DatabaseProvider databaseProvider;

  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    selectedDates = widget.initialDates;
  }

  @override
  Widget build(BuildContext context) {
    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xFFE5BA73),
        appBar: AppBar(
          title: const Text(
            'Pilih Tanggal',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'poppins_bold',
            ),
            // itineraryProvider.itinerary.title,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: const Color(0xFFE5BA73),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: CustomColor.surface,
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: SfDateRangePicker(
                          selectionColor: CustomColor.dateBackground,
                          backgroundColor: CustomColor.surface,
                          todayHighlightColor: CustomColor.borderColor,
                          selectionTextStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          initialSelectedDates: widget.initialDates,
                          selectionMode: DateRangePickerSelectionMode.multiple,
                          showNavigationArrow: true,
                          minDate: DateTime.now(),
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs? args) {
                            if (args?.value is List<DateTime>) {
                              final dates = args?.value as List<DateTime>;
                              setState(
                                () {
                                  selectedDates = dates
                                      .where(
                                        (date) => date.isAfter(
                                          DateTime.now().subtract(
                                            const Duration(days: 1),
                                          ),
                                        ),
                                      )
                                      .toList();
                                  // ignore: avoid_print
                                  print(selectedDates);
                                },
                              );
                            }
                          },
                          headerStyle: const DateRangePickerHeaderStyle(
                            backgroundColor: CustomColor.surface,
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'poppins_bold',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // onSelectionChanged:
            //     (DateRangePickerSelectionChangedArgs? args) {
            //   if (args?.value is List<DateTime>) {
            //     final dates = args?.value as List<Date>Time>;
            //     selectedDates = dates;
            //   }
            // },
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // padding: EdgeInsets.fromLTRB(7, 15, 7, 30),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: 4,
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ],
                ),
                height: 200,
                // color: Colors.grey,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.isNewItinerary)
                      Expanded(
                        child: FilledButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              CustomColor.buttonColor,
                            ),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 20),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Rekomendasi Itinerary',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'poppins_bold',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (selectedDates.isNotEmpty) {
                              // itineraryProvider.initializeDays(selectedDates);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormSuggestion(
                                    selectedDays: selectedDates,
                                    // onSubmit: (Activity newActivity) {
                                    //   // Implementasikan logika setelah aktivitas disubmit
                                    //   print(
                                    //       'Aktivitas Baru: ${newActivity.activityName}');
                                    // },
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Pilih Tanggal setelah Hari Ini!"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FilledButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            CustomColor.buttonColor,
                          ),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 31),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          widget.isNewItinerary
                              ? 'Self Planning'
                              : 'Selanjutnya',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'poppins_bold',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (selectedDates.isNotEmpty) {
                            itineraryProvider.initializeDays(selectedDates);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddDays(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Pilih Tanggal setelah Hari Ini!"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
