import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import '../env.dart';
import 'package:http/http.dart' as http;

class OperationModel {
  String name;
  String count;

  OperationModel(this.name,  this.count);
}

List<OperationModel> datas = operationsData.map((item) =>
    OperationModel(item['name'],  item['count'])).toList();

var operationsData = [
  
];
var response = http.get(Uri.parse("${Env.URL_PREFIX}")).then((value) => {
  json.decode(value.body)['data']
  
});