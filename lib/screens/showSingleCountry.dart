import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:persian_date/persian_date.dart';

class ShowSingleCountry extends StatefulWidget {
  final Map county;

  ShowSingleCountry({this.county});

  @override
  _ShowSingleCountryState createState() => _ShowSingleCountryState();
}

class _ShowSingleCountryState extends State<ShowSingleCountry> {
  List countries = new List();
  List items = new List();
  bool loading = true;
  var toDate;
  DateTime date=DateTime.now();
  var from;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toDate=DateTime.now().toString().split(" ")[0].toString();
    from=new DateTime(date.year, date.month - 1, date.day).toString().split(" ")[0];

    _setData();
  }

  @override
  Widget build(BuildContext context) {

    print(from);
    print(toDate);
    return Directionality(textDirection: TextDirection.rtl,child:  Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                  title: new Text('${widget.county['persianName']}'),
                  backgroundColor: Colors.indigo,
                  pinned: true,
                  actions: [
                    new Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Image.asset("assets/flags/${widget.county['ISO2'].toLowerCase()}.png",width: 60,height: 60,),
                    ),
                  ]
              )
            ];
          },
          body: _buildBody()),
    ),);
  }

  Widget _buildBody() {
    if (loading) {
      return SpinKitRotatingCircle(
        color: Colors.indigo,
        size: 60.0,
      );
    }
    return new Container(
      child: new Column(
        children: [
          new Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  var country = items[index];
                  if(index==0){
                    return Container();
                  }
                  String dayDeaths;
                  String dayConfirmed;
                  dayDeaths=(country['Deaths']-items[index-1]['Deaths']).toString();
                  dayConfirmed=(country['Confirmed']-items[index-1]['Confirmed']).toString();
                  PersianDate persianDate = PersianDate();
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: new Material(
                      elevation: 3,
                      shadowColor: Colors.indigo.withOpacity(0.3),
                      child: new ListTile(
                        title:new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text('مبتلایان‌جدید: $dayConfirmed',style: new TextStyle(
                                fontSize: 13
                            ),),
                            new Text(
                                'بیماران‌فعال: ${country['Active']}',style: new TextStyle(
                                fontSize: 13
                            ),),
                            new Text(
                                'جان‌باختگان: $dayDeaths',style: new TextStyle(
                                fontSize: 13
                            ),),
                          ],
                        ),
                        subtitle: new Text('تاریخ: ${persianDate.gregorianToJalali(country['Date'],"d-mm-yyyy")}',style: new TextStyle(
                          height: 1.8,

                        ),),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }


  void _setData() async {
    // https://developers.google.com/books/docs/overview
//    var url = 'https://api.covid19api.com/total/dayone/country/${widget.county['Country']}';
    var url =
        "https://api.covid19api.com/country/iran?from=${from}T00:00:00Z&to=${toDate}T00:00:00Z";



    // Await the http get response, then decode the json-formatted response.
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      countries = jsonResponse;
      items.addAll(jsonResponse);
      setState(() {
        loading = false;
      });
    } else {}
  }
}
