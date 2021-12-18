import 'dart:convert';
import 'dart:ui';


class Matpel {
  Matpel({
    this.kelompok,
    this.nama,
    this.kelas_ajar,
    this.desc_ket,
    this.desc_peng,
    this.id,
    this.nama_guru,
    this.kode_guru
  });

  String kelompok;
  String nama;
  String kelas_ajar;
  String desc_peng;
  String desc_ket;
  String id;
  String nama_guru;
  String kode_guru;

  factory Matpel.fromJson(Map<String, dynamic> json) { 
    return Matpel(
        id: json['matpel']['id'].toString(),
        kelompok: json['matpel']['kelompok'],
        nama: json['matpel']['nama'],
        kelas_ajar: json['matpel']['kelas_ajar'],
        desc_ket: json['matpel']['desc_ket'],
        desc_peng: json['matpel']['desc_peng'],
        nama_guru: (json['guru'] != null) ? json['guru']['nama'] : 'belum ada guru',
        kode_guru: (json['guru'] != null) ? json['guru']['kode_guru'] : '-',
    );
  }

}
  
List<Matpel> matpelFromjson(String jsonData) {
    final data = json.decode(jsonData)['data'];
    print(data);
    return List<Matpel>.from(data.map((item) => Matpel.fromJson(item)));
}