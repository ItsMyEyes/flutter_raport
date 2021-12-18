import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../widgets/widget.dart';
import 'package:flutter_login_register_ui/env.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class GuruPage extends StatefulWidget {
  @override
  _GuruPageState createState() => _GuruPageState();
}

class _GuruPageState extends State<GuruPage> {
  String tokenAndroid;
  bool _isLoading = false;
  TextEditingController controllerUsername = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  bool isPasswordVisible = true;

  String dropdownValue;
  static const _fruits = [
    '2019/2020',
    '2020/2021',
    '2021/2022'
  ];

  void initState() {
      super.initState();
      checkingLogin();
  }

  void setDropdown(item) {
    setState(() => {
      dropdownValue = item,
    });
  }

  void checkingLogin() async {
    final pref = await SharedPreferences.getInstance();
    print(pref.getString('token'));
    EasyLoading.show(status: 'loading...');
    if (pref.getString('token') != null) {
      Map<String, String> requestHeaders = {
         'Authorization': 'Bearer ' + pref.getString('token')
      };
      final response2 = await http.post(Uri.parse("${Env.URL_PREFIX}/auth/me?ta=${dropdownValue}"),headers: requestHeaders);
      print(response2.body);
      var decodeJson = json.decode(response2.body);
      if (response2.statusCode == 200) {
        if (decodeJson['nama'] == null) {
          final pref = await SharedPreferences.getInstance();
          pref.remove("token");
          pref.remove("akses");
          pref.remove("email");
          pref.remove("nama");
          pref.remove("kode_login");
          pref.remove("ta");
          EasyLoading.showSuccess("Token tidak valid, silahkan login lagi");
        } else {
          EasyLoading.showSuccess("Welcome back! ${decodeJson['nama']}");
          if (decodeJson['akses2'] == 'tata_usaha' || decodeJson['akses2'] == 'wakil_kurikulum') {
            Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MainGuru(),
            ));
          } else {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => GuruScreen(),
              ));
          }
        }
        
      }
    }
    EasyLoading.dismiss();
  }

  void  prosesLogin() async {
    EasyLoading.show(status: 'loading...');
    if (controllerUsername.text.isEmpty || controllerPassword.text.isEmpty || dropdownValue == null) {
      EasyLoading.showError('Tolong isi, pada bagian yang kosong');
      return;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var uri = Uri;
    final response = await http.post(Uri.parse("${Env.URL_PREFIX}/auth/login"), body: {
      "kode_login": controllerUsername.text,
      "password": controllerPassword.text,
      "type": "guru"
    });

    if (response.statusCode == 200) {
      var ini = json.decode(response.body);
      Map<String, String> requestHeaders = {
       'Authorization': 'Bearer ' + ini['access_token']
     };
      var result = json.decode(response.body);
      final response2 = await http.post(Uri.parse("${Env.URL_PREFIX}/auth/me?ta=${dropdownValue}"),headers: requestHeaders);
      print(response2.body);
      var ini2 = json.decode(response2.body);
      print(ini2);
      sharedPreferences.setString("token", ini['access_token']);
      sharedPreferences.setString("akses", ini2['akses2']);
      sharedPreferences.setString("email", ini2['email']);
      sharedPreferences.setString("nama", ini2['nama']);
      sharedPreferences.setString("kode_login", ini2['kode_login']);
      sharedPreferences.setString("ta", dropdownValue);
      EasyLoading.showSuccess('Welcome back!');
      if (ini2['akses2'] == 'tata_usaha' || ini2['akses2'] == 'wakil_kurikulum') {
        Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => MainGuru(),
        ));
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => GuruScreen(),
          ));
      }
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
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: Svg('assets/images/back_arrow.svg'),
          ),
        ),
      ),
      body: SafeArea(
        //to make page scrollable
        child: CustomScrollView(
          reverse: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat datang.",
                            style: kHeadline,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "mari kita manage raport!",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 60,
                          ),
                          MyTextField(
                            hintText: 'Kode guru',
                            inputType: TextInputType.text,
                            controllerText: controllerUsername,
                          ),
                          MyPasswordField(
                            isPasswordVisible: isPasswordVisible,
                            controllerText: controllerPassword,
                            onTap: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20, left: 3, right: 3,bottom: 10),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tahun Pelajaran',
                                labelStyle: kBodyText,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
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
                                      child: Text(item, style: kBodyText),
                                    );
                                  }).toList(),
                                  onChanged: (selectedItem) => { setDropdown(selectedItem) },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Jika ada masalah hubungi admin? ",
                          style: kBodyText,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyTextButton(
                      buttonName: 'Sign In',
                      onTap: () => {
                        prosesLogin()
                      },
                      bgColor: Colors.black,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
