import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

class TrainBookingScreen extends StatefulWidget {
  final String title;
  final int bookingId;

  const TrainBookingScreen({
    Key? key,
    required this.title,
    required this.bookingId,
  }) : super(key: key);

  @override
  _TrainBookingScreenState createState() => _TrainBookingScreenState();
}

class _TrainBookingScreenState extends State<TrainBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  TrainStation? departure;
  TrainStation? destination;
  int numAdult = 0;
  int numChild = 0;
  TrainScheduleResponse? train;

  List<TrainPassengerData> passengerData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  FutureOr<Null> _handleError(Object e) {
    snackBarDialog(context, e.toString());
    isLoading = false;
    setState(() {});
  }

  void initialize() {
    setState(() {
      isLoading = true;
    });
    Api.getTrainBookingDetail(widget.bookingId).then((response) {
      debugPrint('Get booking ${response}');
      isLoading = false;
      setState(() {});
    }).catchError(_handleError);
  }

  Widget buildSchedulesItem(TrainScheduleResponse schedule) {
    var timeDiff =
        schedule.arrivalDatetime.difference(schedule.departureDatetime);
    var hours = (timeDiff.inMinutes / 60).floor();
    var minutes = timeDiff.inMinutes % 60;
    var availableSeat = schedule.detail.availableSeat;
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.trainName),
                      ],
                    ),
                    const Spacer(),
                    Text(schedule.trainNo)
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${formatDate(schedule.departureDatetime, format: 'HH:mm')} - ${formatDate(schedule.arrivalDatetime, format: 'HH:mm')}'),
                            Text(
                              '$hours Jam $minutes Menit',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${schedule.detail.className} (${schedule.detail.classCode}) / ${schedule.detail.subClass}'),
                            // Text(
                            //   'Tersedia ${availableSeat} Kursi',
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .bodyMedium!
                            //       .copyWith(
                            //           color: availableSeat == 0
                            //               ? Colors.redAccent
                            //               : null),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Rp. ${formatNumber(schedule.detail.adultPrice)}',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: AppColors.blue4,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(' / orang'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPassengerItem(TrainPassengerData passenger, int index) {
    if (passenger is TrainPassengerAdultData) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dewasa',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextFormField(
                decoration: generateInputDecoration(
                  label: 'Nama Lengkap (Sesuai nomor identitas)',
                ),
                initialValue: passenger.name,
                maxLength: 50,
                onChanged: (value) {
                  passenger.name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Masukkan Nama Lengkap';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: generateInputDecoration(
                  label: 'Nomor Identitas',
                ),
                initialValue: passenger.idNumber,
                maxLength: 50,
                onChanged: (value) {
                  passenger.idNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Masukkan Nomor Identitas';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: generateInputDecoration(
                  label: 'Nomor Telepon',
                ),
                initialValue: passenger.phoneNumber,
                maxLength: 15,
                onChanged: (value) {
                  passenger.phoneNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Masukkan Nomor Telepon';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );
    } else if (passenger is TrainPassengerChildData) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anak',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextFormField(
                decoration: generateInputDecoration(
                  label: 'Nama Lengkap',
                ),
                initialValue: passenger.name,
                maxLength: 50,
                onChanged: (value) {
                  passenger.name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Masukkan Nama Lengkap';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: generateInputDecoration(
                  label: 'Tanggal Lahir (DDMMYYYY)',
                ),
                initialValue: passenger.idNumber,
                maxLength: 8,
                onChanged: (value) {
                  passenger.idNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Masukkan Tanggal Lahir';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void submitData() async {
    // if (_formKey.currentState!.validate()) {
    //   void exec() {
    //     setState(() {
    //       isLoading = true;
    //     });
    //     Api.createTrainBooking(
    //       departure: widget.departure,
    //       destination: widget.destination,
    //       numAdult: widget.numAdult,
    //       numChild: widget.numChild,
    //       train: widget.train,
    //       adultPassengers:
    //           passengerData.whereType<TrainPassengerAdultData>().toList(),
    //       childPassengers:
    //           passengerData.whereType<TrainPassengerChildData>().toList(),
    //     ).then((response) {
    //       debugPrint('Response ${response.body}');
    //       popScreen(context);
    //     }).catchError(_handleError);
    //   }
    //
    //   confirmDialog(context,
    //       msg: 'Data yang dimasukkan sudah benar ?',
    //       title: 'Konfirmasi',
    //       confirmAction: exec);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.title),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
              // color: Theme.of(context).cardTheme.color,
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            departure?.code ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(departure?.stationName ?? '')
                        ],
                      ),
                    ),
                    const Image(image: AppImages.trainArrow),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            destination?.code ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(destination?.stationName ?? '')
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                train == null
                    ? Text('')
                    : Text(
                        '${formatDate(train!.departureDatetime, format: 'EEEE, d MMMM yyyy')} - ${numAdult} Dewasa ${numChild > 0 ? numChild.toString() + ' Bayi' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
              ],
            ),
          ),
          train == null ? SizedBox() : buildSchedulesItem(train!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: passengerData.length,
                  itemBuilder: (context, index) {
                    return buildPassengerItem(passengerData[index], index);
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: AppButton('Pesan Tiket', isLoading ? null : submitData),
          )
        ],
      ),
    );
  }
}
