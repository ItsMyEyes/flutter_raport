import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';  
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_login_register_ui/widgets/search_bar.dart';
import '../../models/matpelModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/cupertino.dart';
import '../screen.dart';
import 'dart:convert';
import '../matpel/master/add.dart';
import '../matpel/master/detail.dart';

class OnlyViewMatpel extends StatelessWidget {

  Future<List<Matpel>> getGuru() async {
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/matpel/get/mapping?ta=${pref.getString('ta')}"), headers: requestHeaders);
    if (response.statusCode == 200) {
      return matpelFromjson(response.body);
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
            Navigator.push(context,CupertinoPageRoute(builder: (context) => GuruScreen()));
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: AssetImage('assets/images/back_arrow.png'),
          ),
        ),
      ),
      body: FutureBuilder(
            future: getGuru(),
            builder: (BuildContext context, AsyncSnapshot<List<Matpel>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Token is expired please login again"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                List<Matpel> matpels = snapshot.data;
                return _buildListView(context,matpels);
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

Widget _buildListView(context,List<Matpel> matpels) {
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
                      "Mata pelajaran",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage Mata pelajaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: size.width * .6, // it just take 60% of total width
                      child: Text(
                        "Manage Mata pelajaran dan melihat untuk guru dan wali kelas",
                      ),
                    ),
                    SizedBox(
                      width: size.width * .5, // it just take the 50% width
                      child: SearchBar(text: 'Mata Pelajaran'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "List Guru",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      padding: EdgeInsets.only(top: 25, right: 25, left: 25),
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: matpels.length,
                      itemBuilder: (context, index) {
                        Matpel matpel = matpels[index];
                        return GestureDetector(
                          onTap: () {
                            
                          },
                          onLongPress: () {
                            print("Long");
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
                                        matpel.nama,
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      Text("${matpel.nama_guru} / Kelompok ${matpel.kelompok.toUpperCase()}")
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
