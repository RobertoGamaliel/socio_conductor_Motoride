import 'dart:convert';

Viaje_M viajeFromJson(String str) => Viaje_M.fromJson(json.decode(str));
String viajeToJson(Viaje_M data) => json.encode(data.toJson());

/*
Esta clase contiene la informacion necesaria para un viaje por parte del socio viajero.
incluye la latitud y longitud para el punto de origen, destino y la posicion actual (util durante el viaje),
La informacion de conductor será proporcionada por el socio conductor que acepte el viaje
el estado 0 es el estado incial y solo sera cambiado por el conductor una vez que inicie y/o finalice el viaje. 
El solcio viajero podra cambiarlo solo a estado cancelado.

 */
class Viaje_M {
  Viaje_M(
      { //0=peticion, 1=inicialdo, 2=concluido, 3=cancelado por el viajero, 4=cancelado por conductor
      this.id,
      this.nombre_chofer,
      this.lat_chofer,
      this.lon_chofer,
      this.viajes_chofer,
      this.foto,
      this.vijaero1,
      this.viajero2,
      this.viajero3,
      this.estado_viaje1,
      this.estado_viaje2,
      this.estado_viaje3});

  String id, nombre_chofer, foto, vijaero1, viajero2, viajero3;
  double lat_chofer, lon_chofer;
  int viajes_chofer, estado_viaje1, estado_viaje2, estado_viaje3;

  factory Viaje_M.fromJson(Map<String, dynamic> json) => Viaje_M(
      id: json["id"],
      nombre_chofer: json["nombre_chofer"],
      lat_chofer: json["lat_chofer"],
      lon_chofer: json["lon_chofer"],
      viajes_chofer: json["viajes_chofer"],
      foto: json["foto"],
      vijaero1: json["vijaero1"],
      viajero2: json["viajero2"],
      viajero3: json["viajero3"],
      estado_viaje1: json["estado_viaje1"],
      estado_viaje2: json["estado_viaje2"],
      estado_viaje3: json["estado_viaje3"]);
  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre_chofer": nombre_chofer,
        "lat_chofer": lat_chofer,
        "lon_chofer": lon_chofer,
        "viajes_chofer": viajes_chofer,
        "foto": foto,
        "vijaero1": vijaero1,
        "viajero2": viajero2,
        "viajero3": viajero3,
        "estado_viaje1": estado_viaje1,
        "estado_viaje2": estado_viaje2,
        "estado_viaje3": estado_viaje3
      };
}
