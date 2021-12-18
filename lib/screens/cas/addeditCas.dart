import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_login_register_ui/screens/cas/index.dart';
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
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddCas extends StatefulWidget {
  AddCas({this.nis,this.semester,this.nama_siswa,this.id_kelas});
  String nis;
  String nama_siswa;
  String semester;
  String id_kelas;
  @override
  _AddCasState createState() => _AddCasState();
}

class _AddCasState extends State<AddCas> {
  bool showPassword = false;
  TextEditingController controllernis = new TextEditingController();
  TextEditingController controllersakit = new TextEditingController();
  TextEditingController controllerijin = new TextEditingController();
  TextEditingController controlleralpha = new TextEditingController();
  TextEditingController controllersikap = new TextEditingController();
  TextEditingController controllerCatatan = new TextEditingController();

  var _matpel = [];
  bool updates = false;
  int dropdownValue;
  final _formKey = GlobalKey<FormState>();

  void setDropdown(item) {
    setState(() => {
      dropdownValue = item,
    });
  }

  void initState() {
      super.initState();
      getData();
  }

  void getData() async {
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/cas/${widget.nis}?semester=${widget.semester}&ta=${pref.getString('ta')}"));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        updates = true;
      });
      final data = json.decode(response.body)['datas'];
      controllersakit.text =  data['sakit'];
      controllerijin.text = data['ijin'];
      controlleralpha.text = data['alpa'];
      controllersikap.text = data['sikap'];
      controllerCatatan.text = data['catatan'];
    }
    EasyLoading.dismiss();
  }

  void update() async  {
    final pref = await SharedPreferences.getInstance();
    if (!_formKey.currentState.validate()) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    EasyLoading.show(status: 'loading...');
    final response = await http.put(Uri.parse("${Env.URL_PREFIX}/cas/${widget.nis}"), body: {
      "induk": widget.nis,
      "sakit": controllersakit.text,
      "ijin": controllerijin.text,
      "semester": widget.semester,
      "alpa": controlleralpha.text,
      "sikap": controllersikap.text,
      "catatan": controllerCatatan.text,
      "ta": pref.getString('ta')
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
    } else {  
      EasyLoading.showError('Ada kesalahan dari server');
    }
    EasyLoading.dismiss();
  }

  void storeUser() async {
    final pref = await SharedPreferences.getInstance();
    if (!_formKey.currentState.validate()) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    EasyLoading.show(status: 'loading...');
    final response = await http.post(Uri.parse("${Env.URL_PREFIX}/cas"), body: {
      "induk": widget.nis,
      "sakit": controllersakit.text,
      "ijin": controllerijin.text,
      "semester": widget.semester,
      "alpa": controlleralpha.text,
      "sikap": controllersikap.text,
      "catatan": controllerCatatan.text,
      "ta": pref.getString('ta')
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
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
              Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
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
              SizedBox(
                height: 35,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    buildTextField("Sakit", "Angka", false,controllersakit, 2, "number"),
                    buildTextField("Ijin", "Angka", false,controllerijin, 2, "number"),
                    buildTextField("Alpa", "Angka", false,controlleralpha, 2, "number"),
                    buildTextField("Sikap", "A", false,controllersikap, 2, "text"),
                    buildTextField("Catatan", "A", false,controllerCatatan, 50, "text"),
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
                        Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
                    },
                    child: Text("Cancel",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  RaisedButton(
                    onPressed: () { (updates) ? update() : storeUser(); },
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