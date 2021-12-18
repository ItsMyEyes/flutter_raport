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

class AddEditPrakerin extends StatefulWidget {
  AddEditPrakerin({this.id,this.nis,this.semester,this.nama_siswa,this.id_kelas});
  String id = "0  ";  
  String nis;
  String nama_siswa;
  String semester;
  String id_kelas;
  @override
  _AddEditPrakerinState createState() => _AddEditPrakerinState();
}

class _AddEditPrakerinState extends State<AddEditPrakerin> {
  bool showPassword = false;
  TextEditingController controllernis = new TextEditingController();
  TextEditingController controllernama = new TextEditingController();
  TextEditingController controllerlokasi = new TextEditingController();
  TextEditingController controllerlama = new TextEditingController();
  TextEditingController controllerketerangan = new TextEditingController();

  var _matpel = [];
  bool updates = false;
  int dropdownValue;

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
    print("${Env.URL_PREFIX}/prakerin/${widget.id}");
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/prakerin/${widget.id}"));
    print(response.body);
      if (response.statusCode == 200) {
        setState(() { 
        updates = true;
      });
      final data = json.decode(response.body)['data'];
      controllernama.text =  data['nama_tempat'];
      controllerlokasi.text = data['lokasi'];
      controllerlama.text = data['lama'].toString();
      controllerketerangan.text = data['keterangan']; 
    }
    EasyLoading.dismiss();
  }

  void update() async  {
    print('update');
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    final response = await http.put(Uri.parse("${Env.URL_PREFIX}/prakerin/${widget.nis}"), body: {
      "induk": widget.nis,
      "nama_tempat": controllernama.text,
      "lokasi": controllerlokasi.text,
      "lama": controllerlama.text,
      "keterangan": controllerketerangan.text,
      "semester": widget.semester,
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
    print('store_usre');
    final pref = await SharedPreferences.getInstance();
    EasyLoading.show(status: 'loading...');
    print("${Env.URL_PREFIX}/prakerin");
    final response = await http.post(Uri.parse("${Env.URL_PREFIX}/prakerin"), body: {
      "induk": widget.nis,
      "nama_tempat": controllernama.text,
      "lokasi": controllerlokasi.text,
      "alpa": widget.semester,
      "lama": controllerlama.text,
      "keterangan": controllerketerangan.text,
      "catatan": '-',
      "semester": widget.semester,
      "ta": pref.getString('ta')
    });
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(response.body)['message']);
      Navigator.push(context,CupertinoPageRoute(builder: (context) => CasIndex(id_kelas: widget.id_kelas.toString(),semester: widget.semester,)));
    } else {  
      EasyLoading.showError(json.decode(response.body)['data'][0]);
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
              buildTextField("Nama perusahaan", "PT. Daerah", false,controllernama,false, false),
              buildTextField("Lokasi", "Jakarta", false,controllerlokasi,false, false),
              buildTextField("Berapa Lama", "10 Bulan", false,controllerlama,false, true),
              buildTextField("keterangan", "-", false,controllerketerangan,false, false),
              
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

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField,controllerText, bool readOnly, bool number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        keyboardType: (number) ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        controller: controllerText,
        obscureText: isPasswordTextField ? showPassword : false,
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