import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_login_register_ui/screens/guru_page.dart';
import 'package:flutter_login_register_ui/screens/manageKelas/index.dart';
import 'package:flutter_login_register_ui/screens/manageUser/guru/index.dart';
import 'package:flutter_login_register_ui/screens/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/manageUser/screen_user.dart';
import '../../env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_login_register_ui/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DetailKelas extends StatefulWidget {
  DetailKelas({this.id_kelas});
  String id_kelas;
  @override
  _DetailKelasState createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  bool showPassword = false;
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerKode = new TextEditingController();

  String dropdownValue;
  String tingkat;
  final _formKey = GlobalKey<FormState>();
  static const _tingkat = [
    '10',
    '11',
    '12',
    '13',
  ];

  void setTingkat(item) {
    setState(() => {  
      tingkat = item,
    });
  }

  void detroyKelas() async{
    EasyLoading.show(status: 'loading...');
    final pref = await SharedPreferences.getInstance();
    final response = await http.delete(Uri.parse("${Env.URL_PREFIX}/kelas/${widget.id_kelas}?ta=${pref.getString('ta')}"));
    EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => KelasIndex(),
      ));
      EasyLoading.dismiss();
  }

  void getData() async {
    EasyLoading.show(status: 'loading...');
    final pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/kelas/${widget.id_kelas}?ta=${pref.getString('ta')}"));
  // print("${Env.URL_PREFIX}/kelas/${widget.id_kelas}?ta=${pref.getString('ta')}");
    final data =json.decode(response.body)['data'][0];
    setState(() {
          tingkat = data['kelas']['tingkat'].toString();
        });
    controllerName.text = data['kelas']['kelas']; 
    controllerKode.text = data['wali_kelas'];
    EasyLoading.dismiss();
  }

  void initState() {
      super.initState();
      getData();
  }

  void storeUser() async {
    EasyLoading.show(status: 'loading...');
    if (!_formKey.currentState.validate() || tingkat == null) {
      EasyLoading.showError('Incomplete data');
      return;
    }
    final pref = await SharedPreferences.getInstance();
    final response = await http.put(Uri.parse("${Env.URL_PREFIX}/kelas/${widget.id_kelas}"), body: {
      "tingkat": tingkat,
      "kelas": controllerName.text,
      "wali_kelas": controllerKode.text
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final response2 = await http.post(Uri.parse("${Env.URL_PREFIX}/kelas/mapping"), body: {
        "id_kelas": widget.id_kelas,
        "wali_kelas": controllerKode.text,
        'ta': pref.getString('ta')
      });
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => KelasIndex(),
      ));
    } else {
      print(response.statusCode);
      print(response.body);
      EasyLoading.showError(json.decode(response.body)['message']);
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
              Navigator.push(context,CupertinoPageRoute(builder: (context) => KelasIndex()));
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
                    labelText: 'Tingkat',
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
                      value: tingkat,
                      items: _tingkat.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(item, style: kBodyText),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedItem) => { setTingkat(selectedItem) },
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
                    buildTextField("Nama Kelas", "X MULTIMEDIA 12", false, controllerName, 255, "text"),
                    buildTextField("Kode Guru", "05050505", false,controllerKode, 14, "number"),
                  ],
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {                  
                        detroyKelas();
                    },
                    child: Text("DELETE",
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