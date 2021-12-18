import 'dart:convert';

class Cart {
  Cart({
    this.kode_item,
    this.harga,
    this.jenis,
    this.nama_produk,
    this.jumlah,
    this.total,
    this.file
  });

  String kode_item;
  String nama_produk;
  String jenis;
  String harga;
  int jumlah;
  int total;
  String file;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
        kode_item: json["kode_item"],
        nama_produk: json["nama_produk"],
        jenis: json["jenis"],
        harga: json["harga"],
        jumlah: int.parse(json["jumlah"].toString()),
        total: int.parse(json["total"].toString()),
        file: json["file"]
    );
  }

}
  
List<Cart> cartFromJson(String jsonData) {
    final data = json.decode(jsonData)['data'];
    return List<Cart>.from(data.map((item) => Cart.fromJson(item)));
}