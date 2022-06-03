import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

class TrainSeatScreen extends StatefulWidget {
  final String title;
  final TrainBookingResponse booking;

  const TrainSeatScreen({Key? key, required this.title, required this.booking})
      : super(key: key);

  @override
  _TrainSeatScreenState createState() => _TrainSeatScreenState();
}

class _TrainSeatScreenState extends State<TrainSeatScreen> {
  bool isLoading = false;
  List<TrainWagonData> wagonData = [];
  TrainWagonData? currentWagon;
  TrainPassenger? currentPassenger;
  TrainRowData? currentSeat;
  late TrainBookingResponse booking;

  @override
  void initState() {
    super.initState();
    // booking = TrainBookingResponse.fromJson(widget.booking.toJson());
    booking = widget.booking;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
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
    Api.getTrainSeatMap(booking: widget.booking).then((response) {
      wagonData = (response['data'] as List<dynamic>)
          .map(
              (dynamic e) => TrainWagonData.fromJson(e as Map<String, dynamic>))
          .toList();
      isLoading = false;
      if (wagonData.isNotEmpty) currentWagon = wagonData.first;
      setState(() {});
    }).catchError(_handleError);
  }

  Widget buildWagonCard(TrainWagonData wagon) {
    return InkWell(
      onTap: () {
        setState(() {
          currentWagon = wagon;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: currentWagon == wagon ? AppColors.black1 : AppColors.yellow1,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '${wagon.wagonCode} ${wagon.wagonNo}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  VoidCallback onPassengerTap(TrainPassenger passenger) {
    return () {
      if (passenger.wagonCode.isNotEmpty && passenger.wagonNo.isNotEmpty) {
        var searchWagon = wagonData.where((wagon) =>
            wagon.wagonCode == passenger.wagonCode &&
            wagon.wagonNo == passenger.wagonNo);
        if (searchWagon.isNotEmpty) {
          currentWagon = searchWagon.first;
        }
      }
      currentPassenger = passenger;
      debugPrint('Passenger $currentPassenger');
      setState(() {});
    };
  }

  Widget buildPassengerCard(TrainPassenger passenger) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onPassengerTap(passenger),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentPassenger != null &&
                        currentPassenger!.passengerId == passenger.passengerId
                    ? AppColors.red1
                    : AppColors.blue6,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${passenger.seatRow}${passenger.seatColumn}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            Text(passenger.name),
            Text(
              '${passenger.wagonCode} ${passenger.wagonNo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback onSelectSeat(TrainRowData seat) {
    return () async {
      if (seat.isEmpty) {
        if (currentPassenger == null) {
          snackBarDialog(context, 'Pilih penumpang');
          return;
        }
        var closeLoader = showLoaderDialog(context, message: 'Mohon tunggu...');
        await Api.changeTrainSeat(
                passengerId: currentPassenger!.passengerId,
                wagonCode: currentWagon!.wagonCode,
                wagonNo: currentWagon!.wagonNo,
                seat: seat)
            .then((response) {
          currentPassenger!.seatRow = seat.seatRow;
          currentPassenger!.seatColumn = seat.seatColumn;
          currentPassenger!.wagonCode = currentWagon!.wagonCode;
          currentPassenger!.wagonNo = currentWagon!.wagonNo;
          if (currentSeat != null) {
            currentSeat!.isEmpty = true;
          }
          seat.isEmpty = false;
          setState(() {});
        }).catchError(_handleError);
        await closeLoader();
      }
    };
  }

  Widget buildSeat(TrainRowData row) {
    bool isCurrentPassengerSeat = currentPassenger != null &&
        currentPassenger!.wagonCode == currentWagon!.wagonCode &&
        currentPassenger!.wagonNo == currentWagon!.wagonNo &&
        currentPassenger!.seatRow == row.seatRow &&
        currentPassenger!.seatColumn == row.seatColumn;
    currentSeat = isCurrentPassengerSeat ? row : currentSeat;
    return row.seatColumn.isEmpty
        ? const SizedBox()
        : row.seatRow == 0
            ? Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(2),
                width: 60,
                height: 50,
              )
            : InkWell(
                onTap: onSelectSeat(row),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(10)),
                    shape: BoxShape.circle,
                    color: row.isEmpty && !isCurrentPassengerSeat
                        ? Colors.white
                        : isCurrentPassengerSeat
                            ? AppColors.red1
                            : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(2),
                  height: 50,
                  width: 60,
                  alignment: Alignment.center,
                  child: Text('${row.seatRow}${row.seatColumn}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: row.isEmpty && !isCurrentPassengerSeat
                              ? Colors.green
                              : Colors.white)),
                ),
              );
  }

  Widget buildWagonSeatMap(TrainWagonData wagon) {
    return Expanded(
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final column in wagon.columns)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [for (final row in column.rows) buildSeat(row)],
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.title),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            // margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('Gerbong',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (var wagon in wagonData) buildWagonCard(wagon)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var passenger in booking.passengers)
                    buildPassengerCard(passenger)
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pilih Kursi'),
                      const SizedBox(height: 10),
                      currentWagon != null
                          ? buildWagonSeatMap(currentWagon!)
                          : const SizedBox()
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: AppButton('Selesai', () {
              popScreen(context);
            }),
          )
        ],
      ),
    );
  }
}
