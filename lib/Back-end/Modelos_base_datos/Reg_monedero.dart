import 'dart:convert';
Reg_monedero monederoFromJson(String str) =>
Reg_monedero.fromJson(json.decode(str));
String monederoToJson(Reg_monedero data) => json.encode(data.toJson());
class Reg_monedero {
  Reg_monedero({
    this.id,
    this.id_socio,
    this.id_conductor,
    this.fecha,
    this.monto,
    this.saldo_anterior,
    this.tipo_transaccion,
    this.tipo
  });

  String id, id_socio, id_conductor, fecha;
  double monto,saldo_anterior;
  int tipo_transaccion, tipo;

  factory Reg_monedero.fromJson(Map<String, dynamic> json) => Reg_monedero(
    id: json["id"],
    id_socio: json["id_socio"],
    id_conductor: json["id_conductor"],
    fecha: json["fecha"],
    monto: json["monto"],
    saldo_anterior: json["saldo_anterior"],
    tipo_transaccion: json["tipo_transaccion"],
    tipo: json["tipo"]
  );
  Map<String, dynamic> toJson() => {
    "id":id,
    "id_socio":id_socio,
    "id_conductor":id_conductor,
    "fecha":fecha,
    "monto":monto,
    "saldo_anterior":saldo_anterior,
    "tipo_transaccion":tipo_transaccion,
    "tipo":tipo
  };
}