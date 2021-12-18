import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../constants.dart';
import '../models/carousel_model.dart';
import '../env.dart';
import '../models/operation_model.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _current = 0;
  int current = 0;

  int siswa = 0;
  int guru = 0;
  int matpel = 0;
  String _name;
  String _email;

  void initState() {
      super.initState();
      getUser();
      getData();
  }

  void getData() async {
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}"));
    final data = json.decode(response.body)['data'];
    print(data);
    setState(() {
      siswa = data['siswa'];
      guru = data['guru'];
      matpel = data['matpel'];
    });
  }

  void getUser() async {
    final pref = await SharedPreferences.getInstance();
    var name = pref.getString('nama');
    var email = pref.getString('email');
    setState(() {
      _name = name;
      _email = email;
    });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            // Promos Section
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 24,top: 50),
              child: Text(
                "Hi, $_email 👋",
                style: mTitleStyle,
              ),
            ),

            Container(
                    margin: EdgeInsets.only(right: 10,left: 10,top: 5),
                    height: 199,
                    width: 344,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Color(0xFF1E1E99)),
                    child: Stack(
                      children: [
                        Positioned(
                          child: SvgPicture.asset('assets/svg/ellipse_top_pink.svg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child:
                              SvgPicture.asset('assets/svg/ellipse_bottom_pink.svg'),
                        ),
                        Positioned(
                          top: 24,
                          left: 24,
                          child: Image(
                            image: AssetImage('assets/images/logo_putih.png'),
                            width: 130,
                          ) 
                        ),
                        Positioned(
                          right: 21,
                          top: 35,
                          child: Text("$_name", 
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),)
                        ),
                        Positioned(
                          right: 30,
                          top: 90,
                          child: Text(
                            'SMK SAHID JAKARTA',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ),
                        Positioned(
                          right: 30,
                          bottom: 35,
                          child: Text(
                            'Multimedia',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

            // Service Section
           Padding(
              padding: const EdgeInsets.only(
                  top: 29, bottom: 13, left: 16, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operation',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A3A)),
                  ),
                  Row(
                    children: map<Widget>(
                      datas,
                      (index, selected) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          height: 9,
                          width: 9,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: current == index
                                  ? Color(0xFF1E1E99)
                                  : Color(0x201E1E99)),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 123,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                      },
                      child: OperationCard(
                        operation: "Mata \n Pelajaran",
                        count: matpel.toString(),
                        context: this,
                      ),
                    ),
                  GestureDetector(
                      onTap: () {
                      },
                      child: OperationCard(
                        operation: "Guru",
                        count: guru.toString(),
                        context: this,
                      ),
                    ),
                  GestureDetector(
                      onTap: () {
                      },
                      child: OperationCard(
                        operation: "Siswa",
                        count: siswa.toString(),
                        context: this,
                      ),
                    ),
                ],
              )
            ),

            Container(
                    margin: EdgeInsets.only(right: 10,left: 10,top: 30),
                    height: 199,
                    width: 344,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Color(0xFF1E1E99)),
                    child: Stack(
                      children: [
                        Positioned(
                          child: SvgPicture.asset('assets/svg/ellipse_top_pink.svg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child:
                              SvgPicture.asset('assets/svg/ellipse_bottom_pink.svg'),
                        ),
                        Positioned(
                          right: 160,
                          top: 60,
                          child: Text("SMK Sahid Jakarta", 
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),)
                        ),
                        Positioned(
                          right: 80,
                          top: 90,
                          child: Text(
                            'Reaching a Better Future',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
            
            // Popular Destination Section
          ],
        ),
    );
  }
}


class OperationCard extends StatefulWidget {
  final String operation;
  final String count;
  final color;
  final bool isSelected;
  _DashboardState context;

  OperationCard(
      {this.operation,
      this.count,
      this.color,
      this.isSelected,
      this.context});

  @override
  _OperationCardState createState() => _OperationCardState();
}

class _OperationCardState extends State<OperationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4,left: 6),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0x10000000),
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(10.0, 10.0)),
          ],
          borderRadius: BorderRadius.circular(15),
          color: Colors.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text((widget.count != null) ? widget.count : '0', style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
          SizedBox(
            height: 3,
          ),
          Text(
            widget.operation,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          )
        ],
      ),
    );
  }
}