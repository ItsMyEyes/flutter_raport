import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_login_register_ui/screens/guru_page.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/index.dart';
import 'package:flutter_login_register_ui/screens/screen.dart';
import '../../../screens/manageUser/screen_user.dart';
import '../../../env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSiswa extends StatefulWidget {
  AddSiswa({this.id_kelas});
  String id_kelas;
  @override
  _AddSiswaState createState() => _AddSiswaState();
}

class _AddSiswaState extends State<AddSiswa> {
  bool showPassword = false;
  TextEditingController controllernis = new TextEditingController();
  TextEditingController controllernisn = new TextEditingController();
  TextEditingController controlleremail = new TextEditingController();
  TextEditingController controllernohp  = new TextEditingController();
  TextEditingController controllernama = new TextEditingController();
  TextEditingController controllerkelamin = new TextEditingController();
  TextEditingController controllertmp_lhr = new TextEditingController();
  TextEditingController controllertgl_lhr = new TextEditingController();
  TextEditingController controlleragama = new TextEditingController();
  TextEditingController controlleralamat = new TextEditingController();
  TextEditingController controllerkelurahan = new TextEditingController();
  TextEditingController controllerkecamatan = new TextEditingController();
  TextEditingController controllerkabupaten = new TextEditingController();
  TextEditingController controllerkodepos = new TextEditingController();
  TextEditingController controllernama_ayah = new TextEditingController();
  TextEditingController controllernama_ibu = new TextEditingController();
  TextEditingController controlleralamat_ortu = new TextEditingController();
  TextEditingController controllerkecamatan_ortu = new TextEditingController();
  TextEditingController controllerkelurahan_ortu = new TextEditingController();
  TextEditingController controllerkabupaten_ortu = new TextEditingController();
  TextEditingController controllerkodepos_ortu = new TextEditingController();
  TextEditingController controllernohp_ortu = new TextEditingController();
  TextEditingController controllerpekerjaan_ortu = new TextEditingController();

  String dropdownValue;
  final _formKey = GlobalKey<FormState>();
  static const _fruits = [
    'Guru',
    'Tata usaha',
    'Wakil kurikulum'
  ];

  void setDropdown(item) {
    setState(() => {
      dropdownValue = item,
    });
  }

  void initState() {
      super.initState();
  }

  void storeUser() async {
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    if (!_formKey.currentState.validate()) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    final response = await http.post(Uri.parse("${Env.URL_PREFIX}/siswa"), body: {
      'nis': controllernis.text,
      'nisn': controllernisn.text,
      'nama': controllernama.text,
      'kelamin': controllerkelamin.text,
      'tmp_lhr': controllertmp_lhr.text,
      'tgl_lhr': controllertgl_lhr.text,
      'agama': controlleragama.text,
      'alamat': controlleralamat.text,
      'kelurahan': controllerkelurahan.text,
      'kecamatan': controllerkecamatan.text,
      'kabupaten': controllerkabupaten.text,
      'kodepos': controllerkodepos.text,
      'nohp': controllernohp.text,
      'email': controlleremail.text,
      'nama_ayah': controllernama_ayah.text,
      'nama_ibu': controllernama_ibu.text,
      'alamat_ortu': controlleralamat_ortu.text,
      'kelurahan_ortu': controllerkelurahan_ortu.text,
      'kecamatan_ortu': controllerkecamatan_ortu.text,
      'kabupaten_ortu': controllerkabupaten_ortu.text,
      'kodepos_ortu': controllerkodepos_ortu.text,
      'nohp_ortu': controllernohp_ortu.text,
      'pekerjaan_ortu': controllerpekerjaan_ortu.text,
      'id_kelas': widget.id_kelas,
      'ta': pref.getString('ta')
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => MainGuru(currentTab: 1, currentScreen: UserTata())));
    } else {  
      EasyLoading.showError('Ada kesalahan dari server');
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
              Navigator.push(context,CupertinoPageRoute(builder: (context) => SiswaIndex(id_kelas: widget.id_kelas)));
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
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                      buildTextField("Nis", "05050505", false,controllernis, 11, "number"),
                      buildTextField("NIsn", "31877777", false,controllernisn, 20, "number"),
                      buildTextField("Full Name", "Dor Alex", false,controllernama, 255, "text"),
                      buildTextField("E-mail", "alexd@gmail.com", false,controlleremail, 255, "email"),
                      buildTextField("Kelamin (L/P)", "L", false,controllerkelamin, 1, "text"),
                      buildTextField("Tempat Lahir", "Jakarta", false,controllertmp_lhr,30,"text"),
                      buildTextField("Tanggal Lahir", "Years-Month-Date", false,controllertgl_lhr, 255, "date"),
                      buildTextField("Agama", "Islam", false,controlleragama, 11, "text"),
                      buildTextField("Alamat", "Alamat", false,controlleralamat, 255, "text"),
                      buildTextField("Kelurahan", "Kelurahan", false,controllerkelurahan, 255, "text"),
                      buildTextField("Kecamatan", "Kecamatan", false,controllerkecamatan, 255, "text"),
                      buildTextField("Kabupaten", "Kabupaten", false,controllerkabupaten, 255, "text"),
                      buildTextField("Kodepos", "Kodepos", false,controllerkodepos, 6, "number"),
                      buildTextField("No hp", "No hp", false,controllernohp, 16, "phone"),
                      buildTextField("Nama ayah", "Nama ayah", false,controllernama_ayah, 255, "text"),
                      buildTextField("Nama ibu", "Nama ibu", false,controllernama_ibu, 255, "text"),
                      buildTextField("Alamat Orang tua", "Alamat Orang tua", false,controlleralamat_ortu, 255, "text"),
                      buildTextField("Kecamatan Orang tua", "Kecamatan Orang tua", false,controllerkecamatan_ortu,255, "text"),
                      buildTextField("Kabupaten Orang tua", "Kabupaten Orang tua", false,controllerkabupaten_ortu,255, "text"),
                      buildTextField("Kodepos Orang tua", "Kodepos Orang tua", false,controllerkodepos_ortu,255, "number"),
                      buildTextField("Nohp Orang tua", "Nohp Orang tua", false,controllernohp_ortu, 16, "phone"),
                      buildTextField("pekerjaan Orang tua", "pekerjaan Orang tua", false,controllerpekerjaan_ortu, 255, "text"),
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
                          builder: (context) => GuruIndex(),
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

Widget buildTextField(String labelText, String placeholder, bool isPasswordTextField,controllerText, int maxLength, String keyboardType) {
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