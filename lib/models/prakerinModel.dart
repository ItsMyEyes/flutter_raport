import 'dart:convert';
import 'dart:ui';


class Prakerin {
  Prakerin({
    this.id,
    this.nama_tempat,
    this.lokasi,
    this.lama,
    this.keterangan,
    this.nis
  });

  String id;
  String nis;
  String nama_tempat;
  String lokasi;
  String lama;
  String keterangan;

  factory Prakerin.fromJson(Map<String, dynamic> json) {
    return Prakerin(
        id: json['id'].toString(),
        nis: json['induk'].toString(),
        nama_tempat: json['nama_tempat'],
        lokasi: json['lokasi'],
        lama: json['lama'].toString(),
        keterangan: json['keterangan']
    );
  }

}
  
List<Prakerin> prakerinFromJson(String jsonData) {
    final data = json.decode(jsonData)['data'];
    print(data);
    return List<Prakerin>.from(data.map((item) => Prakerin.fromJson(item)));
}
