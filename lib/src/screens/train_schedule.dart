import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/screens/train_passanger.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class TrainScheduleScreen extends StatefulWidget {
  final String title;

  final DateTime departureDate;
  final TrainStation departure;
  final TrainStation destination;
  final int numAdult;
  final int numChild;

  const TrainScheduleScreen({
    Key? key,
    required this.title,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.numAdult,
    required this.numChild,
  }) : super(key: key);

  @override
  _TrainScheduleScreenState createState() => _TrainScheduleScreenState();
}

class _TrainScheduleScreenState extends State<TrainScheduleScreen> {
  // late AnimationController _controller;

  bool isLoading = false;
  List<TrainScheduleResponse> schedulesData = [];

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
    setState(() {
      isLoading = true;
    });
    Api.getTrainSchedule(
      departure: widget.departure,
      destination: widget.destination,
      numAdult: widget.numAdult,
      numChild: widget.numChild,
      date: widget.departureDate,
    ).then((response) {
      schedulesData = (response['schedules'] as List<dynamic>)
          .map((dynamic e) =>
              TrainScheduleResponse.fromJson(e as Map<String, dynamic>))
          .toList();
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
        onTap: () {
          pushScreen(
            context,
            (_) => TrainPassangerScreen(
              title: 'Data Penumpang',
              departure: widget.departure,
              destination: widget.destination,
              numAdult: widget.numAdult,
              numChild: widget.numChild,
              train: schedule,
            ),
          );
        },
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
                            Text(
                              'Tersedia ${availableSeat} Kursi',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: availableSeat == 0
                                          ? Colors.redAccent
                                          : null),
                            ),
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
                  '${formatDate(widget.departureDate, format: 'EEEE, d MMMM yyyy')} - ${widget.numAdult} Dewasa ${widget.numChild > 0 ? widget.numChild.toString() + ' Bayi' : ''} (${schedulesData.length} jadwal)',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : ListView.builder(
                      itemCount: schedulesData.length,
                      itemBuilder: (context, index) {
                        return buildSchedulesItem(schedulesData[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
