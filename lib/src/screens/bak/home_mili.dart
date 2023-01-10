// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/data/bak/mili_service.dart';
import 'package:miliv2/src/services/dark_theme_provider.dart';
import 'package:miliv2/src/services/size_config.dart';
import 'package:miliv2/src/theme/theme.dart';
import 'package:miliv2/src/widgets/mili_appbar.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<Homepage> {
  //Homepage({Key key, this.title}) : super(key:key);
  //final String title;
  List<MiliService> _miliServiceList = [];
  List<Widget> _listSaldo = [];
  int _currentPage = 0;
  String test = 'aaa';
  //List<MiliSaldo> _miliSaldoList = [];
  int selectedIndex = 0;
  String text = "Home";
  bool clickedCentreFAB = false;
  bool hideAppbar = false;

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollBottomBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  bool _show = true;

  late Future<List<MiliPromo>> _futurePromo = fetchPromo();

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
      text = buttonText;
    });
  }

  void showBottomBar() {
    setState(() {
      _show = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _show = false;
    });
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          hideBottomBar();
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          showBottomBar();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    myScroll();
    _miliServiceList.add(MiliService(
      image: Icons.electric_car,
      color: Colors.blue,
      title: 'Listrik',
      imageIcon: 'assets/icons/PLN.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'Tagihan',
      imageIcon: 'assets/icons/Tagihan.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'Pulsa',
      imageIcon: 'assets/icons/Pulsa.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'BPJS',
      imageIcon: 'assets/icons/BPJS.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'e-Money',
      imageIcon: 'assets/icons/E-money.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'Cicilan',
      imageIcon: 'assets/icons/Cicilan.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'Telkom',
      imageIcon: 'assets/icons/Telkom.png',
    ));
    _miliServiceList.add(MiliService(
      image: Icons.directions_bike,
      color: Colors.blue,
      title: 'More',
      routeName: '/more',
      imageIcon: 'assets/icons/More.png',
    ));
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<DarkThemeProvider>(context);
    final PageController _pageController = PageController(initialPage: 0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(-0.29653486609458923, -0.3259020447731018),
            end: Alignment(0.3259020447731018, -0.004678232595324516),
            colors: [
              Color.fromRGBO(63, 203, 233, 1),
              Color.fromRGBO(63, 203, 233, 1),
              Color.fromRGBO(139, 234, 255, 1)
            ]),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0), //// here the desired height
            child: MiliAppBar(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _show
              ? FloatingActionButton(
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  backgroundColor: Color(0xff00A3FF),
                  tooltip: "Centre FAB",
                  child: Container(
                    margin: EdgeInsets.all(1.0),
                    child: Image.asset('assets/images/logonavbar.png'),
                  ),
                  elevation: 4.0,
                )
              : null,
          bottomNavigationBar: _show ? bottomBar(_pageController) : null,
          // body: Container(
          //   padding: EdgeInsets.only(top:0,bottom: 1),
          //   color: Theme.of(context).primaryColor,
          //   child: Consumer<ConnectivityChangeNotifier>(builder:(BuildContext context, ConnectivityChangeNotifier connectivityChangeNotifier, Widget child) {
          //     return PageView(
          //       scrollDirection: Axis.horizontal,
          //       controller: _pageController,
          //       onPageChanged: (index){
          //         //if (index!=1){
          //           updateTabSelection(index-1, "page "+index.toString());
          //         //}
          //       },
          //       children: [
          //         homeScreen(themeProvider),
          //         Center(
          //           child: Text('First Page '+text),
          //         ),
          //         Center(
          //           child: Text('Second Page '+text),
          //         ),
          //         Center(
          //           child: Text('Third Page '+text),
          //         ),
          //         Center(
          //           child: Text('Fourt Page '+text),
          //         )
          //       ],
          //     );
          //   }),
          // )
        ),
      ),
    );
  }

  Widget saldoVersi3(DarkThemeProvider themeProvider) {
    return Container(
      width: getProportionateScreenWidth(350),
      height: 120,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      //padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff0196DD), Color(0xff01C9D0)])),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, //Center Row contents horizontally,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
              padding: EdgeInsets.only(top: 2), child: Text('OKEE')
              // child: DotsIndicator(
              //   dotsCount: _listSaldo.length>1?_listSaldo.length:1,
              //   position: _currentPage.toDouble(),
              //   axis: Axis.vertical,
              //   decorator: DotsDecorator(
              //     color: Colors.lightBlueAccent,
              //     activeColor: Colors.white,
              //     activeSize: Size.square(5.0),
              //     size: Size.square(5.0),
              //     shape: RoundedRectangleBorder(),
              //     activeShape: RoundedRectangleBorder(),
              //   ),
              // )
              ),
          saldoSlide(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          themeProvider.darkTheme = !themeProvider.darkTheme;
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(10, 10),
                          elevation: 1,
                          primary: Color.fromRGBO(0, 173, 210, 1),
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                      Text(
                        "Topup",
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //generate();
                        },
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          minimumSize: Size(10, 10),
                          primary: Color.fromRGBO(0, 173, 210, 1),
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.white, width: 1)),
                        ),
                      ),
                      Text(
                        "Transfer",
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(10, 10),
                          elevation: 1,
                          primary: Color.fromRGBO(0, 173, 210, 1),
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.white, width: 1)),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "History",
                        style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                            color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget saldoSlide() {
    var idx = 1;
    return Container(
        padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
        width: 180,
        height: 120,
        child: FutureBuilder(
          future: refreshBalance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // return CarouselSlider(
              //   options: CarouselOptions(
              //       onPageChanged: (index, reason) {
              //         setState(() {
              //           _currentPage = index;
              //         });
              //       },
              //       scrollDirection: Axis.vertical,
              //       enlargeCenterPage: true
              //   ),
              //   items: _listSaldo
              // );
            }
            return SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  Widget saldoContent() {
    return Container(
        padding: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 28.0,
                    width: 28.0,
                    alignment: Alignment.centerLeft,
                    child: new Icon(
                      IconData(0xe041, fontFamily: 'MaterialIcons'),
                      color: AppTheme.miliLightBlue,
                      size: 16.0,
                    ),
                  ),
                  Container(
                    child: new Text(
                      "Saldo",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Text(
                          "Rp.",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black,
                              fontFamily: 'Montserrat'),
                        ),
                        Text(
                          "200.000.000",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                //mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Saldo Kredit",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: AppTheme.miliLightBlue,
                        fontFamily: 'Montserrat'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Text(
                          "Rp.",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black,
                              fontFamily: 'Montserrat'),
                        ),
                        Text(
                          "100.000.000",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppTheme.miliLightBlue,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  Widget saldoSlideContent(MiliSaldo data) {
    // var formater = NumberFormat('#,###,###');
    return Container(
        padding: EdgeInsets.only(left: 10.0),
        //width: getProportionateScreenWidth(10),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 28.0,
                  width: 28.0,
                  alignment: Alignment.centerLeft,
                  child: new Icon(
                    IconData(0xe041, fontFamily: 'MaterialIcons'),
                    color: AppTheme.miliLightBlue,
                    size: 16.0,
                  ),
                ),
                Container(
                  child: new Text(
                    data.title!,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Montserrat'),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Rp.",
                  style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.black,
                      fontFamily: 'Montserrat'),
                ),
                Text(
                  // formater.format(data.saldoValue),
                  '20.123.123',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Tap for history",
                    style: TextStyle(
                        fontSize: 10.0,
                        color: AppTheme.miliLightBlue,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget saldo2(BuildContext context) {
    return Stack(
      children: [
        new Column(
          children: <Widget>[
            new Container(
              height: MediaQuery.of(context).size.height * .13,
              decoration: BoxDecoration(
                  //color: Color.fromRGBO(80, 210, 238, 1)
                  gradient: LinearGradient(
                      begin: Alignment(-0.1, -0.3),
                      end: Alignment(0.3259020447731018, -0.004678232595324516),
                      colors: [
                    Color.fromRGBO(63, 203, 233, 1),
                    Color.fromRGBO(63, 203, 233, 1),
                    Color.fromRGBO(80, 210, 238, 1)
                  ])),
            ),
            new Container(
              height: MediaQuery.of(context).size.height * .05,
              color: Colors.white,
            )
          ],
        ),
        // The card widget with top padding,
        // incase if you wanted bottom padding to work,
        // set the `alignment` of container to Alignment.bottomCenter
        Container(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 28.0,
                      width: 28.0,
                      alignment: Alignment.centerLeft,
                      child: new Icon(
                        IconData(0xe041, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                        size: 16.0,
                      ),
                    ),
                    Container(
                      child: new Text(
                        "Saldo",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Rp.",
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.white,
                                fontFamily: 'Montserrat'),
                          ),
                          Text(
                            "100.000.000",
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Saldo Kredit ",
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.white,
                                fontFamily: 'Montserrat'),
                          ),
                          Text(
                            "150.000.000",
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.yellowAccent,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
        Container(
          alignment: Alignment.topCenter,
          padding: new EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .08,
              right: 20.0,
              left: 20.0),
          child: Container(
            height: 80.0,
            width: MediaQuery.of(context).size.width,
            child: new Card(
              color: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Icon(
                          Icons.add,
                          color: Color(0xffb00C2FF),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          primary: Colors.white,
                          shape: CircleBorder(
                              side: BorderSide(color: Color(0xffb00C2FF))),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "Topup",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Montserrat',
                            color: Color(0xffb00C2FF)),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Icon(
                          Icons.arrow_upward,
                          color: Color(0xffb00C2FF),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          primary: Colors.white,
                          shape: CircleBorder(
                              side: BorderSide(color: Color(0xffb00C2FF))),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "Transfer",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Montserrat',
                            color: Color(0xffb00C2FF)),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Icon(
                          Icons.history,
                          color: Color(0xffb00C2FF),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          primary: Colors.white,
                          shape: CircleBorder(
                              side: BorderSide(color: Color(0xffb00C2FF))),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        "History",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Montserrat',
                            color: Color(0xffb00C2FF)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget saldo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(-0.29653486609458923, -0.3259020447731018),
            end: Alignment(0.3259020447731018, -0.004678232595324516),
            colors: [
              Color.fromRGBO(63, 203, 233, 1),
              Color.fromRGBO(63, 203, 233, 1),
              Color.fromRGBO(139, 234, 255, 1)
            ]),
      ),
    );
  }

  Widget _buildMiliServiceMenu() {
    return SizedBox(
      width: double.infinity,
      height: 220.0,
      child: Container(
        margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
        //color: Colors.blue,
        child: GridView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _miliServiceList.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemBuilder: (context, position) {
              return _rowGojekService(_miliServiceList[position]);
            }),
      ),
    );
  }

  Widget _rowGojekService(MiliService _miliService) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_miliService.routeName == '/more') {
                // showModalBottomSheet(
                //   isScrollControlled: true,
                //   backgroundColor: Colors.transparent,
                //   context: context,
                //   builder: (context){
                //     // return MiliFeatured();
                // });
              } else {
                Navigator.pushNamed(context, _miliService.routeName!);
              }
            },
            child: Container(
              width: 69,
              height: 69,
              decoration: BoxDecoration(
                  //border: Border.all(color: Colors.grey, width: 1.0),
                  //borderRadius: BorderRadius.all(Radius.circular(20.0))
                  color: Color.fromRGBO(250, 250, 250, 1),
                  borderRadius: BorderRadius.all(Radius.elliptical(69, 69))),
              padding: EdgeInsets.all(12.0),
              child: Image.asset(_miliService.imageIcon!),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 6.0)),
          Text(
            _miliService.title!,
            style: TextStyle(fontSize: 10.0),
          )
        ],
      ),
    );
  }

  Widget _rowMiliFeatured(MiliPromo promo) {
    return Container(
      margin: EdgeInsets.only(right: 10.0, bottom: 10.0, top: 5.0, left: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(15.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/browser',
                  arguments: ScreenArguments(
                    promo.title!,
                    promo.image!,
                  ),
                );
              },
              child: FadeInImage(
                image: NetworkImage(promo.image!),
                placeholder: AssetImage("assets/images/promo/promo_1.jpg"),
                width: getProportionateScreenWidth(300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowMiliFeaturedVertical(MiliNews news) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color.fromRGBO(250, 250, 250, 1),
      ),
      padding: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              news.image!,
              width: getProportionateScreenWidth(300),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiliFeatured() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Promo",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          Divider(),
          SizedBox(
            height: getProportionateScreenHeight(150),
            child: FutureBuilder<List>(
              future: _futurePromo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data?.length,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Text('DUMMY');
                        // return _rowMiliFeatured(snapshot.data?[index]);
                      });
                }
                return Center(
                  child: SizedBox(
                    width: 10.0,
                    height: 10.0,
                    child: const CircularProgressIndicator(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiliFeatured2() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Promo hari ini",
            style: TextStyle(
                fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
          ),
          Container(
            //height: getProportionateScreenHeight(200),
            child: FutureBuilder<List>(
              future: fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> _listPromo = [];
                  var pjg = snapshot.data?.length;
                  for (var i = 0; i < pjg!; i++) {
                    // _listPromo.add(_rowPromo(snapshot.data?[i]));
                  }
                  return Column(
                    children: _listPromo,
                  );
                }
                return Center(
                  child: SizedBox(
                    width: 10.0,
                    height: 10.0,
                    child: const CircularProgressIndicator(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<List<MiliPromo>> fetchPromo() async {
    // // SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<MiliPromo> _miliPromoList = [];
    // var jsonResponse = "";
    // var bannerUrl = "http://180.250.247.164:3000/api/active-banners";
    // var serverUrl = "http://180.250.247.164:3000/";
    // // String? _token = prefs.getString("token");
    // Map<String, String> requestHeaders = {
    //   'Content-type': 'application/json',
    //   // 'Device': MiliGlobal.uniqueId,
    //   // 'Authorization': 'Bearer '+_token!
    // };
    //
    // var response = await http.get(Uri.parse(bannerUrl), headers: requestHeaders);
    // if(response.statusCode == 200) {
    //   jsonResponse = json.decode(response.body).toString();
    //   if(jsonResponse != null) {
    //     // BannerData _dataBanner = BannerData.fromJson(jsonResponse);
    //     // _dataBanner.data.map((i){
    //     //   String _imgLink = serverUrl+i.url;
    //     //   _miliPromoList.add(MiliPromo(title: i.title, image: _imgLink));
    //     // }).toList();
    //   }else{
    //     print("a");
    //   }
    // }else{
    //   print("b");
    // }
    return Future.delayed(Duration(seconds: 1), () {
      // return _miliPromoList;
      return [];
    });
  }

  Future<List<MiliSaldo>> refresh() async {
    List<MiliSaldo> _miliSaldoList = [];
    return _miliSaldoList;
  }

  Future<List<MiliSaldo>> refreshBalance() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MiliSaldo> _miliSaldoList = [];
    List<Widget> _saldo = [];
    // // var jsonResponse = null;
    // var loginUrl = "http://180.250.247.164:3000/api/balance";
    // // String? _token = prefs.getString("token");
    // Map<String, String> requestHeaders = {
    //   'Content-type': 'application/json',
    //   // 'Device': MiliGlobal.uniqueId,
    //   // 'Authorization': 'Bearer '+_token!
    // };
    // var response = await http.get(Uri.parse(loginUrl), headers: requestHeaders);
    // if(response.statusCode == 200) {
    //   // jsonResponse = json.decode(response.body);
    //   // if(jsonResponse != null) {
    //   //   print(response.body);
    //   //   BalanceData _balancedata = BalanceData.fromJson(jsonResponse);
    //   //   _miliSaldoList.add(MiliSaldo(title: "Saldo Utama", iconData: IconData(0xe041, fontFamily: 'MaterialIcons'),saldoValue:_balancedata.available_balance));
    //   //   _miliSaldoList.add(MiliSaldo(title: "Saldo Kredit", iconData: IconData(0xe041, fontFamily: 'MaterialIcons'),saldoValue:_balancedata.balanceCredit));
    //   //   _miliSaldoList.forEach((element) {
    //   //     _saldo.add(saldoSlideContent(element));
    //   //   });
    //   //   _listSaldo = _saldo;
    //   // }else {
    //   // }
    // }else{
    // }
    return _miliSaldoList;
  }

  Future<List<MiliSaldo>> fetchSaldo() async {
    List<MiliSaldo> _miliSaldoList = [];
    List<Widget> _saldo = [];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? _userData = prefs.getString("userdata");
    // LoginData _loginData = LoginData.fromJson(jsonDecode(_userData!));
    // print("aaaaa");
    // print(_loginData.user.balance);
    // print(_loginData.user.balanceCredit);
    // _miliSaldoList.add(MiliSaldo(title: "Saldo Utama", iconData: IconData(0xe041, fontFamily: 'MaterialIcons'),saldoValue:_loginData.user.balance));
    // _miliSaldoList.add(MiliSaldo(title: "Saldo Kredit", iconData: IconData(0xe041, fontFamily: 'MaterialIcons'),saldoValue:_loginData.user.balanceCredit));
    // _miliSaldoList.forEach((element) {
    //   _saldo.add(saldoSlideContent(element));
    // });

    _listSaldo = _saldo;
    return Future.delayed(Duration(seconds: 1), () {
      return _miliSaldoList;
    });
  }

  Future<List<MiliNews>> fetchNews() async {
    List<MiliNews> _newsList = [];
    _newsList.add(new MiliNews(
        image: "assets/images/promo/promo_1.jpg",
        title: "Bayar PLN dan BPJS, dapat cashback 10%",
        content:
            "Nikmatin cashback 10% untuk pembayaran PLN, BPJS, Google Voucher dan tagihan lain di GO-BILS.",
        button: "MAU!"));
    _newsList.add(new MiliNews(
        image: "assets/images/promo/promo_1.jpg",
        title: "#CeritaGojek",
        content:
            "Berulang kali terpuruk tak menghalanginya untuk bangkit dan jadi kebanggan kami, Simak selengkapnya disini.",
        button: "SELENGKAPNYA"));
    _newsList.add(new MiliNews(
        image: "assets/images/promo/promo_1.jpg",
        title: "GOJEK Ultah Ke 8",
        content:
            "8 Tahun berdiri ada satu alasan kami tetap tumbuh dan berinovasi. Satu yang buat kami untuk terus berinovasi",
        button: "CARI TAU!"));
    _newsList.add(new MiliNews(
        image: "assets/images/promo/promo_1.jpg",
        title: "Gratis Pulsa 100rb*",
        content:
            "Aktifkan 10 Voucher GO-PULSAmu sekarang biar ngabarin yang terdekat gak pakai terhambat.",
        button: "LAKSANAKAN"));
    return new Future.delayed(new Duration(seconds: 3), () {
      return _newsList;
    });
  }

  Widget homeScreen(DarkThemeProvider themeProvider) {
    return RefreshIndicator(
        onRefresh: refreshBalance,
        child: ListView(
          controller: _scrollBottomBarController,
          physics: ClampingScrollPhysics(),
          children: [
            saldoVersi3(themeProvider),
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              color: Theme.of(context).primaryColor,
              child: _buildMiliServiceMenu(),
            ),
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0),
              color: Theme.of(context).primaryColor,
              child: _buildMiliFeatured(),
            ),
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0),
              color: Theme.of(context).primaryColor,
              child: _buildMiliFeatured2(),
            )
          ],
        ));
  }

  Widget bottomBar(PageController _pageController) {
    return Transform.translate(
      offset: Offset(0.0, 0.0),
      child: Container(
        //margin: EdgeInsets.only(left: 20, right: 20),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Theme.of(context).backgroundColor,
            child: Container(
              height: 60.0,
              margin: EdgeInsets.only(left: 12.0, right: 12.0),
              //color: Theme.of(context).backgroundColor,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        updateTabSelection(0, "Home");
                        if (_pageController.hasClients) {
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.home,
                        //darken the icon if it is selected or else give it a different color
                        color: selectedIndex == 0
                            ? Colors.blue.shade900
                            : Colors.grey.shade400,
                      )),
                  IconButton(
                    onPressed: () {
                      updateTabSelection(1, "Outgoing");
                      if (_pageController.hasClients) {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      Icons.call_made,
                      color: selectedIndex == 1
                          ? Colors.blue.shade900
                          : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                  ),
                  IconButton(
                    onPressed: () {
                      updateTabSelection(2, "Incoming");
                      if (_pageController.hasClients) {
                        _pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      Icons.call_received,
                      color: selectedIndex == 2
                          ? Colors.blue.shade900
                          : Colors.grey.shade400,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      updateTabSelection(3, "Settings");
                      if (_pageController.hasClients) {
                        _pageController.animateToPage(
                          4,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    iconSize: 27.0,
                    icon: Icon(
                      Icons.settings,
                      color: selectedIndex == 3
                          ? Colors.blue.shade900
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromo() {
    List<Widget> data = [];
    return new Container(
        //margin: EdgeInsets.all(10.0),
        child: FutureBuilder(
      future: fetchNews(),
      builder: (context, AsyncSnapshot<List> snapshot) => snapshot.hasData
          ? ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Text("a");
              })
          : Center(
              child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: const CircularProgressIndicator()),
            ),
    ));
  }

  Widget _rowPromo(MiliNews milinews) {
    return Container(
      height: 320.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(bottom: 16.0),
            width: double.infinity,
            height: 1.0,
            color: AppTheme.miligrey200,
          ),
          new ClipRRect(
            borderRadius: new BorderRadius.circular(8.0),
            child: new Image.asset(
              milinews.image!,
              height: 172.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 16.0),
          ),
          new Text(
            milinews.title!,
            style: new TextStyle(fontFamily: "NeoSansBold", fontSize: 16.0),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 8.0),
          ),
          new Text(
            milinews.content!,
            maxLines: 2,
            softWrap: true,
            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 6.0),
          ),
          new Container(
            alignment: Alignment.centerRight,
            child: new MaterialButton(
              color: AppTheme.miliLightBlue,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/browser',
                  arguments: ScreenArguments(
                    milinews.title!,
                    milinews.content!,
                  ),
                );
              },
              child: new Text(
                milinews.button!,
                style: new TextStyle(
                    color: Colors.white,
                    fontFamily: "NeoSansBold",
                    fontSize: 12.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
