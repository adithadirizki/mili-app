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

class TrainPassangerScreen extends StatefulWidget {
  final String title;

  final TrainStation departure;
  final TrainStation destination;
  final int numAdult;
  final int numChild;
  final TrainScheduleResponse train;

  const TrainPassangerScreen({
    Key? key,
    required this.title,
    required this.departure,
    required this.destination,
    required this.numAdult,
    required this.numChild,
    required this.train,
  }) : super(key: key);

  @override
  _TrainPassangerScreenState createState() => _TrainPassangerScreenState();
}

class _TrainPassangerScreenState extends State<TrainPassangerScreen> {
  // late AnimationController _controller;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  List<TrainPassengerData> passengerData = [];

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this);
    for (var i = 0; i < widget.numAdult; i++) {
      passengerData.add(TrainPassengerAdultData());
    }
    for (var i = 0; i < widget.numChild; i++) {
      passengerData.add(TrainPassengerChildData());
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  FutureOr<Null> _handleError(Object e) {
    snackBarDialog(context, e.toString());
    isLoading = false;
    setState(() {});
  }

  void initialize() {
    // setState(() {
    //   isLoading = true;
    // });
    // Api.getTrainSchedule(
    //         departure: widget.departure,
    //         destination: widget.destination,
    //         numAdult: widget.numAdult,
    //         numChild: widget.numChild,
    //         date: widget.departureDate)
    //     .then((response) {
    //   schedulesData = (response['schedules'] as List<dynamic>)
    //       .map((dynamic e) =>
    //           TrainScheduleResponse.fromJson(e as Map<String, dynamic>))
    //       .toList();
    //   isLoading = false;
    //   setState(() {});
    // }).catchError(_handleError);
  }

  Widget buildSchedulesItem(TrainScheduleResponse schedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
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
                                schedule.estimationTime(),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
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
    if (_formKey.currentState!.validate()) {
      void exec() {
        setState(() {
          isLoading = true;
        });
        Api.createTrainBooking(
          departure: widget.departure,
          destination: widget.destination,
          numAdult: widget.numAdult,
          numChild: widget.numChild,
          train: widget.train,
          adultPassengers:
              passengerData.whereType<TrainPassengerAdultData>().toList(),
          childPassengers:
              passengerData.whereType<TrainPassengerChildData>().toList(),
        ).then((response) {
          debugPrint('Response ${response.body}');
          popScreen(context);
        }).catchError(_handleError);
      }

      confirmDialog(context,
          msg: 'Data yang dimasukkan sudah benar ?',
          title: 'Konfirmasi',
          confirmAction: exec);
    }
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
                            widget.departure.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(widget.departure.stationName)
                        ],
                      ),
                    ),
                    const Image(image: AppImages.trainArrow),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.destination.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(widget.destination.stationName)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${formatDate(widget.train.departureDatetime, format: 'EEEE, d MMMM yyyy')} - ${widget.numAdult} Dewasa ${widget.numChild > 0 ? widget.numChild.toString() + ' Bayi' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          ),
          buildSchedulesItem(widget.train),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
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
