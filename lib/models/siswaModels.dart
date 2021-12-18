import 'dart:convert';
import 'dart:ui';


class Siswa {
  Siswa({
    this.kode_login,
    this.email,
    this.akses,
    this.nama,
    this.nilai
  });

  String kode_login;
  String email;
  String akses;
  String nama;
  bool nilai;

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
        kode_login: json['kode_login'].toString(),
        email: json['email'],
        akses: 'Siswa',
        nama: json['nama'],
        nilai: json['nilai']
    );
  }

}
  
List<Siswa> siswaFromJson(String jsonData) {
    final data = json.decode(jsonData)['data']['data'];
    print(data);
    return List<Siswa>.from(data.map((item) => Siswa.fromJson(item)));
}
