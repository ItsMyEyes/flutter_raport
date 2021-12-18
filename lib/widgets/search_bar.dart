import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

class SearchBar extends StatelessWidget {
  SearchBar({this.data,this.text});
  Widget data;
  String text;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        print('tap'),
        if (data != null) {
          Navigator.push(context,CupertinoPageRoute(builder: (context) => data))
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 30),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(29.5),
        ),
        child: Text('\u{2795} ${text}', style: TextStyle(fontWeight: FontWeight.bold),)
      ),
    );
  }
}