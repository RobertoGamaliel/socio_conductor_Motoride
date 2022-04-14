import 'dart:convert';
Reg_renovacionMemebresia renovacionFromJson(String str) =>
Reg_renovacionMemebresia.fromJson(json.decode(str));
String renovacionToJson(Reg_renovacionMemebresia data) => json.encode(data.toJson());
class Reg_renovacionMemebresia {
  Reg_renovacionMemebresia(
  {
    this.id,
    this.fecha,
    this.id_socio,
    this.pago_adeudo_servicios,
    this.pago_adeudo_memebresia,
    this.pago_renovacion,
    this.modalidad,
    this.tipo
  });

  String id, fecha, id_socio;
  double pago_adeudo_servicios,pago_adeudo_memebresia,pago_renovacion;
  int modalidad, tipo;
  factory Reg_renovacionMemebresia.fromJson(Map<String, dynamic> json) => Reg_renovacionMemebresia(
    id: json["id"],
    fecha: json["fecha"],
    id_socio: json["id_socio"],
    pago_adeudo_servicios: json["pago_adeudo_servicios"],
    pago_adeudo_memebresia: json["pago_adeudo_memebresia"],
    pago_renovacion: json["pago_renovacion"],
    modalidad: json["modalidad"],
    tipo: json["tipo"],
  );
  Map<String, dynamic> toJson() => {
    "id":id,
    "fecha":fecha,
    "id_socio":id_socio,
    "pago_adeudo_servicios":pago_adeudo_servicios,
    "pago_adeudo_memebresia":pago_adeudo_memebresia,
    "pago_renovacion":pago_renovacion,
    "modalidad":modalidad,
    "tipo":tipo,
  };
}