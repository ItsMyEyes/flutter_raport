import 'dart:convert';
import 'dart:ui';


class Guru {
  Guru({
    this.kode_login,
    this.email,
    this.akses,
    this.nama,
    this.wali_kelas
  });

  String kode_login;
  String email;
  String akses;
  String nama;
  bool wali_kelas;

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
        kode_login: json['kode_login'],
        email: json['email'],
        akses: json['akses'],
        nama: json['nama'],
        wali_kelas: (json['akses2'] == 'wali_kelas') ? true : false
    );
  }

}
  
List<Guru> guruFromJson(String jsonData) {
    final data = json.decode(jsonData)['data']['data'];
    return List<Guru>.from(data.map((item) => Guru.fromJson(item)));
}
