import 'package:flutter/material.dart';

class MiliAppBar extends AppBar {
  MiliAppBar() : super(
      elevation: 0.25,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      flexibleSpace: _buildAppBar()
  );

  static Widget _buildAppBar(){
      return Container(
        padding: EdgeInsets.only(left: 0, right: 0),
        // child: Consumer<ConnectivityChangeNotifier>(builder: (BuildContext context,
        //     ConnectivityChangeNotifier connectivityChangeNotifier,
        //     Widget child) {
        //   return ListView(
        //     children: [
        //       connectivityChangeNotifier.errmsg(connectivityChangeNotifier.pageText,connectivityChangeNotifier.showAlert),
        //       MiliAppBar().topheader(context),
        //     ],
        //   );
        // }
        // ),
        child: MiliAppBar().topheader(),
      );
  }

  Widget topheader(){
    return Container(
        height: 120,
        // color: Theme.of(context).primaryColor,
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
        margin: EdgeInsets.only(bottom: 5.0),
        /*decoration: BoxDecoration(
        gradient : LinearGradient(
            begin: Alignment(-0.1,-0.3),
            end: Alignment(0.3259020447731018,-0.004678232595324516),
            colors: [Color.fromRGBO(63, 203, 233, 1),Color.fromRGBO(63, 203, 233, 1),Color.fromRGBO(80, 210, 238, 1)]
        ),
      ),*/
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logomili.png', height: 50.0,width: 100.0,)
          ],
        )
    );
  }
}
