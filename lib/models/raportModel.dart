import 'dart:convert';
import 'dart:ui';


class Raport {
  Raport({
    this.id,
    this.ta,
    this.semester,
  });

  String id;
  String nis;
  String ta;
  String semester;

  factory Raport.fromJson(Map<String, dynamic> json) {
    return Raport(
        id: json['id'].toString(),
        ta: json['ta'],
        semester: json['semester'],
    );
  }

}
  
List<Raport> raportfromJSON(String jsonData) {
    final data = json.decode(jsonData)['data'];
    return List<Raport>.from(data.map((item) => Raport.fromJson(item)));
}
