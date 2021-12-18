import 'dart:convert';
import 'dart:ui';


class Kelas {
  Kelas({
    this.id_kelas,
    this.wali_kelas,
    this.nama_guru,
    this.nama_kelas,
    this.tingkat,
    this.kb_ket,
    this.kb_peng
  });

  String id_kelas;
  String wali_kelas;
  String nama_guru;
  String nama_kelas;
  String tingkat;
  String kb_peng;
  String kb_ket;

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
        id_kelas: json['id_kelas'].toString(), 
        wali_kelas: json['wali_kelas'],
        nama_guru: json['guru']['nama'],
        nama_kelas: json['kelas']['kelas'],
        tingkat: json['kelas']['tingkat'].toString(),
        kb_ket: json['kb_ket'].toString(),
        kb_peng: json['kb_peng'].toString()
    );
  }

}
  
List<Kelas> kelasFromJson(String jsonData) {
    final data = json.decode(jsonData)['data'];
    print(data);
    return List<Kelas>.from(data.map((item) => Kelas.fromJson(item)));
}