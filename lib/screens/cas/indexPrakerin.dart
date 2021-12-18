import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../env.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_login_register_ui/constants.dart';
import '../../models/prakerinModel.dart';
import 'index.dart';
import 'addEditPrakerin.dart';

class PrakerinIndex extends StatefulWidget {
  PrakerinIndex({this.nis,this.semester,this.nama_siswa,this.id_kelas});
  String nis;
  String nama_siswa;
  String semester;
  String id_kelas;
  @override
  _PrakerinIndexState createState() => _PrakerinIndexState();
}

class _PrakerinIndexState extends State<PrakerinIndex> {
  TextEditingController controllerSemester = new TextEditingController();
  TextEditingController controllerNis = new TextEditingController();

  var _kelas = []; 
  var _matpel = [];
  int _current = 0;
  int current = 0;
  String kelas;
  bool wali_kelas = false;
  int matpel;
  
  String _name;
  String _email;

  void initState() {
      super.initState();
  }

  Future<List<Prakerin>> getSiswa() async {
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    print("${Env.URL_PREFIX}/prakerin?nis=${widget.nis}&semester=${widget.semester}&ta=${pref.getString('ta')}");
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/prakerin?nis=${widget.nis}&semester=${widget.semester}&ta=${pref.getString('ta')}"), headers: requestHeaders);
    if (response.statusCode == 200) {
      return prakerinFromJson(response.body);
    } else {
      return null;
    }
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

  void getUser() async {
    final pref = await SharedPreferences.getInstance();
    var name = pref.getString('nama');
    var email = pref.getString('email');
    setState(() {
      _name = name;
      _email = email;
      wali_kelas = (pref.getString('akses') == 'wali_kelas') ? true : false;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: AssetImage('assets/images/back_arrow.png'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context,CupertinoPageRoute(builder: (context) => AddEditPrakerin(nis: widget.nis,semester: widget.semester,id_kelas: widget.id_kelas,)));
        },
      ),
      body: FutureBuilder(
            future: getSiswa(),
            builder: (BuildContext context, AsyncSnapshot<List<Prakerin>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Token is expired please login again"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.length > 0) {
                  List<Prakerin> gurus = snapshot.data;
                  return _buildListView(context,gurus,widget.id_kelas,widget.semester); 
                } else {
                  return Container(
                      child: Center(
                          child: Text("No data PKL...",
                          style: TextStyle(
                              fontFamily: 'regular',
                              fontSize: 18,
                              color: Colors.black),
                  )));
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
    );
  }
  

  Widget _buildListView(context,List<Prakerin> prakerins, kelas,semester) {
  var size = MediaQuery.of(context).size;
  return new Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListView.builder(
                      padding: EdgeInsets.only(top: 25, right: 25, left: 25),
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: prakerins.length,
                      itemBuilder: (context, index) {
                        Prakerin prakerin = prakerins[index];
                        return GestureDetector(
                          onTap: () {
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
                                      leading: Icon(Icons.block_outlined),
                                      title: Text('Edit'),
                                      onTap: () => {
                                        Navigator.push(context,CupertinoPageRoute(builder: (context) => AddEditPrakerin(id: prakerin.id,nis: widget.nis,semester: widget.semester,id_kelas: widget.id_kelas,)))
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.report),
                                      title: Text('Hapus'),
                                      onTap: () => {
                                        
                                      },
                                    ),
                                  ],
                                ),
                              );
                          },
                          onLongPress: () {

                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            padding: EdgeInsets.all(10),
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 17),
                                  blurRadius: 23,
                                  spreadRadius: -13,
                                  color: kShadowColor,
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                // SvgPicture.asset(
                                //   "assets/images/Meditation_women_small.svg",
                                // ),
                                Image(
                                  image: AssetImage('assets/images/logo.png'),
                                  width: 90,
                                ) ,
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        prakerin.nama_tempat,
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      Text("${prakerin.lokasi} | ${prakerin.lama} Bulan")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
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
