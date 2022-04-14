import 'dart:math';
import 'package:connection_verify/connection_verify.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';

import 'Modelos_base_datos/Tarifas_M.dart';

class Direcciones {
  Direcciones();

  datos_de_la_ruta(maps.LatLng _from, maps.LatLng _to, Tarifas_M _tarifas,
      BuildContext context) async {
    if (!await ConnectionVerify.connectionStatus()) {
      await Funciones().dialogo_sin_internet(context);
      return [];
    }
    GoogleMapsDirections _direccionesApi =
        GoogleMapsDirections(apiKey: "AIzaSyDGBoI697rJxVex-lpemMjTNYIsAR7TKQg");

    String _dir_origen = "", _dir_destino = "";

    Location _origen = Location(lat: _from.latitude, lng: _from.longitude);
    Location _destino = Location(lat: _to.latitude, lng: _to.longitude);
    var _ruta = Set();
    num _distancia = 0;
    List<maps.LatLng> _puntos;
    DirectionsResponse _resultado;
    try {
      _resultado = await _direccionesApi.directions(_origen, _destino,
          travelMode: TravelMode.driving);
    } catch (e) {
      return [];
    }

    if (_resultado.isOkay) {
      var _leg = _resultado.routes[0].legs[0];

      ///con el objeto leg vamos a crear la ruta que se trazara en los polylines
      List<maps.LatLng> _puntos = [];

      ///Tambien usaremos el valor distancia de cada step para calcular la distancia el recorrido
      _dir_origen = _leg.startAddress;
      _dir_destino = _leg.endAddress;

      _leg.steps.forEach((_step) {
        _distancia += _step.distance.value;

        _puntos
            .add(maps.LatLng(_step.startLocation.lat, _step.startLocation.lng));
        _puntos.add(maps.LatLng(_step.endLocation.lat, _step.endLocation.lng));
      });

      ///como ya tenemos la distancia ahora tenmos que calcular el costo, multiplicamos el costo por km recorrido
      ///y enviamos el maximo valor entre costo minimo y el costo en km recorridos

      ///ahora que ya tenemos los puntos que trazan la ruta de leg, definimos el polyline
      var _linea = maps.Polyline(
        polylineId: const maps.PolylineId("VIAJE"),
        points: _puntos,
        color: Colors.green[900],
        width: 3,
      );

      _ruta.add(_linea);
    } else {
      return [];
    }

    double _precio =
        max((_tarifas.precioKM * (_distancia / 1000)), _tarifas.costoMinimo);

    _precio = double.parse(_precio.toStringAsFixed(2));

    return [_ruta, _precio, _distancia, _dir_origen, _dir_destino];
  }

  Future<maps.Polyline> ruta(
      maps.LatLng _from, maps.LatLng _to, BuildContext context) async {
    if (!await ConnectionVerify.connectionStatus()) {
      await Funciones().dialogo_sin_internet(context);
      return null;
    }
    GoogleMapsDirections _direccionesApi =
        GoogleMapsDirections(apiKey: "AIzaSyDGBoI697rJxVex-lpemMjTNYIsAR7TKQg");

    maps.Polyline _ruta;
    num _distancia = 0;
    List<maps.LatLng> _puntos;
    DirectionsResponse _resultado;

    if (_resultado.isOkay) {
      var _leg = _resultado.routes[0].legs[0];

      ///con el objeto leg vamos a crear la ruta que se trazara en los polylines
      List<maps.LatLng> _puntos = [];

      _leg.steps.forEach((_step) {
        _distancia += _step.distance.value;

        _puntos
            .add(maps.LatLng(_step.startLocation.lat, _step.startLocation.lng));
        _puntos.add(maps.LatLng(_step.endLocation.lat, _step.endLocation.lng));
      });

      ///como ya tenemos la distancia ahora tenmos que calcular el costo, multiplicamos el costo por km recorrido
      ///y enviamos el maximo valor entre costo minimo y el costo en km recorridos

      ///ahora que ya tenemos los puntos que trazan la ruta de leg, definimos el polyline
      _ruta = maps.Polyline(
        polylineId: const maps.PolylineId("VIAJE"),
        points: _puntos,
        color: Colors.green[900],
        width: 5,
      );
    } else {
      return null;
    }

    return _ruta;
  }
}
