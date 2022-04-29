import 'dart:math' as math; // import this

import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/screens/train_schedule.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/train_station_list.dart';

class TrainOrder extends StatefulWidget {
  const TrainOrder({Key? key}) : super(key: key);

  @override
  _TrainOrderState createState() => _TrainOrderState();
}

class _TrainOrderState extends State<TrainOrder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool isLoading = false;
  List<TrainStation> stationData = [];

  DateTime departureDate = DateTime.now().add(const Duration(days: 1));
  TrainStation? departure;
  TrainStation? destination;

  int numAdult = 1;
  int numChild = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initialize() {
    initDB();
  }

  Future<void> initDB() async {
    isLoading = true;

    await AppDB.syncTrainStation();

    final stationDB = AppDB.trainStationDB;

    QueryBuilder<TrainStation> queryStation = stationDB.query()
      ..order(TrainStation_.stationName);
    stationData = queryStation.build().find();

    debugPrint('TrainOrder station size ${stationData.length}');

    isLoading = false;
    setState(() {});
  }

  void adjustAdult(int num) {
    if (num < 0 && numAdult > 1) {
      setState(() {
        numAdult--;
      });
    } else if (num > 0 && numChild + numAdult < 4) {
      setState(() {
        numAdult++;
      });
    }
  }

  void adjustChild(int num) {
    if (num < 0 && numChild > 0) {
      setState(() {
        numChild--;
      });
    } else if (num > 0 && numChild + numAdult < 4) {
      setState(() {
        numChild++;
      });
    }
  }

  void selectDepartureDate() async {
    var selectedDate = await showDatePicker(
      context: context,
      initialDate: departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (selectedDate != null) {
      setState(() {
        departureDate = selectedDate;
      });
    }
  }

  void searchStation(void Function(TrainStation) onItemTap) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return TrainStationList(
          stationData: stationData,
          onItemTap: onItemTap,
        );
      },
    );
  }

  void onSearchDepartStation() {
    searchStation((station) {
      if (destination != null && destination!.code == station.code) {
        snackBarDialog(
          context,
          'Pilih stasiun lain',
          duration: 2000,
        );
      } else {
        setState(() {
          departure = station;
        });
      }
    });
  }

  void onSearchDestinationStation() {
    searchStation((station) {
      if (departure != null && departure!.code == station.code) {
        snackBarDialog(
          context,
          'Pilih stasiun lain',
          duration: 2000,
        );
      } else {
        setState(() {
          destination = station;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onSearchDepartStation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Keberangkatan'),
                        const Image(image: AppImages.train, width: 120),
                        departure != null
                            ? Text(
                                '${departure?.stationName}\n(${departure?.code})',
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                'Cari Stasiun\n',
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      var temp = departure;
                      departure = destination;
                      destination = temp;
                      setState(() {});
                    },
                    child: const Image(
                        image: AppImages.destinationSwap, width: 50)),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onSearchDestinationStation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Tujuan'),
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child:
                              const Image(image: AppImages.train, width: 120),
                        ),
                        destination != null
                            ? Text(
                                '${destination?.stationName}\n(${destination?.code})',
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                'Cari Stasiun\n',
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Image(image: AppImages.trainCalendar, width: 32),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Keberangkatan',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    GestureDetector(
                      onTap: () {
                        selectDepartureDate();
                      },
                      child: Text(
                        formatDate(departureDate, format: 'EEEE, d MMMM yyyy'),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('DEWASA'),
                      const Text('Umur diatas 3 tahun'),
                      const Image(image: AppImages.trainAdult, height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              adjustAdult(-1);
                            },
                            icon: const Icon(
                              Icons.remove_circle_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                          Text(numAdult.toString()),
                          IconButton(
                            onPressed: () {
                              adjustAdult(1);
                            },
                            icon: const Icon(
                              Icons.add_circle_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Stack(
                //   children: const [
                //     // Container(
                //     //   width: 2,
                //     //   height: double.infinity,
                //     //   decoration: BoxDecoration(
                //     //     border: Border.all(color: Colors.grey, width: 1),
                //     //   ),
                //     // ),
                //   ],
                // ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('BAYI'),
                      const Text('Umur dibawah 3 tahun'),
                      const Image(image: AppImages.trainBaby, height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              adjustChild(-1);
                            },
                            icon: const Icon(
                              Icons.remove_circle_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                          Text(numChild.toString()),
                          IconButton(
                            onPressed: () {
                              adjustChild(1);
                            },
                            icon: const Icon(
                              Icons.add_circle_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppButton('Cari Tiket', () {
          if (null == departure || null == destination) {
            snackBarDialog(context, 'Pilih stasiun keberangkatan dan tujuan');
            return;
          } else if (departureDate
              .isBefore(DateUtils.dateOnly(DateTime.now()))) {
            snackBarDialog(context, 'Tanggal keberangkatan tidak sesuai');
            return;
          } else if (numAdult < 1) {
            snackBarDialog(context, 'Jumlah penumpang minimal 1 dewasa');
            return;
          }
          pushScreen(
            context,
            (_) => TrainScheduleScreen(
              title: 'Jadwal Kereta',
              departure: departure!,
              destination: destination!,
              departureDate: departureDate,
              numAdult: numAdult,
              numChild: numChild,
            ),
          );
        })
      ],
    );
  }
}
