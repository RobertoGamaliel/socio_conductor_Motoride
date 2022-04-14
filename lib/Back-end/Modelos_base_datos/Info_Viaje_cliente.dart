class Info_Viaje_cliente {
  Info_Viaje_cliente(
      this.uid,
      this.foto,
      this.dir_origen,
      this.dir_destino,
      this.nombre,
      this.fecha,
      this.lat_origen,
      this.lat_destino,
      this.lon_destino,
      this.lon_origen,
      this.costo,
      this.puntos,
      this.viajes,
      this.estado,
      this.pasajeros,
      this.raites);
  String uid, foto, dir_origen, dir_destino, nombre, fecha;
  double lat_origen, lon_origen, lat_destino, lon_destino, costo;
  int puntos, viajes, estado, pasajeros, raites;
}
