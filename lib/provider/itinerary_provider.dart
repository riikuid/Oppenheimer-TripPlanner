import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/model/itinerary.dart';

class ItineraryProvider extends ChangeNotifier {
  late Itinerary _itinerary;
  late Itinerary initialItinerary;
  Itinerary get itinerary => _itinerary;

  bool get isDataChanged =>
      _itinerary.toJsonString() != initialItinerary.toJsonString();

  void initItinerary(Itinerary newItinerary) {
    _itinerary = newItinerary.copy();
    initialItinerary = newItinerary.copy();
    notifyListeners();
  }

  void setNewItineraryTitle(String newTitle) {
    _itinerary.title = newTitle;
  }

  void addDay(Day newDay) {
    try {
      _itinerary.days = [..._itinerary.days, newDay];
    } catch (e) {
      log("$e", name: 'qqq');
    }
    notifyListeners();
  }

  void initializeDays(List<DateTime> dates) {
    List<DateTime> sortedNewDates = dates..sort();

    List<DateTime> currentDates =
        _itinerary.days.map((e) => e.getDatetime()).toList();

    List<Day> finalDays = [];

    var i = 0;
    var j = 0;
    // Push semua currentDates yang gak ada di sortedNewDates
    while (i < sortedNewDates.length && j < currentDates.length) {
      if (currentDates[j].isBefore(sortedNewDates[i])) {
        j++;
      } else if (currentDates[j].isAfter(sortedNewDates[i]))
        finalDays.add(Day.from(sortedNewDates[i++]));
      else {
        finalDays.add(_itinerary.days[j].copy());
        j++;
        i++;
      }
    }
    while (i < sortedNewDates.length) {
      finalDays.add(Day.from(sortedNewDates[i++]));
    }

    _itinerary.days = finalDays;
    print('final : ${_itinerary.days[0].date}');

    notifyListeners();
  }

  List<Day> getDateTime() {
    return _itinerary.days;
  }

  // String convertDateTimeToString({required DateTime dateTime}) =>
  //     "${dateTime.day}/" "${dateTime.month}/" "${dateTime.year}";

  void updateActivity({
    required int updatedDayIndex,
    required int updatedActivityIndex,
    required Activity newActivity,
  }) {
    _itinerary = itinerary.copy(
        days: itinerary.days.mapIndexed((index, day) {
      if (index == updatedDayIndex) {
        return day.copy(
            activities: day.activities.mapIndexed((index, activity) {
          if (index == updatedActivityIndex) {
            return newActivity;
          }
          return activity;
        }).toList());
      }
      return day;
    }).toList());
    notifyListeners();
  }

  void insertNewActivity(
      {required List<Activity> activities, required Activity newActivity}) {
    print('new activity :${newActivity.endDateTime}');
    activities.add(newActivity);
    notifyListeners();
  }

  void removeActivity(
      {required List<Activity> activities, required int removedHashCode}) {
    activities.removeWhere((element) => element.hashCode == removedHashCode);
    notifyListeners();
  }

  void addPhotoActivity(
      {required Activity activity, required String pathImage}) {
    activity.images!.add(pathImage);
    log("ADD IMAGE $pathImage");
    notifyListeners();
  }

  void removePhotoActivity({
    required Activity activity,
    required String pathImage,
  }) {
    activity.removedImages!.add(pathImage);
    log("ADD TO REMOVED IMAGE $pathImage");
    log("removed images" + activity.removedImages.toString());
    notifyListeners();
  }

  void returnPhotoActivity({
    required Activity activity,
    required String pathImage,
  }) {
    activity.removedImages!.remove(pathImage);
    log("RETURN IMAGE $pathImage");
    log("removed images${activity.removedImages}");
    notifyListeners();
  }

  void cleanPhotoActivity({
    required Activity activity,
  }) {
    activity.images = [];
    log("CLEANING");
    notifyListeners();
  }

  Future<List<Activity>> getSortedActivity(List<Activity> activities) async {
    return activities
      ..sort((a, b) {
        return a.startDateTime.compareTo(b.startDateTime);
      });
  }

  List<String> getImage(Activity activity) {
    return activity.images!;
  }

  Future<List<Itinerary>> parseJsonToItinerary(
      String asal, String tujuan, int jumlahHari) async {
    // Baca file JSON dari assets
    final rawData = await rootBundle.loadString('assets/data.json');

    // Parse JSON
    Map<String, dynamic> jsonData = jsonDecode(rawData);
    List<dynamic> itinerariesJson = jsonData['itineraries'];

    List<Itinerary> itineraries = [];

    // Gabungkan asal dan tujuan menjadi satu string format "asal-tujuan"
    String asalTujuan = "$asal-$tujuan";

    // Loop untuk mencari kecocokan lokasi di JSON
    for (var itineraryJson in itinerariesJson) {
      String location = itineraryJson['ASAL'];

      // Cek apakah lokasi dalam format asal-tujuan cocok
      if (asalTujuan == location) {
        String hasilItineraryKeyA = 'HASIL ${jumlahHari} HARI - A';
        String hasilItineraryKeyB = 'HASIL ${jumlahHari} HARI - B';

        // Mengambil hasil itinerary yang sesuai berdasarkan jumlahHari
        String hasilItinerary1 = itineraryJson[hasilItineraryKeyA] ?? '';
        String hasilItinerary2 = itineraryJson[hasilItineraryKeyB] ?? '';

        // Pisahkan hasil itinerary menjadi List<Day>
        List<Day> days1 = splitItineraryToDays(hasilItinerary1);
        List<Day> days2 = splitItineraryToDays(hasilItinerary2);

        // Menambahkan itinerary pertama dan kedua
        itineraries.add(Itinerary(
          title: 'Rekomendasi A',
          dateModified: DateTime.now().toString(),
          days: days1,
        ));

        itineraries.add(Itinerary(
          title: 'Rekomendasi B',
          dateModified: DateTime.now().toString(),
          days: days2,
        ));
      }
    }

    return itineraries;
  }

