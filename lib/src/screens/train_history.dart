import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/train.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/screens/train_booking.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme.dart';

class TrainHistoryScreen extends StatefulWidget {
  const TrainHistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  _TrainHistoryScreenState createState() => _TrainHistoryScreenState();
}

class _TrainHistoryScreenState extends State<TrainHistoryScreen> {
  // late AnimationController _controller;

  bool isLoading = false;
  List<TrainBookingResponse> bookingData = [];

  DateTime departureDate = DateTime.now();
  TrainStation? departure;
  TrainStation? destination;
  int numAdult = 0;
  int numChild = 0;

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
    Map<String, Object> params = <String, Object>{};
    params['sort'] = '{"created_at":"desc"}';
    params['limit'] = '50';
    Api.getTrainBookingList(params: params).then((response) {
      bookingData = response.data
          .map((dynamic e) =>
              TrainBookingResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      isLoading = false;
      setState(() {});
    }).catchError(_handleError);
  }

  Widget buildBookingItem(TrainBookingResponse data) {
    var timeDiff = data.arrivalDatetime.difference(data.departureDatetime);
    var hours = (timeDiff.inMinutes / 60).floor();
    var minutes = timeDiff.inMinutes % 60;
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          pushScreen(
            context,
            (_) => TrainBookingScreen(
              title: 'Detail Pembelian',
              booking: data,
              // bookingId: data.bookingId,
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
                        Text('ORDER ID : ${data.bookingNumber}'),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      formatDate(data.createdDatetime,
                          format: 'dd/MM/yyyy HH:mm'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                                data.departure['code'] == null
                                    ? ''
                                    : data.departure['code'] as String,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(data.departure['name'] == null
                                  ? ''
                                  : data.departure['name'] as String)
                            ],
                          ),
                        ),
                        const Image(image: AppImages.trainArrow),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                data.destination['code'] == null
                                    ? ''
                                    : data.destination['code'] as String,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(data.destination['name'] == null
                                  ? ''
                                  : data.destination['name'] as String)
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
                          '$hours Jam $minutes Menit',
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
                    // const Divider(),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(data.statusDescription),
                    ),
                    const SizedBox(height: 20),
                    data.isOpen()
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Colors.amberAccent,
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Order ini akan otomatis batal pada ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextSpan(
                                    text: formatDate(data.expiredAt,
                                        format: 'EEEE, dd MMMM HH:ss'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        ', silahkan segera lakukan pembayaran',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : data.isCompleted()
                            ? Column(
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
                              )
                            : const SizedBox(),
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : ListView.builder(
              itemCount: bookingData.length,
              itemBuilder: (context, index) {
                return buildBookingItem(bookingData[index]);
              },
            ),
    );
  }
}
