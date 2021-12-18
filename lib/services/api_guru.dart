import '../models/guruModels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show Client;
import '../env.dart';

class ApiService {
  Client client = Client();

  Future<List<Guru>> getGuru() async {
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await client.get(Uri.parse("${Env.URL_PREFIX}/guru"), headers: requestHeaders);
    if (response.statusCode == 200) {
      return guruFromJson(response.body);
    } else {
      return null;
    }
  }

}