import 'package:flutter/material.dart';
import 'package:miliv2/src/models/train_station.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';

class TrainStationList extends StatefulWidget {
  final List<TrainStation> stationData;
  final void Function(TrainStation) onItemTap;

  const TrainStationList(
      {Key? key, required this.stationData, required this.onItemTap})
      : super(key: key);

  @override
  _TrainStationListState createState() => _TrainStationListState();
}

class _TrainStationListState extends State<TrainStationList> {
  String query = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var filteredList = widget.stationData
        .where((station) =>
            station.stationName.toUpperCase().contains(query.toUpperCase()) ||
            station.city.toUpperCase().contains(query.toUpperCase()))
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: false,
                  decoration: generateInputDecoration(
                      outlineBorder: true,
                      // color: Colors.grey,
                      hint: 'Cari Stasiun (${widget.stationData.length})'
                      // suffixIcon: IconButton(
                      //   color: Colors.white,
                      //   icon: const Icon(Icons.add_circle_outline_sharp),
                      //   onPressed: () {},
                      // ),
                      ),
                  onChanged: (value) {
                    query = value;
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    var data = filteredList[index];
                    return ListTile(
                      onTap: () async {
                        await popScreen(context);
                        widget.onItemTap(data);
                      },
                      title: Text(
                          '${data.stationName} (${data.code}) - ${data.city}'),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
