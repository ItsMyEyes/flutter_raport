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

class SiswaIndex extends StatefulWidget {
  
  String id_kelas;
  SiswaIndex({this.id_kelas});
  @override
  _SiswaIndexState createState() => _SiswaIndexState();
}

class _SiswaIndexState extends State<SiswaIndex> {

  
  String _filePath;

  void uploadFile(url) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );
    
    final pref = await SharedPreferences.getInstance();
    if(result != null) {
      PlatformFile file = result.files.first;  
      EasyLoading.show(status: 'uploading...');
      var request = http.MultipartRequest("POST", Uri.parse("${url}"));
      var pic = await http.MultipartFile.fromPath("file", file.path);
      //add multipart to request
      request.files.add(pic);
      request.fields['id_kelas'] = widget.id_kelas;
      request.fields['ta'] = pref.getString('ta');
      
      var response = await request.send();

      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      if(response.statusCode == 500) {
        EasyLoading.showError("Ada duplicate data");
        return;
      }
      var jsonDecode = json.decode(responseString);
      EasyLoading.showSuccess(jsonDecode['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => MainGuru(currentTab: 1, currentScreen: UserTata())));
    } else {
      EasyLoading.showSuccess('Format file salah');
    }
    EasyLoading.dismiss();
  }

  Future<List<Siswa>> getSiswa() async {
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/siswa?kelas=${widget.id_kelas}&ta=${pref.getString('ta')}"), headers: requestHeaders);
    print("${Env.URL_PREFIX}/siswa?kelas=${widget.id_kelas}&ta=${pref.getString('ta')}");
    print(response.body);
    if (response.statusCode == 200) {
      return siswaFromJson(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
          /// both default to 16
          marginEnd: 18,
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          /// This is ignored if animatedIcon is non null
          icon: Icons.add,
          activeIcon: Icons.remove,
          buttonSize: 55.0,
          visible: true,
          closeManually: false,
          renderOverlay: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.6,
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.public_sharp, color: Colors.white,),
              backgroundColor: Colors.pinkAccent,
              label: 'Tambah Siswa',
              labelStyle: TextStyle(fontSize: 18.0),
              onLongPress: () => print('FIRST CHILD LONG PRESS'),
              onTap: () => {
                  Navigator.push(context,CupertinoPageRoute(builder: (context) => AddSiswa(id_kelas: widget.id_kelas,)))    
              }
            ),
            SpeedDialChild(
              child: Icon(Icons.upload_file, color: Colors.white,),
              backgroundColor: Colors.green,
              label: 'Upload Siswa',
              labelStyle: TextStyle(fontSize: 18.0),
              onLongPress: () => print('FIRST CHILD LONG PRESS'),
              onTap: () => {
                  uploadFile("${Env.URL_PREFIX}/siswa/import")
              }
            ),
            SpeedDialChild(
              child: Icon(Icons.upload_file, color: Colors.white,),
              backgroundColor: Colors.green,
              label: 'Mapping Siswa',
              labelStyle: TextStyle(fontSize: 18.0),
              onLongPress: () => print('FIRST CHILD LONG PRESS'),
              onTap: () => {
                  uploadFile("${Env.URL_PREFIX}/siswa/import/mapping")
              }
            ),
          ],
        ),
      appBar: AppBar(
        backgroundColor: kBlueLightColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,CupertinoPageRoute(builder: (context) => MainGuru(currentTab: 1, currentScreen: UserTata())));
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
  void deleteUser(nis) async {
      final pref = await SharedPreferences.getInstance();
      EasyLoading.show(status: 'Deleting...');
      final response = await http.delete(Uri.parse("${Env.URL_PREFIX}/siswa/sekolah/${nis}?ta=${pref.getString('ta')}"));
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => SiswaIndex(id_kelas: kelas,)));
      print(response.statusCode);
      EasyLoading.dismiss();
  }
  void deleteUserKelas(nis) async {
      EasyLoading.show(status: 'Deleting...');
      final pref = await SharedPreferences.getInstance();
      final response = await http.delete(Uri.parse("${Env.URL_PREFIX}/siswa/${nis}?ta=${pref.getString('ta')}"));
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => SiswaIndex(id_kelas: kelas,)));
      print(response.statusCode);
      EasyLoading.dismiss();
  }
  void showBottomSheet(nis) => showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
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
            title: Text('Hapus siswa dari kelas'),
            onTap: () => {
              deleteUserKelas(nis)
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Hapus siswa dari sekolah'),
            onTap: () => {
              deleteUser(nis)
            },
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('Close'),
            onTap: () => {
              Navigator.of(context).pop(context)
            },
          ),
        ],
      ),
    );
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
                        "Manage pengguna yang berole access Siswa, dan mapping siswa",
                      ),
                    ),
                    SizedBox(
                      width: size.width * .5, // it just take the 50% width
                      child: SearchBar(data: AddSiswa(id_kelas: kelas,),text: 'Tambahkan Siswa',),
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
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => DetailSiswa(nis: siswa.kode_login,id_kelas: kelas,)));
                          },
                          onLongPress: () {
                            showBottomSheet(siswa.kode_login);
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

class SessionCard extends StatelessWidget {
  final int seassionNum;
  final bool isDone;
  final Function press;
  const SessionCard({
    Key key,
    this.seassionNum,
    this.isDone = false,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: constraint.maxWidth / 2 -
              10, // constraint.maxWidth provide us the available with for this widget
          // padding: EdgeInsets.all(16),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: press,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 42,
                      width: 43,
                      decoration: BoxDecoration(
                        color: isDone ? kBlueColor : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBlueColor),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: isDone ? Colors.white : kBlueColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Session $seassionNum",
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}