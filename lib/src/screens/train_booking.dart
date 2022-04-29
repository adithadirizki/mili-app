import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/screens/train_payment.dart';
import 'package:miliv2/src/screens/train_seat.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TrainBookingScreen extends StatefulWidget {
  final String title;
  final TrainBookingResponse booking;

  const TrainBookingScreen({
    Key? key,
    required this.title,
    required this.booking,
  }) : super(key: key);

  @override
  _TrainBookingScreenState createState() => _TrainBookingScreenState();
}

class _TrainBookingScreenState extends State<TrainBookingScreen> {
  bool isLoading = false;

  TrainStation? departure;
  TrainStation? destination;
  int numAdult = 0;
  int numChild = 0;
  TrainScheduleResponse? train;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   initialize();
    // });
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
    // setState(() {
    //   isLoading = true;
    // });
    // Api.getTrainBookingDetail(widget.bookingId).then((response) {
    //   debugPrint('Get booking ${response}');
    //   bookingData = TrainBookingResponse.fromJson(response['data'] as Map<String, dynamic>);
    //   isLoading = false;
    //   setState(() {});
    // }).catchError(_handleError);
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

  void openPayment() {
    pushScreen(context, (ctx) {
      return TrainPaymentScreen(
        booking: widget.booking,
        onPaymentConfirmed: _onPaymentConfirmed,
      );
    });
  }

  void printReceipt() {
    AppPrinter.printTrainReceipt(widget.booking);
  }

  void changeSeat() {
    pushScreen(context, (ctx) {
      return TrainSeatScreen(
        title: 'Ganti Kursi',
        booking: widget.booking,
      );
    });
  }

  void _onPaymentConfirmed() {
    popScreenWithCallback<bool>(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.booking;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            data.departure.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(data.departure.stationName)
                        ],
                      ),
                    ),
                    const Image(image: AppImages.trainArrow),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            data.destination.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(data.destination.stationName)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(data.departureDatetime,
                          format: 'EEEE, dd MMMM yyyy HH:mm'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    // const SizedBox(width: 20),
                    Text(
                      data.estimationTime(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.trainName} - No. ${data.trainNo}'),
                        Text(
                            '${data.className} (${data.classCode}) / ${data.subClass}'),
                      ],
                    ),
                    const Spacer(),
                    Text('Dewasa ( ${data.adultNum} )'),
                    data.childNum > 0
                        ? Text('Anak ( ${data.childNum} )')
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    data.isCompleted()
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              child: Column(
                                children: [
                                  const Text('Kode Booking'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // mainAxisSize: MainAxisSize.max,
                                    children: [
                                      QrImage(
                                        data: data.bookingCode,
                                        version: QrVersions.auto,
                                        size: 100,
                                      ),
                                      Text(
                                        data.bookingCode,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Penumpang'),
                                const Spacer(),
                                data.isOpen()
                                    ? TextButton(
                                        onPressed: changeSeat,
                                        child: const Text('Ganti Kursi'),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const Divider(),
                            for (var passanger in data.passengers)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(passanger.name),
                                  Text(
                                    '${passanger.wagonCode} ${passanger.wagonNo} / ${passanger.seatRow}${passanger.seatColumn}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10)
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Biaya'),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dewasa x${data.adultNum}',
                                ),
                                Text(
                                  'Rp. ${formatNumber(data.adultNum * data.adultPrice)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            data.childNum > 0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Anak x${data.childNum}',
                                      ),
                                      Text(
                                        'Rp. ${formatNumber(data.childNum * data.childPrice)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Colors.deepOrange),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sub Total',
                                ),
                                Text(
                                  'Rp. ${formatNumber(data.totalPrice)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Biaya Admin',
                                ),
                                Text(
                                  'Rp. ${formatNumber(data.totalAdmin)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Potongan',
                                ),
                                Text(
                                  'Rp. ${formatNumber(data.totalDiscount)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                ),
                                Text(
                                  'Rp. ${formatNumber(data.grandTotal)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data.isOpen() || data.isCompleted()
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child: data.isOpen()
                      ? AppButton('Pembayaran', isLoading ? null : openPayment)
                      : AppButton(
                          'Cetak Struk', isLoading ? null : printReceipt),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
