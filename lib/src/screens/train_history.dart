import 'package:flutter/material.dart';

class TrainHistory extends StatefulWidget {
  const TrainHistory({Key? key}) : super(key: key);

  @override
  _TrainHistoryState createState() => _TrainHistoryState();
}

class _TrainHistoryState extends State<TrainHistory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Train History'),
    );
  }
}
