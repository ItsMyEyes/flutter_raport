import 'package:flutter/material.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/add.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/detail.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';  
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_login_register_ui/widgets/search_bar.dart';
import '../../../models/siswaModels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../env.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/cupertino.dart';
import '../screen_user.dart';
import '../../screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class SiswaIndexOnlyView extends StatefulWidget {
  
  String id_kelas;
  SiswaIndexOnlyView({this.id_kelas});
  @override
  _SiswaIndexOnlyViewState createState() => _SiswaIndexOnlyViewState();
}

class _SiswaIndexOnlyViewState extends State<SiswaIndexOnlyView> {

  

  Future<List<Siswa>> getSiswa() async {
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/siswa?kelas=${widget.id_kelas}&ta=${pref.getString('ta')}"), headers: requestHeaders);
    if (response.statusCode == 200) {
      return siswaFromJson(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlueLightColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,CupertinoPageRoute(builder: (context) => GuruScreen(currentTab: 1, currentScreen: SiswaOnlyView())));
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: AssetImage('assets/images/back_arrow.png'),
          ),
        ),
      ),
      body: FutureBuilder(
            future: getSiswa(),
            builder: (BuildContext context, AsyncSnapshot<List<Siswa>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Token is expired please login again"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                List<Siswa> gurus = snapshot.data;
                return _buildListView(context,gurus,widget.id_kelas);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
    );
  }
}

Widget _buildListView(context,List<Siswa> siswas, kelas) {
  var size = MediaQuery.of(context).size;
  return new Stack(
        children: <Widget>[
          Container(
            height: size.height * .45,
            decoration: BoxDecoration(
              color: kBlueLightColor,
              image: DecorationImage(
                image: AssetImage("assets/images/meditation_bg.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    Text(
                      "Siswa",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage Siswa",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: size.width * .6, // it just take 60% of total width
                      child: Text(
                        "Manage pengguna yang berole access Siswa, wali kelas, tata usaha, dan wakil kurikulum",
                      ),
                    ),
                    SizedBox(
                      width: size.width * .5, // it just take the 50% width
                      child: SearchBar(text: 'Siswa',),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "List Siswa",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      padding: EdgeInsets.only(top: 25, right: 25, left: 25),
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: siswas.length,
                      itemBuilder: (context, index) {
                        Siswa siswa = siswas[index];
                        return GestureDetector(
                          onTap: () {
                            
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
                                        siswa.nama,
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      Text("${siswa.kode_login}")
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