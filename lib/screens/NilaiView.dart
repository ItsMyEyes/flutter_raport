import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_login_register_ui/screens/screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';
import '../constants.dart';
import '../models/carousel_model.dart';
import 'manageKelas/index.dart';
import '../models/operation_model.dart';
import 'manageUser/screen_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../env.dart';
import 'cetakRaport.dart';
import './nilai/index.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'cas/index.dart';

class NilaiView extends StatefulWidget {
  @override
  _NilaiViewState createState() => _NilaiViewState();
}

class _NilaiViewState extends State<NilaiView> {
  TextEditingController controllerSemester = new TextEditingController();
  TextEditingController controllerNis = new TextEditingController();

  var _kelas = []; 
  var _matpel = [];
  int _current = 0;
  int current = 0;
  String kelas;
  bool wali_kelas = false;
  String matpel;
  
  String _name;
  String _email;

  void initState() {
      super.initState();
      getUser();
      getKelas();
      getData();
  }
  
  static Future<File> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('/storage/emulated/0/Documents/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void cetakRaport() async {
    EasyLoading.show(status: 'checking permission and downloading...');
    final pref = await SharedPreferences.getInstance();
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/nilai/pdf?nis=${controllerNis.text}&ta=${pref.getString('ta')}&semester=${controllerSemester.text}")); 
    print(data.body);
    if (data.statusCode == 200) {
      final resp = json.decode(data.body);
      cetak(resp['link']);
      EasyLoading.showSuccess('Raport berhasil didownload, dan tersimpan didocument');
    } else {
      EasyLoading.showError('Gagal Mencetak PDF');
    }
    EasyLoading.dismiss();
  }

// 
  void cetakAjaDah() async {
    EasyLoading.show(status: 'checking permission and downloading...');
    final pref = await SharedPreferences.getInstance();
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/nilai/pdf/cetak/lagger?matpel=${matpel.toString()}&id_kelas=${kelas}&ta=${pref.getString('ta')}&semester=${controllerSemester.text}")); 
    print(data.body);
    if (data.statusCode == 200) {
      final resp = json.decode(data.body);
      cetak(resp['link']);
      EasyLoading.showSuccess('Raport berhasil didownload, dan tersimpan didocument');
    } else {
      EasyLoading.showError('Gagal Mencetak PDF / Kemungkinan Belum ada nilai');
    }
    EasyLoading.dismiss();
  }

  void cetakReport() async {
    EasyLoading.show(status: 'checking permission and downloading...');
    final pref = await SharedPreferences.getInstance();
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/nilai/pdf/cetak/rangking?kelas=${kelas}&ta=${pref.getString('ta')}&semester=${controllerSemester.text}")); 
    print("${Env.URL_PREFIX}/nilai/pdf/cetak/rangking?kelas=${kelas}&ta=${pref.getString('ta')}&semester=${controllerSemester.text}");
    final s = json.decode(data.body);
    if (data.statusCode == 200) {
      cetak(s['link']);
      EasyLoading.showSuccess('Raport berhasil didownload, dan tersimpan didocument');
    } else {
      EasyLoading.showError('Gagal Mencetak PDF');
    }
    EasyLoading.dismiss();
  }

  void getData() async{
    EasyLoading.show(status: 'getting matpel...');
    final pref = await SharedPreferences.getInstance();
    final checking = await http.get(Uri.parse("${Env.URL_PREFIX}/matpel/get/mapping?ta=${pref.getString('ta')}"));
    print(json.decode(checking.body)['data']);
    _matpel = json.decode(checking.body)['data'];
    EasyLoading.dismiss();
  }

