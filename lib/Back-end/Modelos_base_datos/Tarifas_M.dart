import 'dart:convert';

Tarifas_M objetFromJson(String str) => Tarifas_M.fromJson(json.decode(str));
String objetToJson(Tarifas_M data) => json.encode(data.toJson());

class Tarifas_M {
  //Guardar las variables que se usaran par definir los cobros, este objeto usa variables de tipo final
  //es decir, que una vez son declaradas no es posible reasignarles otro valor, esto se hará para
  //garantzar que no podra ser alterada una vez se descargue sus valores.
  Tarifas_M(
      {this.costoMinimo,
      this.penalizacion,
      this.precioKM,
      this.membresia,
      this.raites_por_membresia,
      this.raites_por_sorteo,
      this.fecha,
      this.valor_raite});

  final double costoMinimo, penalizacion, precioKM, membresia, valor_raite;
  final int raites_por_membresia, raites_por_sorteo;
  String fecha;

  factory Tarifas_M.fromJson(Map<String, dynamic> json) => Tarifas_M(
      costoMinimo: json["costoMinimo"],
      penalizacion: json["penalizacion"],
      precioKM: json["precioKM"],
      membresia: json["membresia"],
      raites_por_membresia: json["raites_por_membresia"],
      raites_por_sorteo: json["raites_por_sorteo"],
      valor_raite: json["valor_raite"]);
  Map<String, dynamic> toJson() => {
        "costoMinimo": costoMinimo,
        "penalizacion": penalizacion,
        "precioKM": precioKM,
        "membresia": membresia,
        "raites_por_membresia": raites_por_membresia,
        "raites_por_sorteo": raites_por_sorteo,
        "valor_raite": valor_raite
      };
}
