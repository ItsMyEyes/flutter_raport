import 'package:flutter/material.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/add.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/detail.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';  
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_login_register_ui/widgets/search_bar.dart';
import '../../models/siswaModels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/cupertino.dart';
import '../screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'add.dart';
import 'detail.dart';


class NilaiIndex extends StatefulWidget {
  
  NilaiIndex({this.id_kelas,this.semester});
  String id_kelas;
  String semester;
  @override
  _NilaiIndexState createState() => _NilaiIndexState();
}

class _NilaiIndexState extends State<NilaiIndex> {

  String _filePath;

   var _matpel = [];

   void setDropdown(item) {
    setState(() => {
      dropdownValue = item,
    });
  }

  void uploadFile(id_matpel) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'doc','xlsx'],
        );

    if(result != null) {
      PlatformFile file = result.files.first;  
      final pref = await SharedPreferences.getInstance();
      EasyLoading.show(status: 'uploading...');
      var request = http.MultipartRequest("POST", Uri.parse("${Env.URL_PREFIX}/nilai/upload?ta=${pref.getString('ta')}&id_matpel=${id_matpel}&semester=${widget.semester}"));
      var pic = await http.MultipartFile.fromPath("file", file.path);
      //add multipart to request
      request.files.add(pic);
      var response = await request.send();

      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      if (response.statusCode == 500) {
        EasyLoading.showError("Data belum sesuai");
        return;
      }
      var jsonDecode = json.decode(responseString);
      EasyLoading.showSuccess(jsonDecode['message']);
    } else {
      EasyLoading.showSuccess('Format file salah');
    }
    EasyLoading.dismiss();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int dropdownValue;

  void getData() async{
    EasyLoading.show(status: 'getting matpel...');
    final pref = await SharedPreferences.getInstance();
    final checking = await http.get(Uri.parse("${Env.URL_PREFIX}/matpel/get/mapping?ta=${pref.getString('ta')}"));
    _matpel = json.decode(checking.body)['data'];
    EasyLoading.dismiss();
  }

  void initState() {
      super.initState();
      getData();
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
    if (response.statusCode == 200) {
      return siswaFromJson(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.upload_file),
        backgroundColor: Colors.green,
        onPressed: () {
          showModalBottomSheet(context: context, builder: (BuildContext bc) {
            return Container(
              color: Color(0xff757575),
              height: MediaQuery.of(context).size.height * .3,
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
                      'Hello!!, Pilih matpel dahulu',
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
                            value: dropdownValue,
                            items: _matpel.map((item) {
                              return DropdownMenuItem(
                                value: item['id_matpel'],
                                child: Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(item['matpel']['nama'] + " ( " + item['guru']['nama'] + " )", style: kBodyText),
                                ),
                              );
                            }).toList(),
                            onChanged: (selectedItem) => { 
                              uploadFile(selectedItem)
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
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
                return _buildListView(context,gurus,widget.id_kelas,widget.semester);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
    );
  }

  Widget _buildListView(context,List<Siswa> siswas, kelas,semester) {
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
                      child: SearchBar(text: 'Pilih siswa',),
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
                            showModalBottomSheet(context: context, builder: (BuildContext bc) {
                              return Container(
                                color: Color(0xff757575),
                                height: MediaQuery.of(context).size.height * .3,
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
                                              value: dropdownValue,
                                              items: _matpel.map((item) {
                                                return DropdownMenuItem(
                                                  value: item['id_matpel'],
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 5),
                                                    child: Text(item['matpel']['nama'] + "( " + item['guru']['nama'] + " )", style: kBodyText),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (selectedItem) => { 
                                                (!siswa.nilai) ? 
                                                  Navigator.push(context,CupertinoPageRoute(builder: (context) => AddNilai(nis: siswa.kode_login, semester: semester,nama_siswa: siswa.nama,id_kelas: kelas,id_matpel: selectedItem)))
                                                  : 
                                                  Navigator.push(context,CupertinoPageRoute(builder: (context) => DetailNilai(nis: siswa.kode_login, semester: semester,nama_siswa: siswa.nama,id_kelas: kelas, id_matpel: selectedItem),))
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
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
}