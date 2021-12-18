import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';
import '../constants.dart';
import '../models/carousel_model.dart';
import './manageKelas/index.dart';
import '../models/operation_model.dart';
import '../screens/manageUser/screen_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UserTata extends StatefulWidget {
  @override
  _UserTataState createState() => _UserTataState();
}

class _UserTataState extends State<UserTata> {
  var _kelas = []; 
  int _current = 0;
  int current = 0;
  String kelas;

  String _name;
  String _email;

  void initState() {
      super.initState();
      getUser();
      getKelas();
  }

  void getKelas() async {
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'Getting data...');
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/kelas?ta=${pref.getString('ta')}"));
    print(data.body);
    _kelas = json.decode(data.body)['data'];
    EasyLoading.dismiss();
  }

  void setKelas(item) {
    print(item);
    setState(() {
          kelas = item;
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
        padding: EdgeInsets.only(top: 120),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            // Promos Section
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image(
                  image:
                      AssetImage('assets/images/team_illustration.png'),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(child: Text(
              "Management User.",
              style: kHeadline,
            ),),
            Center(
              child: Text(
                "mari kita manage user!",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 40)),
            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => GuruIndex(),
                              ))
                    },
                    child: SizedBox(
                      width:150.0,
                      height: 150.0,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black45,
                                spreadRadius: 1.0,
                                blurRadius: 10.0,
                                offset: Offset(3.0, 3.0))
                          ],
                        color: Color(0xff453658), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(top: 12,)),
                            Image.asset(
                              'assets/images/note.png',
                              width: 42,
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              'Guru',
                              style: GoogleFonts.openSans(
                                  textStyle: TextStyle( 
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Padding(padding: EdgeInsets.only(top: 12)),
                          ],
                        ),
                      ),
                  ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      showModalBottomSheet(context: context, builder: (BuildContext bc) {
                        return Container(
                          color: Color(0xff757575),
                          height: MediaQuery.of(context).size.height * .4,
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  'Hello!!, Pilih kelas dahulu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    color: Colors.blue,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 3, right: 3,bottom: 10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Kelas',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        isDense: true, 
                                        dropdownColor: Colors.white,
                                        focusColor: Colors.black,
                                        iconEnabledColor: Colors.black,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        value: kelas,
                                        items: _kelas.map((item) {
                                          return DropdownMenuItem(
                                            value: item['kelas']['id'].toString(),
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text(item['kelas']['kelas'], style: kBodyText),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (selectedItem) => { setKelas(selectedItem) },
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                    onPressed: () { 
                                      (kelas != null) ? Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => SiswaIndex(id_kelas: kelas),
                                      ))  :   EasyLoading.showError('Pilih kelas terlebih dahulu');
                                    },
                                    color: Colors.green,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "SAVE",
                                      style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 2.2,
                                          color: Colors.white),
                                    ),
                                  ),
                                RaisedButton(
                                    onPressed: () { 
                                      Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => KelasIndex(),
                                      ));
                                    },
                                    color: Colors.green,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      "Buat Kelas",
                                      style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 2.2,
                                          color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      })
                    },
                    child: SizedBox(
                      width:150.0,
                      height: 150.0,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                              BoxShadow(
                                  color: Colors.black45,
                                  spreadRadius: 1.0,
                                  blurRadius: 10.0,
                                  offset: Offset(3.0, 3.0))
                            ],
                        color: Color(0xff453658), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(top: 12,)),
                            Image.asset(
                              'assets/images/note.png',
                              width: 42,
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              'Siswa',
                              style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Padding(padding: EdgeInsets.only(top: 12)),
                          ],
                        ),
                      ),
                  ),
                  )
                ],
              ),
            )
            // Popular Destination Section
          ],
        ),
    );
  }
}
