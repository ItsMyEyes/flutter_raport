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

class EditProfilePage extends StatefulWidget {
  
  String kode_login;
  EditProfilePage({this.kode_login});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;
  bool waliKelas = false;
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerKode = TextEditingController();
  TextEditingController controllerNip  = TextEditingController();
  TextEditingController controllerNohp = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();

  String dropdownValue;
  String kelas;
  static const _fruits = [
    'Guru',
    'Admin',
    'Wakil kurikulum'
  ];

  var _kelas = []; 
  final _formKey = GlobalKey<FormState>();

  void setDropdown(item) {
    if (item == 'Wali kelas') {
        setState(() {
            waliKelas = true;      
        });
    } else {
      setState(() {
            waliKelas = false;      
        });
    }
    setState(() => {
      dropdownValue = item,
    });
  }

  void setKelas(item) {
    setState(() {
          kelas = item;
        });
  }

  void initState() {
      super.initState();
      getUser();
      getKelas();
  }

  void getKelas() async {
    final pref = await SharedPreferences.getInstance();
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/kelas?ta=${pref.getString('ta')}"));
    _kelas = json.decode(data.body)['data'];
  }

  void getUser() async {
    final data = await http.get(Uri.parse("${Env.URL_PREFIX}/guru/${widget.kode_login}"));
    final decodeJson = json.decode(data.body)['data']['data'][0];
    controllerName.text = decodeJson['nama'];
    controllerEmail.text = decodeJson['email'];
    controllerKode.text = decodeJson['kode_login'];
    controllerNip.text = decodeJson['nip'];
    controllerNohp.text = decodeJson['no_hp'];
    var akses = null;
    switch (decodeJson['akses2']) {
      case 'wali_kelas':
        akses = 'Wali Kelas';
        waliKelas = true;
        break;
      case 'guru':
        akses = 'Guru';
        break;
      case 'wakil_kurikulum':
        akses = 'Wakil kurikulum';
        break;
      case 'tata_usaha':
        akses = 'Admin';
        break;
      default:
        akses = 'Guru';
    }
    setState(() {
       dropdownValue = akses;
    });
  }

  void deleteUser() async {
    EasyLoading.show(status: 'loading...');
    final response = await http.delete(Uri.parse("${Env.URL_PREFIX}/guru/${widget.kode_login}"));
    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GuruIndex(),
      ));
    } else {
      var ini = json.decode(response.body);
      EasyLoading.showError(ini['error']);
    }
    EasyLoading.dismiss();
  }

  void updateUser() async {
    EasyLoading.show(status: 'loading...');
    if (!_formKey.currentState.validate() || dropdownValue == null) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    final pref = await SharedPreferences.getInstance();
    final response = await http.put(Uri.parse("${Env.URL_PREFIX}/guru/${widget.kode_login}"), body: {
      "kode_guru": controllerKode.text,
      "nip": controllerNip.text,
      "nama": controllerName.text,
      "no_hp": controllerNohp.text,
      "email": controllerEmail.text,
      "akses": dropdownValue,
      "password": controllerPassword.text,
    });

    if (response.statusCode == 200) {
      if (dropdownValue == 'wali_kelas') {
        final kelasPost = await http.post(Uri.parse("${Env.URL_PREFIX}/kelas/mapping"), body: {
          "id_kelas": kelas,
          "wali_kelas": controllerKode.text,
          "ta": pref.getString('ta')
        });
      }
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GuruIndex(),
      ));
    } else {
      print(response.statusCode);
      print(response.body);
      var ini = json.decode(response.body);
      EasyLoading.showError(ini['error']);
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
              Navigator.push(context,CupertinoPageRoute(builder: (context) => GuruIndex()));
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
                    buildTextField("Kode Guru", "05050505", false,controllerKode, 10, "number"),
                    buildTextField("NIP", "31877777", false,controllerNip, 10, "number"),
                    buildTextField("Full Name", "Dor Alex", false,controllerName, 255, "text"),
                    buildTextField("E-mail", "alexd@gmail.com", false,controllerEmail, 255, "email"),
                    buildTextField("No hp", "+6285790801400", false,controllerNohp, 14, "phone"),
                    buildTextField("Password", "******", false,controllerPassword, 255, "password"),
                    // Add TextFormFields and ElevatedButton here.
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 3, right: 3,bottom: 10),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Akses',
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
                      items: _fruits.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(item, style: kBodyText),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedItem) => { setDropdown(selectedItem) },
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: waliKelas,
                child: Container(
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
                          value: item['id'].toString(),
                          child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(item['kelas']['kelas'], style: kBodyText),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedItem) => { setKelas(selectedItem) },
                    ),
                  ),
                ),
              ),
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
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      deleteUser();
                    },
                    child: Text("DELETE ACCOUNT",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  RaisedButton(
                    onPressed: () { updateUser(); },
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 60),
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