import 'dart:convert';
import 'dart:ui';


class Siswa {
  Siswa({
    this.nis,
    this.nama,
    this.id_matpel,
    this.nama_matpel,
    this.semester,
    this.p1,
    this.p2,
    this.p3,
    this.k1,
    this.k2,
    this.k3,
    this.catatan
  });

  String nis;
  String nama;
  String id_matpel;
  String nama_matpel;
  String semester;
  String p1;
  String p2;
  String p3;
  String k1;
  String k2;
  String k3;
  String catatan;

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
        nis: json['siswa']['nis'],
        nama: json['siswa']['nama'],
        id_matpel: json['matpel']['id_matpel'],
        nama_matpel: json['matpel']['nama_matpel'],
        semester: json['semester'],
        p1: json['p1'],
        p2: json['p2'],
        p3: json['p3'],
        k1: json['k1'],
        k2: json['k2'],
        k3: json['k3'],
        catatan: json['catatan']
    );
  }

}
  
List<Siswa> siswaFromJson(String jsonData) {
    final data = json.decode(jsonData)['data'];
    print(data);
    return List<Siswa>.from(data.map((item) => Siswa.fromJson(item)));
}
