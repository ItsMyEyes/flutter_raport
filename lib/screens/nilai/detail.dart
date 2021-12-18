import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_login_register_ui/screens/guru_page.dart';
import 'package:flutter_login_register_ui/screens/manageKelas/index.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/index.dart';
import 'package:flutter_login_register_ui/screens/nilai/index.dart';
import 'package:flutter_login_register_ui/screens/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/manageUser/screen_user.dart';
import '../../env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add.dart';
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DetailNilai extends StatefulWidget {
  DetailNilai({this.nis,this.semester,this.nama_siswa,this.id_kelas,this.id_matpel});
  String nis;
  String nama_siswa;
  String semester;
  String id_kelas;
  int id_matpel;
  @override
  _DetailNilaiState createState() => _DetailNilaiState();
}

class _DetailNilaiState extends State<DetailNilai> {
  bool showPassword = false;
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerKode = new TextEditingController();
  TextEditingController controllerp1 = new TextEditingController();
  TextEditingController controllerp2 = new TextEditingController();
  TextEditingController controllerp3 = new TextEditingController();
  TextEditingController controllerk1 = new TextEditingController();
  TextEditingController controllerk2 = new TextEditingController();
  TextEditingController controllerk3 = new TextEditingController();
  TextEditingController controllercatatan = new TextEditingController();

  var _matpel = [];
  int dropdownValue;
  String tingkat;
  final _formKey = GlobalKey<FormState>();


  static const _tingkat = [
    {
      "kelompok": "a",
      "title": "A. Muatan Nasional"
    },
    {
      "kelompok": "b",
      "title": "B. Muatan Kewilayahan"
    },
    {
      "kelompok": "c1",
      "title": "C1. Dasar Bidang Keahlian"
    },
    {
      "kelompok": "c2",
      "title": "C2. Dasar Program Keahlian"
    },
    {
      "kelompok": "c3",
      "title": "C3. Kompetensi Keahlian"
    },
    {
      "kelompok": "m",
      "title": "D. Muatan Lokal"
    },
  ];

  void setDropdown(item) {
    setState(() => {
      dropdownValue = item,
    });
  }

  void setTingkat(item) async {
    setState(() => {
      tingkat = item,
    });
  }

  void getData() async{
    EasyLoading.show(status: 'getting matpel...');
    final pref = await SharedPreferences.getInstance();
    final checking = await http.get(Uri.parse("${Env.URL_PREFIX}/matpel/get/mapping?ta=${pref.getString('ta')}"));
    for(var i in json.decode(checking.body)['data']) {
       if (i['id_matpel'] == widget.id_matpel) {
         _matpel.add(i);
         dropdownValue = i['id_matpel'];
       }
    }
    setState(() {
          controllerName.text = widget.nama_siswa;
        });
  }

  void initState() {
      super.initState();
      getData();
      getNilai();
  }

  void getNilai() async {
    EasyLoading.show(status: 'getting nilai...');
    final pref = await SharedPreferences.getInstance();
    final checking = await http.get(Uri.parse("${Env.URL_PREFIX}/nilai/${widget.nis}/${widget.id_matpel}?ta=${pref.getString('ta')}&semester=${widget.semester}"));
    final data = json.decode(checking.body)['data'];
    print(data);
    if (data != null) {
      setState(() {
          dropdownValue = data['matpel'];
        });
    controllerp1.text = data['p1'].toString();
    controllerp2.text = data['p2'].toString();
    controllerp3.text = data['p3'].toString();
    controllerk1.text = data['k1'].toString();
    controllerk2.text = data['k2'].toString();
    controllerk3.text = data['k3'].toString();
    controllercatatan.text = data['catatan'];
    } else {
      Navigator.push(context,CupertinoPageRoute(builder: (context) => AddNilai(nis: widget.nis, semester: widget.semester,nama_siswa: widget.nama_siswa,id_kelas: widget.id_kelas,id_matpel: widget.id_matpel)));
    }
    EasyLoading.dismiss();
  }

  void storeUser() async {
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    if (!_formKey.currentState.validate()) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    final response = await http.post(Uri.parse("${Env.URL_PREFIX}/nilai"), body: {
      "id_siswa": widget.nis,
      "id_matpel": dropdownValue.toString(),
      "semester": widget.semester,
      "p1": controllerp1.text,
      "p2": controllerp2.text,
      "p3": controllerp3.text,
      "k1": controllerk1.text,
      "k2": controllerk2.text,
      "k3": controllerk3.text,
      "s1": '-',
      "s2": '-',
      "s3": '-',
      "catatan": controllercatatan.text,
      "ta": pref.getString('ta')
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => NilaiIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
    } else {  
      EasyLoading.showError('Ada Field Yang belum teriisi / Ada kesalahan dari server');
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: () {
              Navigator.push(context,CupertinoPageRoute(builder: (context) => NilaiView()));
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/logo.png'))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
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
                            child: Text(item['matpel']['nama'], style: kBodyText),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedItem) => { setDropdown(selectedItem) },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                      buildTextField("Nama Siswa", "X MULTIMEDIA 12", false,controllerName,true, 255, "text"),
                      buildTextField("Nilai Pengetahuan 1", "80", false,controllerp1,false, 2, "number"),
                      buildTextField("Nilai Pengetahuan 2", "80", false,controllerp2,false, 2, "number"),
                      buildTextField("Nilai Pengetahuan 3", "80", false,controllerp3,false, 2, "number"),
                      buildTextField("Nilai Keterampilan 1", "80", false,controllerk1,false, 2, "number"),
                      buildTextField("Nilai Keterampilan 2", "80", false,controllerk2,false, 2, "number"),
                      buildTextField("Nilai Keterampilan 3", "80", false,controllerk3,false, 2, "number"),
                      buildTextField("Catatan", "Catatan", false,controllercatatan,false, 100, "text"),
                  ]
                )
              ),
              
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                    borderSide: BorderSide(
                        width: 2.0,
                        color: Colors.black,
                        style: BorderStyle.solid,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {                  
                        Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => NilaiIndex(id_kelas: widget.id_kelas, semester: widget.semester),
                        ));
                    },
                    child: Text("Cancel",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  RaisedButton(
                    onPressed: () { storeUser(); },
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 80),
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
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder, bool isPasswordTextField,controllerText, bool readOnly, int maxLength, String keyboardType) {
    var typeKey = TextInputType.text;
    switch (keyboardType) {
      case "date":
        typeKey = TextInputType.datetime;
        break;
      case "number":
        typeKey = TextInputType.number;
        break;
      case "phone":
        typeKey = TextInputType.phone;
        break;
      case "email":
        typeKey = TextInputType.emailAddress;
        break;
      default:
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        readOnly: readOnly,
        keyboardType: typeKey,
        maxLength: maxLength,
        controller: controllerText,
        obscureText: isPasswordTextField ? showPassword : false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
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