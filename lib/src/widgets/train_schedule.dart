import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/src/widgets/blue_box.dart';
import 'package:miliv2/src/widgets/button.dart';

class TrainSchedule extends StatefulWidget {
  const TrainSchedule({Key? key}) : super(key: key);

  @override
  _TrainScheduleState createState() => _TrainScheduleState();
}

class _TrainScheduleState extends State<TrainSchedule>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              children: [
                BlueBox(width: 10),
                Container(),
                Container(),
              ],
            ),
          ),
        ),
        Card(
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [],
            ),
          ),
        ),
        Card(
          // color: Colors.white,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [],
            ),
          ),
        ),
        AppButton('Cari Tiket', () {})
      ],
    );
  }
}
