import 'dart:convert';

Registro_M registroFromJson(String str) =>
    Registro_M.fromJson(json.decode(str));

String registroToJson(Registro_M data) => json.encode(data.toJson());
//Esta clase se es para guardar registros de movimeintos importantes del usuario

//La clase lleva tanto el id del registro en firestore como el id del usuario que lo esta relizando
//el objetivo de esto es que solo se puedan descargar de firestore los movimeintos que lleven el id del usuario
//de quien lo esta solicitando.
//el atributo concepto debe contener la descripcion del movimento que se realizó.
//las variables valor_anterior y valor_actual contiene el dato antes del moviento y despues de realizarlo
//la calse fecha es un un DateTime.toString del momento en que se realizo el registro
class Registro_M {
  Registro_M(
      {this.id_registro,
      this.id_socio,
      this.concepto,
      this.valor_anterior,
      this.valor_actual,
      this.fecha});

  String id_registro;
  String id_socio;
  String concepto;
  String valor_anterior;
  String valor_actual;
  String fecha;

  factory Registro_M.fromJson(Map<String, dynamic> json) => Registro_M(
        id_registro: json["id_registro"],
        id_socio: json["id_socio"],
        concepto: json["concepto"],
        valor_anterior: json["valor_anterior"],
        valor_actual: json["valor_actual"],
        fecha: json["fecha"],
      );

  Map<String, dynamic> toJson() => {
        "id_registro": id_registro,
        "id_socio": id_socio,
        "concepto": concepto,
        "valor_anterior": valor_anterior,
        "valor_actual": valor_actual,
        "fecha": fecha,
      };
}