  void getKelas() async {
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'Getting data...');
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/kelas?ta=${pref.getString('ta')}"));
    _kelas = json.decode(data.body)['data'];
    EasyLoading.dismiss();
  }

  void setKelas(item) {
    setState(() {
          kelas = item;
        });
  }
  void setMatpel(item) {
    setState(() {
          matpel = item;
        });
  }

  void cetak(url) async => await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  void getUser() async {
    final pref = await SharedPreferences.getInstance();
    var name = pref.getString('nama');
    var akses = pref.getString('akses');
    var email = pref.getString('email');
    setState(() {
      _name = name;
      _email = email;
      wali_kelas = (akses == 'wali_kelas') ? true : false;
    });
    print(wali_kelas);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,CupertinoPageRoute(builder: (context) => GuruScreen()));
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: AssetImage('assets/images/back_arrow.png'),
          ),
        ),
      ),
      body: Container(
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
              "Management raport.",
              style: kHeadline,
            ),),
            Center(
              child: Text(
                "mari kita manage raport!",
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
                     showModalBottomSheet(
                      enableDrag: true,
                      isDismissible: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      barrierColor: Colors.black.withOpacity(0.2),
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Visibility(
                            visible: wali_kelas,
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Cetak Raport'),
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
                                            buildTextField("nis","nis",controllerNis),
                                            buildTextField("Semester","Semester",controllerSemester),
                                            RaisedButton(
                                                onPressed: () { 
                                                  (controllerSemester.text != null && controllerNis.text != null) ?
                                                  cetakRaport()
                                                  :
                                                  EasyLoading.showError('Pilih kelas dan semester terlebih dahulu');
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
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                              },
                            ),
                          ),
                          // 1ini
                          ListTile(
                            leading: Icon(Icons.report),
                            title: Text('Cetak Lagger 1 Matpel'),
                            onTap: () => {
                                showModalBottomSheet(context: context, builder: (BuildContext bc) {
                                    return Container(
                                      color: Color(0xff757575),
                                      height: MediaQuery.of(context).size.height * .6,
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
                                                  labelText: 'Matpel',
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
                                                    value: matpel,
                                                    items: _matpel.map((item) {
                                                      return DropdownMenuItem(
                                                        value: item['id_matpel'].toString(),
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 3),
                                                          child: Text(item['matpel']['nama'] + " (" + item['guru']['nama'] + ")", style: kBodyText),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (selectedItem) => { setMatpel(selectedItem) },
                                                  ),
                                                ),
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
                                            buildTextField("Semester","Semester",controllerSemester),
                                            RaisedButton(
                                                onPressed: () { 
                                                  (controllerSemester.text != null) ?
                                                  cetakAjaDah()
                                                  :
                                                  EasyLoading.showError('Pilih kelas dan semester terlebih dahulu');
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
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                            },
                          ),
                          // 2ini
                          Visibility(
                            visible: wali_kelas,
                            child: ListTile(
                            leading: Icon(Icons.report),
                            title: Text('Cetak report nilai'),
                            onTap: () => {
                                showModalBottomSheet(context: context, builder: (BuildContext bc) {
                                    return Container(
                                      color: Color(0xff757575),
                                      height: MediaQuery.of(context).size.height * .6,
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
                                            buildTextField("Semester","Semester",controllerSemester),
                                            RaisedButton(
                                                onPressed: () { 
                                                  (controllerSemester.text != null) ?
                                                  cetakReport()
                                                  :
                                                  EasyLoading.showError('Pilih kelas dan semester terlebih dahulu');
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
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                            },
                          ),
                          ),
                          // 3ini
                        ],
                      ),
                    )
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
                              'Cetak Dokumen',
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
                  //nanti
                  GestureDetector(
                    onTap: () => {
                      showModalBottomSheet(
                      enableDrag: true,
                      isDismissible: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      barrierColor: Colors.black.withOpacity(0.2),
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Input Nilai'),
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
                                            buildTextField("Semester","Semester",controllerSemester),
                                            RaisedButton(
                                                onPressed: () { 
                                                  (kelas != null && controllerNis.text != null) ? Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) => NilaiIndex(id_kelas: kelas,semester: controllerSemester.text,),
                                                  ))  :   EasyLoading.showError('Pilih kelas dan semester terlebih dahulu');
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
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                              },
                            ),
                          Visibility(
                            visible: wali_kelas,
                            child: ListTile(
                            leading: Icon(Icons.edit_attributes),
                            title: Text('Input cas dan prakerin'),
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
                                            buildTextField("Semester","Semester",controllerSemester),
                                            RaisedButton(
                                                onPressed: () { 
                                                  (kelas != null && controllerNis.text != null) ? Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) => CasIndex(id_kelas: kelas,semester: controllerSemester.text,),
                                                  ))  :   EasyLoading.showError('Pilih kelas dan semester terlebih dahulu');
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
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                            },
                          ),
                          )
                        ],
                      ),
                    )
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
                              'Input Data',
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
    ),
    );
  }
  

   Widget buildTextField(String labelText, String placeholder,controllerText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controllerText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black12,
            )),
      ),
    );
  }
}
