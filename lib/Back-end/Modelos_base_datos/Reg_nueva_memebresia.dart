import 'dart:convert';

Reg_nueva_memebresia nuevaFromJson(String str) =>
    Reg_nueva_memebresia.fromJson(json.decode(str));

String nuevaToJson(Reg_nueva_memebresia data) => json.encode(data.toJson());

class Reg_nueva_memebresia {
  Reg_nueva_memebresia({
    this.id,
    this.fecha,
    this.id_socio,
    this.costo,
    this.modalidad,
    this.tipo,
  });

  String fecha, id, id_socio;
  double costo;
  int modalidad, tipo;

  factory Reg_nueva_memebresia.fromJson(Map<String, dynamic> json) =>
      Reg_nueva_memebresia(
        id: json["id"],
        fecha: json["fecha"],
        id_socio: json["id_socio"],
        costo: json["costo"],
        modalidad: json["modalidad"],
        tipo: json["tipo"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "fecha": fecha,
        "id_socio": id_socio,
        "costo": costo,
        "modalidad": modalidad,
        "tipo": tipo,
      };
}
