import 'dart:convert';

Reg_solicitud_viaje objetFromJson(String str) =>
    Reg_solicitud_viaje.fromJson(json.decode(str));
String objetToJson(Reg_solicitud_viaje data) => json.encode(data.toJson());

class Reg_solicitud_viaje {
  Reg_solicitud_viaje(
      {this.id,
      this.lat_origen,
      this.lon_origen,
      this.lat_destino,
      this.lon_destino,
      this.direccion_origen,
      this.direccion_destino,
      this.costo_viaje,
      this.rating_viajero,
      this.num_pasajeros,
      this.fecha,
      this.nombre_viajero,
      this.uid_viajero,
      this.uid_chofer,
      this.raites,
      this.foto});

  String id,
      direccion_origen,
      direccion_destino,
      fecha,
      nombre_viajero,
      uid_viajero,
      uid_chofer,
      foto;
  double lat_origen,
      lon_origen,
      lat_destino,
      lon_destino,
      costo_viaje,
      rating_viajero;
  int num_pasajeros, raites;

  factory Reg_solicitud_viaje.fromJson(Map<String, dynamic> json) =>
      Reg_solicitud_viaje(
          id: json["id"],
          foto: json["foto"],
          raites: json["raites"],
          lat_origen: json["lat_origen"],
          lon_origen: json["lon_origen"],
          lat_destino: json["lat_destino"],
          lon_destino: json["lon_destino"],
          direccion_origen: json["direccion_origen"],
          direccion_destino: json["direccion_destino"],
          costo_viaje: json["costo_viaje"],
          rating_viajero: json["rating_viajero"],
          num_pasajeros: json["num_pasajeros"],
          fecha: json["fecha"],
          nombre_viajero: json["nombre_viajero"],
          uid_viajero: json["uid_viajero"],
          uid_chofer: json["uid_chofer"]);
  Map<String, dynamic> toJson() => {
        "id": id,
        "foto": foto,
        "raites": raites,
        "lat_origen": lat_origen,
        "lon_origen": lon_origen,
        "lat_destino": lat_destino,
        "lon_destino": lon_destino,
        "direccion_origen": direccion_origen,
        "direccion_destino": direccion_destino,
        "costo_viaje": costo_viaje,
        "rating_viajero": rating_viajero,
        "num_pasajeros": num_pasajeros,
        "fecha": fecha,
        "nombre_viajero": nombre_viajero,
        "uid_viajero": uid_viajero,
        "uid_chofer": uid_chofer
      };
}