  // Future<List<Itinerary>> parseCsvToItinerary(
  //     String asal, String tujuan, int jumlahHari) async {
  //   final rawData = await rootBundle.loadString('assets/puqi.csv');

  //   // Parse CSV
  //   List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);

  //   Itinerary recommendation1 = Itinerary(
  //     title: 'Rekomendasi 1',
  //     dateModified: DateTime.now().toString(),
  //     days: [],
  //   );

  //   Itinerary recommendation2 = Itinerary(
  //     title: 'Rekomendasi 2',
  //     dateModified: DateTime.now().toString(),
  //     days: [],
  //   );

  //   // Menentukan indeks kolom berdasarkan jumlahHari
  //   int startRowIndex =
  //       (jumlahHari - 1) * 2 + 1; // Logika untuk memilih row yang sesuai

  //   // Gabungkan asal dan tujuan menjadi satu string format "asal-tujuan"
  //   String asalTujuan = "$asal-$tujuan";

  //   log(rows[2][2]);
  //   // Loop melalui baris-baris data CSV
  //   for (var row in rows) {
  //     // Loop untuk mencocokkan kolom 0, 7, 14, dst
  //     for (int i = 0; i < row.length; i++) {
  //       // Cek apakah index i adalah lokasi asal-tujuan (kolom 0, 7, 14, dst)
  //       if (i % 7 == 0) {
  //         String lokasiTujuan =
  //             row[i] ?? ''; // Lokasi - Tujuan pada kolom pertama

  //         // Pastikan kecocokan antara asal dan tujuan dalam format "asal-tujuan"
  //         if (asalTujuan == lokasiTujuan) {
  //           // Menentukan hasil itinerary yang sesuai berdasarkan jumlahHari
  //           String hasilItinerary1 =
  //               row[startRowIndex] ?? ''; // Hasil rekomendasi 1
  //           String hasilItinerary2 =
  //               row[startRowIndex + 1] ?? ''; // Hasil rekomendasi 2

  //           // Pisahkan hasil itinerary menjadi List<Day>
  //           List<Day> days1 = splitItineraryToDays(hasilItinerary1);
  //           List<Day> days2 = splitItineraryToDays(hasilItinerary2);

  //           // Simpan hasil rekomendasi ke dalam list yang sesuai
  //           recommendation1.days = days1;
  //           recommendation2.days = days2;
  //         }
  //       }
  //     }
  //   }

  //   log(recommendation1.days.length.toString());
  //   List<Itinerary> result = [recommendation1, recommendation2];

  //   // Mengembalikan hasil rekomendasi 1 dan 2 dalam bentuk List<Day>
  //   return result;
  // }

  List<Day> splitItineraryToDays(String itinerary) {
    List<Day> days = [];

    // Pisahkan berdasarkan HARI KE-X (menggunakan regex untuk menangkap setiap hari)
    final dayRegex =
        RegExp(r'HARI KE-(\d+)[\s\S]+?(?=HARI KE-\d+|$)', caseSensitive: false);
    final matches = dayRegex.allMatches(itinerary);

    for (final match in matches) {
      final dayActivitiesText = match.group(0) ?? '';

      // Pisahkan setiap aktivitas dalam hari ini dengan regex yang lebih spesifik
      final activityRegex = RegExp(
          r'Judul: (.*?)\nMulai: (.*?)\nEstimasi Selesai: (.*?)\nTempat: (.*?)\nInformasi Tambahan: (.*?)\n',
          caseSensitive: false);

      List<Activity> activities = [];
      final activityMatches = activityRegex.allMatches(dayActivitiesText);

      // Proses setiap aktivitas
      for (final activityMatch in activityMatches) {
        final activityName = activityMatch.group(1)?.trim() ?? '';
        final startActivityTime = activityMatch.group(2)?.trim() ?? '';
        final endActivityTime = activityMatch.group(3)?.trim() ?? '';
        final lokasi = activityMatch.group(4)?.trim() ?? '';
        final keterangan = activityMatch.group(5)?.trim() ?? '';
        // log('cok $activityName');
        Activity activity = Activity(
          activityName: activityName,
          startActivityTime: startActivityTime,
          endActivityTime: endActivityTime,
          lokasi: lokasi,
          keterangan: keterangan,
        );
        activities.add(activity);
      }

      // Menggunakan nama hari berdasarkan urutan
      String dayName = 'HARI KE-${days.length + 1}';
      days.add(Day(date: dayName, activities: activities));
    }

    return days;
  }
}
