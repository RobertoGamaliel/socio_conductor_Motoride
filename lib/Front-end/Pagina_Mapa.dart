// ignore_for_file: prefer_const_constructors, prefer_final_fields, unrelated_type_equality_checks, prefer_conditional_assignment, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:socio_conductor/Back-end/BD.dart';
import 'package:socio_conductor/Back-end/Ciudades.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Mi_Perfil_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_solicitud_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Tarifas_M.dart';
import 'package:socio_conductor/Front-end/Animacion_tombola.dart';
import 'package:socio_conductor/Front-end/Inicio_sesion.dart';
import 'package:socio_conductor/Front-end/Pagina_opciones.dart';

class Pagina_Mapa extends StatefulWidget {
  Pagina_Mapa(this._misDatos, this._miViaje, this._tarifas, this._pos);
  Perfil_conductor_M _misDatos;
  List<Reg_solicitud_viaje> _viajantes = [];
  Tarifas_M _tarifas;
  Reg_viaje _miViaje;
  Position _pos;

  @override
  _Pagina_MapaState createState() => _Pagina_MapaState(_misDatos, _miViaje);
}

class _Pagina_MapaState extends State<Pagina_Mapa> {
  _Pagina_MapaState(this._misDatos, this._miViaje);
  final Perfil_conductor_M _misDatos;
  Size s;
  maps.GoogleMapController _controlador; //controlador del widget mapas
  maps.Marker _destino3, _destino1, _destino2, _miUbicacion;

  maps.BitmapDescriptor _icono_auto,
      _icono_viaje1,
      _icono_viaje2,
      _icono_viaje3,
      _icono_destino1,
      _icono_destino2,
      _icono_destino3;

  List<Reg_solicitud_viaje> _solicitudes = [];
  Reg_solicitud_viaje _misolicitud;
  Funciones _f = new Funciones();
  bool _viajando = false;
  bool _gps_habilitado = false;
  bool _permisos_gps_habilitaados = false;
  bool _escuchandoViajes = false;
  bool _marcador_de_auto = false;
  bool _esperando_pago = false;
  bool _pantalla_pago = false;
  bool _vista_alta = false;
  bool _primera_revision = true;
  bool _activa_tombola = false;
  bool _pantalla_tombola = false;
  bool _terminando_viaje = false;
  int _asientos_libres1 = 1, _asientos_libres2;
  int _pantalla = 1;
  Reg_viaje _miViaje;
  String _path1, _path2;

  /////////////////
  Set<maps.Polyline> _ruta = Set();
  Resultados_viaje _resultados;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _listener_viaje;
  StreamSubscription<QuerySnapshot> _listener_solicitudes;
  StreamSubscription<Position> _listenerGPS;
  ButtonStyle _style =
          ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) return Colors.green[900];
          return Colors.black; // Use the component's default.
        },
      )),
      _style2 = ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Colors.yellow[900];
            return Colors.white; // Use the component's default.
          },
        ),
      );
  @override
  Widget build(BuildContext context) {
    _inicializar();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        actions: _appbar_mnu(),
      ),
      body: Stack(
        children: [
          Container(
            width: s.width,
            height: s.height,
            child: maps.GoogleMap(
              polylines: _ruta,
              mapType: maps.MapType.normal,
              initialCameraPosition: maps.CameraPosition(
                  target:
                      maps.LatLng(widget._pos.latitude, widget._pos.longitude),
                  zoom: 14),
              onMapCreated: (maps.GoogleMapController _control) async {
                _controlador = _control;
                if ((_miViaje.uid_v1 != null && _miViaje.uid_v1 != "") ||
                    (_miViaje.uid_v2 != null && _miViaje.uid_v2 != "") ||
                    (_miViaje.uid_v3 != null && _miViaje.uid_v3 != "")) {
                  await _actualizar_marcadores();
                  await _actualizar_mi_marcador(widget._pos);
                  await _centrar_viaje();
                }
              },
              markers: {
                if (_miUbicacion != null) _miUbicacion,
                if (_destino1 != null) _destino1,
                if (_destino2 != null) _destino2,
                if (_destino3 != null) _destino3
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _area_solicitudes(),
              Flex(
                direction: Axis.vertical,
                children: [
                  _aviso_inicio_de_viaje(),
                ],
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
          _pantalla_fin_de_viaje(),
          _f.pantalla_carga_espera(_terminando_viaje, s),
          _avisoFueraDeZona(),
          _avisoGPSApagado()
        ],
      ),
    );
  }

  List<Widget> _appbar_mnu() {
    if (!_terminando_viaje) {
      return [
        Container(
            width: s.width,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              direction: Axis.horizontal,
              children: [
                GestureDetector(
                    onTap: _miViaje.uid_v1 != null && _miViaje.uid_v1 != ""
                        ? () {
                            _f.dialogo_infor_viaje(
                                _f.info_de_viaje(_miViaje, 1), 1, context, s);
                          }
                        : () {},
                    onLongPress: _miViaje.uid_v1 != null &&
                            _miViaje.uid_v1 != "" &&
                            _miViaje.estado_viaje1 < 3 &&
                            !_esperando_pago
                        ? () async {
                            if (!await _f.dialogoConRespuesta(
                                "¿CANCELAR EL VIAJE?",
                                "La cancelacion de viajes queda registrada en su perfi de socio conductor, desea cacelar esta solicitud?",
                                context)) return;

                            setState(() {
                              _terminando_viaje = true;
                            });

                            if (!await BD.bd.agregar_cargo_a_viajero(
                                _miViaje.uid_v1, 0, 0)) {
                              await _f.dialogo(
                                  "error",
                                  "AL ACTUALIZAR EL PERFIL DEL USUARIO",
                                  context);
                              setState(() {
                                _terminando_viaje = false;
                              });
                              return;
                            }

                            var _v = await BD.bd.concluir_viaje(1, _miViaje);
                            if (_v != null) {
                              _miViaje = _v;
                              _revisar_asientos_libres();
                            }

                            await _actualizar_marcadores();
                            await _trazar_ruta();
                            await _centrar_viaje();
                            _terminando_viaje = false;
                            setState(() {});
                          }
                        : _miViaje.uid_v1 != null &&
                                _miViaje.uid_v1 != "" &&
                                _miViaje.estado_viaje1 == 3 &&
                                !_esperando_pago
                            ? () async {
                                //confirmacion de terminar el viaje
                                if (!await _f.dialogoConRespuesta(
                                    "¿TERMINAR EL VIAJE?",
                                    "Confirme si desea dar por concluido el viaje de ${_miViaje.nombre_v1}.",
                                    //"Se realizará el cobro tomando el cuenta el punto donde recogio a ${_miViaje.nombre_v1} hasta la ubicación actual.\n\n¿Desea continuar?",
                                    context)) {
                                  return;
                                }

                                setState(() {
                                  _terminando_viaje = true;
                                });
                                //esta funcion se ejecuta hasta que no tengamos la ubicacion
                                Position _posi =
                                    await _f.obtener_ubicacion(context);
                                while (_posi == null) {
                                  _posi = await _f.obtener_ubicacion(context);
                                }

                                //creamos los objetos latlang
                                maps.LatLng _from = maps.LatLng(
                                        _miViaje.lat_origen1,
                                        _miViaje.lon_origen1),
                                    _to = maps.LatLng(
                                        _posi.latitude, _posi.longitude);

                                //actualizamos el marcador del chofer con la ubicacion actual
                                await _actualizar_mi_marcador(_posi);

                                //actualizamos la ubicacion del destino del pasajero que va a bajar
                                _miViaje.lat_destino1 = _posi.latitude;
                                _miViaje.lon_destino1 = _posi.longitude;
/*
                                //calculamos el precio del viaje
                                List<dynamic> _precios = await Direcciones()
                                    .datos_de_la_ruta(
                                        _from, _to, widget._tarifas, context);

                                if (_precios == []) {
                                  await _f.dialogo(
                                      "PROBLEMA AL OBTENER LOS PRECIOS",
                                      "",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                //verificamos si se ejecutará la tombola
                                int _llamado_a_tombola =
                                    await _tombola(_miViaje.uid_v1);

                                //casi en que no hay internet
                                if (_llamado_a_tombola == -1) {
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                } else if (_llamado_a_tombola == 4) {
                                  //caso si hay un error desconocido
                                  await _f.dialogo(
                                      "ERROR",
                                      "Hubo un problema al procesar la solicitud.",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                num _precio00 = _precios[1];
                                if (_llamado_a_tombola == 2) {
                                  _precio00 = _precio00 / 2;
                                } else if (_llamado_a_tombola == 3) {
                                  _precio00 = 10;
                                } else if (_llamado_a_tombola == 1) {
                                  _precio00 = 0;
                                }

                                _resultados = Resultados_viaje(
                                    _precio00,
                                    _precios[2],
                                    _miViaje.nombre_v1,
                                    _miViaje.uid_v1,
                                    1);
                                    */
                                _resultados = Resultados_viaje(0, 0,
                                    _miViaje.nombre_v1, _miViaje.uid_v1, 1);
                                _pantalla_pago = true;
                                _terminando_viaje = false;

                                setState(() {});
                              }
                            : () {},
                    child: _miViaje.uid_v1 != null && _miViaje.uid_v1 != ""
                        ? Container(
                            width: s.height * .07,
                            height: s.height * .07,
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/viaje1.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )
                        : Container(
                            width: s.height * .05,
                            height: s.height * .05,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/disable_viaje1.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: _miViaje.uid_v2 != null && _miViaje.uid_v2 != ""
                        ? () {
                            _f.dialogo_infor_viaje(
                                _f.info_de_viaje(_miViaje, 2), 2, context, s);
                          }
                        : () {},
                    onLongPress: _miViaje.uid_v2 != null &&
                            _miViaje.uid_v2 != "" &&
                            _miViaje.estado_viaje2 < 3 &&
                            !_esperando_pago
                        ? () async {
                            if (!await _f.dialogoConRespuesta(
                                "¿CANCELAR EL VIAJE?",
                                "La cancelacion de viajes queda registrada en su perfi de socio conductor, desea cacelar esta solicitud?",
                                context)) return;

                            setState(() {
                              _terminando_viaje = true;
                            });

                            if (!await BD.bd.agregar_cargo_a_viajero(
                                _miViaje.uid_v2, 0, 0)) {
                              await _f.dialogo(
                                  "error",
                                  "AL ACTUALIZAR EL PERFIL DEL USUARIO",
                                  context);
                              setState(() {
                                _terminando_viaje = false;
                              });
                              return;
                            }
                            var _v = await BD.bd.concluir_viaje(2, _miViaje);
                            if (_v != null) {
                              _miViaje = _v;
                              _revisar_asientos_libres();
                            }
                            await _actualizar_marcadores();
                            await _trazar_ruta();
                            await _centrar_viaje();
                            _terminando_viaje = false;
                            setState(() {});
                          }
                        : _miViaje.uid_v2 != null &&
                                _miViaje.uid_v2 != "" &&
                                _miViaje.estado_viaje2 == 3 &&
                                !_esperando_pago
                            ? () async {
                                //confirmacion de terminar el viaje
                                if (!await _f.dialogoConRespuesta(
                                    "¿TERMINAR EL VIAJE?",
                                    "Confirme si desea dar por concluido el viaje de ${_miViaje.nombre_v2}.",
                                    //"Se realizará el cobro tomando el cuenta el punto donde recogio a ${_miViaje.nombre_v2} hasta la ubicación actual.\n\n¿Desea continuar?",
                                    context)) return;

                                setState(() {
                                  _terminando_viaje = true;
                                });

                                //esta funcion se ejecuta hasta que no tengamos la ubicacion
                                Position _posi =
                                    await _f.obtener_ubicacion(context);
                                while (_posi == null) {
                                  _posi = await _f.obtener_ubicacion(context);
                                }

                                //creamos los objetos latlang
                                maps.LatLng _from = maps.LatLng(
                                        _miViaje.lat_origen2,
                                        _miViaje.lon_origen2),
                                    _to = maps.LatLng(
                                        _posi.latitude, _posi.longitude);

                                //verificar que hay internet
                                if (!await ConnectionVerify
                                    .connectionStatus()) {
                                  await _f.dialogo_sin_internet(context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }
                                //actualizamos el marcador del chofer con la ubicacion actual
                                await _actualizar_mi_marcador(_posi);

                                //actualizamos la ubicacion del destino del pasajero que va a bajar
                                _miViaje.lat_destino2 = _posi.latitude;
                                _miViaje.lon_destino2 = _posi.longitude;
/*
                                //calculamos el precio del viaje
                                List<dynamic> _precios = await Direcciones()
                                    .datos_de_la_ruta(
                                        _from, _to, widget._tarifas, context);

                                if (_precios == []) {
                                  await _f.dialogo(
                                      "PROBLEMA AL OBTENER LOS PRECIOS",
                                      "",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                //verificamos si se ejecutará la tombola
                                int _llamado_a_tombola =
                                    await _tombola(_miViaje.uid_v2);

                                //casi en que no hay internet
                                if (_llamado_a_tombola == -1) {
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                } else if (_llamado_a_tombola == 4) {
                                  //caso si hay un error desconocido
                                  await _f.dialogo(
                                      "ERROR",
                                      "Hubo un problema al procesar la solicitud.",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                num _precio00 = _precios[1];
                                if (_llamado_a_tombola == 2) {
                                  _precio00 = _precio00 / 2;
                                } else if (_llamado_a_tombola == 3) {
                                  _precio00 = 10;
                                } else if (_llamado_a_tombola == 1) {
                                  _precio00 = 0;
                                }

                                _resultados = Resultados_viaje(
                                    _precio00,
                                    _precios[2],
                                    _miViaje.nombre_v2,
                                    _miViaje.uid_v2,
                                    2);*/
                                _resultados = Resultados_viaje(0, 0,
                                    _miViaje.nombre_v2, _miViaje.uid_v2, 2);
                                _pantalla_pago = true;
                                _terminando_viaje = false;
                                setState(() {});
                              }
                            : () {},
                    child: _miViaje.uid_v2 != null && _miViaje.uid_v2 != ""
                        ? Container(
                            width: s.height * .07,
                            height: s.height * .07,
                            decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/viaje2.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )
                        : Container(
                            width: s.height * .05,
                            height: s.height * .05,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/disable_viaje2.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: _miViaje.uid_v3 != null && _miViaje.uid_v3 != ""
                        ? () {
                            _f.dialogo_infor_viaje(
                                _f.info_de_viaje(_miViaje, 2), 2, context, s);
                          }
                        : () {},
                    onLongPress: _miViaje.uid_v3 != null &&
                            _miViaje.uid_v3 != "" &&
                            _miViaje.estado_viaje3 < 3 &&
                            !_esperando_pago
                        ? () async {
                            if (!await _f.dialogoConRespuesta(
                                "¿CANCELAR EL VIAJE?",
                                "La cancelacion de viajes queda registrada en su perfi de socio conductor, desea cacelar esta solicitud?",
                                context)) return;

                            setState(() {
                              _terminando_viaje = true;
                            });

                            if (!await BD.bd.agregar_cargo_a_viajero(
                                _miViaje.uid_v3, 0, 0)) {
                              await _f.dialogo(
                                  "error",
                                  "AL ACTUALIZAR EL PERFIL DEL USUARIO",
                                  context);
                              setState(() {
                                _terminando_viaje = false;
                              });
                              return;
                            }
                            var _v = await BD.bd.concluir_viaje(3, _miViaje);
                            if (_v != null) {
                              _miViaje = _v;
                              _revisar_asientos_libres();
                            }
                            await _actualizar_marcadores();
                            await _trazar_ruta();
                            await _centrar_viaje();
                            _terminando_viaje = false;
                            setState(() {});
                          }
                        : _miViaje.uid_v3 != null &&
                                _miViaje.uid_v3 != "" &&
                                _miViaje.estado_viaje3 == 3 &&
                                !_esperando_pago
                            ? () async {
                                //confirmacion de terminar el viaje
                                if (!await _f.dialogoConRespuesta(
                                    "¿TERMINAR EL VIAJE?",
                                    "Confirme si desea dar por concluido el viaje de ${_miViaje.nombre_v3}.",
                                    //"Se realizará el cobro tomando el cuenta el punto donde recogió a ${_miViaje.nombre_v3} hasta la ubicación actual.\n\n¿Desea continuar?",
                                    context)) return;

                                setState(() {
                                  _terminando_viaje = true;
                                });

                                //esta funcion se ejecuta hasta que no tengamos la ubicacion
                                Position _posi =
                                    await _f.obtener_ubicacion(context);
                                while (_posi == null) {
                                  _posi = await _f.obtener_ubicacion(context);
                                }

                                //creamos los objetos latlang
                                maps.LatLng _from = maps.LatLng(
                                        _miViaje.lat_origen3,
                                        _miViaje.lon_origen3),
                                    _to = maps.LatLng(
                                        _posi.latitude, _posi.longitude);

                                //verificar que hayinternet
                                if (!await ConnectionVerify
                                    .connectionStatus()) {
                                  await _f.dialogo_sin_internet(context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                //actualizamos el marcador del chofer con la ubicacion actual
                                await _actualizar_mi_marcador(_posi);

                                //actualizamos la ubicacion del destino del pasajero que va a bajar
                                _miViaje.lat_destino3 = _posi.latitude;
                                _miViaje.lon_destino3 = _posi.longitude;
/*
                                //calculamos el precio del viaje
                                List<dynamic> _precios = await Direcciones()
                                    .datos_de_la_ruta(
                                        _from, _to, widget._tarifas, context);

                                if (_precios == []) {
                                  await _f.dialogo(
                                      "PROBLEMA AL OBTENER LOS PRECIOS",
                                      "",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }
*/
                                //verificamos si se ejecutará la tombola
                                int _llamado_a_tombola =
                                    await _tombola(_miViaje.uid_v3);

                                //caso en que no hay internet
                                if (_llamado_a_tombola == -1) {
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                } else if (_llamado_a_tombola == 4) {
                                  //caso si hay un error desconocido
                                  await _f.dialogo(
                                      "ERROR",
                                      "Hubo un problema al procesar la solicitud.",
                                      context);
                                  setState(() {
                                    _terminando_viaje = false;
                                  });
                                  return;
                                }

                                /* num _precio00 = _precios[1];
                                if (_llamado_a_tombola == 2) {
                                  _precio00 = _precio00 / 2;
                                } else if (_llamado_a_tombola == 3) {
                                  _precio00 = 10;
                                } else if (_llamado_a_tombola == 1) {
                                  _precio00 = 0;
                                }

                                _resultados = Resultados_viaje(
                                    _precio00,
                                    _precios[2],
                                    _miViaje.nombre_v3,
                                    _miViaje.uid_v3,
                                    3);
                                */

                                _resultados = Resultados_viaje(0, 0,
                                    _miViaje.nombre_v3, _miViaje.uid_v3, 3);

                                _pantalla_pago = true;

                                setState(() {});
                              }
                            : () {},
                    child: _miViaje.uid_v3 != null && _miViaje.uid_v3 != ""
                        ? Container(
                            width: s.height * .07,
                            height: s.height * .07,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/viaje3.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )
                        : Container(
                            width: s.height * .05,
                            height: s.height * .05,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/logos/disable_viaje3.png",
                                    ),
                                    fit: BoxFit.cover)),
                          )),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: () {
                      _f.dialogo(
                          "EN DESARROLLO",
                          "Este boton mostrará la estadisticas del turno del conductor",
                          context);
                    },
                    onLongPress: () async {
                      _vista_alta = !_vista_alta;
                      await _centrar_viaje();
                      var _posi = await _f.obtener_ubicacion(context);
                      await _actualizar_mi_marcador(_posi);
                      setState(() {});
                    },
                    child: Container(
                      width: s.height * .06,
                      height: s.height * .06,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                              image: AssetImage(
                                "assets/logos/ride.png",
                              ),
                              fit: BoxFit.cover)),
                    )),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PAgina_opciones(_miViaje))).then((_resp) async {
                      if (_resp == null) return;
                      if (_resp == "cerrar") {
                        if (_listener_solicitudes != null) {
                          try {
                            await _listener_solicitudes.cancel();
                          } catch (e) {}
                        }
                        if (_listener_viaje != null) {
                          try {
                            await _listener_viaje.cancel();
                          } catch (e) {}
                        }

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Inicio_de_sesion()));
                      }
                    });
                  },
                  child: ElevatedButton(
                    style: _style2,
                    child: Icon(
                      Icons.settings,
                      color: Colors.grey[500],
                    ),
                  ),
                )
              ],
            )),
      ];
    } else {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "UN MOMENTO...",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ];
    }
  }

  Widget _pantalla_fin_de_viaje() {
    if (_pantalla_pago &&
        _resultados != null &&
        _resultados._precio != null &&
        _resultados._precio > -1 &&
        _resultados.ditancia != null &&
        _resultados.nombre != null &&
        _resultados.uid != null &&
        _resultados.turno > 0 &&
        _resultados.turno < 4) {
      return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: SizedBox(
              width: s.width,
              height: s.height,
              child: Center(
                  child: ListView(
                children: [
                  /* Container(
                    margin: EdgeInsetsDirectional.fromSTEB(s.width * .05,
                        s.height * .05, s.width * .05, s.height * .01),
                    padding: EdgeInsetsDirectional.fromSTEB(s.width * .025,
                        s.height * .02, s.width * .025, s.height * .02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: Text.rich(
                      TextSpan(
                          text: "VIAJE CONCLUIDO\n",
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                          children: [
                            TextSpan(
                              text: "\nCOSTO DEL VIAJE:",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 25),
                            ),
                            TextSpan(
                              text:
                                  "\n\$ ${_resultados._precio} ${_listener_solicitudes.isPaused}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30),
                            ),
                            TextSpan(
                              text: "\n\nMantenga pulsado el botón ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: "‘PAGADO’",
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: " o ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: "‘NO PAGADO’",
                              style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: " para finalizar el viaje.",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                          ]),
                      textAlign: TextAlign.center,
                    ),
                  ),*/
                  Container(
                    margin: EdgeInsetsDirectional.fromSTEB(s.width * .05,
                        s.height * .05, s.width * .05, s.height * .01),
                    padding: EdgeInsetsDirectional.fromSTEB(s.width * .025,
                        s.height * .02, s.width * .025, s.height * .02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: Text.rich(
                      TextSpan(
                          text: "VIAJE CONCLUIDO\n",
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                          children: [
                            TextSpan(
                              text: "\nGRACIAS POR VIAJAR EN ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 25),
                            ),
                            TextSpan(
                              text: "MotoRide",
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30),
                            ),
                            TextSpan(
                              text: "\n\nMantenga pulsado el botón ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: "‘PAGADO’",
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: " o ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: "‘NO PAGADO’",
                              style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: " para finalizar el viaje.",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                          ]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: s.width * .45,
                        child: ElevatedButton(
                          onLongPress: () async {
                            setState(() {
                              _terminando_viaje = true;
                            });
                            if (!await ConnectionVerify.connectionStatus()) {
                              await _f.dialogo_sin_internet(context);
                              setState(() {
                                _terminando_viaje = false;
                              });
                              return;
                            }
                            if (!await BD.bd.agregar_cargo_a_viajero(
                                _resultados.uid, 0, 1)) {
                              await _f.dialogo(
                                  "error",
                                  "AL ACTUALIZAR EL PERFIL DEL USUARIO",
                                  context);
                              setState(() {
                                _terminando_viaje = false;
                              });
                              return;
                            }

                            var _v = await BD.bd
                                .concluir_viaje(_resultados.turno, _miViaje);
                            if (_v != null) {
                              _miViaje = _v;
                              _revisar_asientos_libres();
                              await _crear_listener_de_solicitudes();
                            }
                            _ruta = null;
                            _ruta = Set();
                            await _actualizar_marcadores();
                            _pantalla_pago = false;
                            _resultados = null;
                            _terminando_viaje = false;
                            setState(() {});
                          },
                          child: Text("PAGADO"),
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.black;
                              return Colors.green[900];
                              // Use the component's default.
                            },
                          )),
                        ),
                      ),
                      Container(
                          width: s.width * .3,
                          child: ElevatedButton(
                            onLongPress: () async {
                              setState(() {
                                _terminando_viaje = true;
                              });
                              if (!await ConnectionVerify.connectionStatus()) {
                                await _f.dialogo_sin_internet(context);
                                setState(() {
                                  _terminando_viaje = false;
                                });
                                return;
                              }
                              if (!await BD.bd.agregar_cargo_a_viajero(
                                  _resultados.uid, _resultados._precio, 1)) {
                                await _f.dialogo(
                                    "error",
                                    "AL ACTUALIZAR EL PERFIL DEL USUARIO",
                                    context);
                                setState(() {
                                  _terminando_viaje = false;
                                });
                                return;
                              }

                              var _v = await BD.bd
                                  .concluir_viaje(_resultados.turno, _miViaje);
                              if (_v != null) {
                                _miViaje = _v;
                                _revisar_asientos_libres();
                                await _crear_listener_de_solicitudes();
                              }
                              _ruta = null;
                              _ruta = Set();

                              await _actualizar_marcadores();

                              _pantalla_pago = false;
                              _resultados = null;
                              _terminando_viaje = false;

                              setState(() {});
                            },
                            child: Text("NO PAGADO"),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.yellow;
                                return Colors
                                    .black; // Use the component's default.
                              },
                            )),
                          ))
                    ],
                  ),
                ],
              ))));
    }
    return _f.invisible();
  }

  Future<int> _tombola(String _id) async {
    ///Esta funcion detecta si se debe de activar la animacion de la tombola o no, retorna un entero como respuesta:
    ///-1: no hay internet,
    /// 0: no se hace ningun ajuste (no hay derecho a tombola)
    /// 1: viaje gratis
    /// 2: 50% descuento
    /// 3: viaje se cobra a $10 pesos
    /// 4: error de algun otro tipo

    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return -1;
    }
    Mi_Perfil_M _perfil_Usuario = await BD.bd.obtener_perfil_viajero(_id);
    if (_perfil_Usuario == null) return 4;

    if (_perfil_Usuario.raites < 10) {
      return 0;
    }

    return await _resultado_tombola();
  }

  Future<int> _resultado_tombola() async {
    int _resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Animacion_tombola()));

    return _resultado;
  }

  Widget _area_solicitudes() {
    if (_solicitudes.isEmpty) {
      return _f.invisible();
    }
    return Container(
      height: s.height * .5,
      child: ListView(
          children: List.generate(
              _solicitudes.length,
              (index) => GestureDetector(
                  onLongPress: () {
                    _viajando = false;
                    _solicitudes = [];
                    _misolicitud = null;
                    setState(() {});
                  },
                  onTap: _viajando ? null : () async {},
                  child: _mensje_viajes(index)))),
    );
  }

  void _inicializar() async {
    s = MediaQuery.of(context).size;
    //crea los iconos que se usaran para los marcadores del mapa
    _crearIconosMarcadores();

    _escuchar_posicion();

    _path1 = Ciudades(4000).carpeta(widget._pos);

    _revisar_asientos_libres();

    //activa el listener de solicitudes de acuerdo a la cantidad de pasajeros en los viajes
    if (!_escuchandoViajes) {
      _escuchandoViajes = true;
      _escuchar_solicitudes();
    }

    if (_primera_revision) {
      _primera_revision = false;
      _revisarViajesCandeladosAlIniciar();
    }
    _miViaje.lat_chofer = widget._pos.latitude;
    _miViaje.lon_chofer = widget._pos.longitude;
  }

  Future<void> _crearIconosMarcadores() async {
    if (_icono_auto == null) {
      _icono_auto = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/iconoRide.png");
    }
    if (_icono_viaje1 == null) {
      _icono_viaje1 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo1.png");
    }
    if (_icono_viaje2 == null) {
      _icono_viaje2 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo2.png");
    }
    if (_icono_viaje3 == null) {
      _icono_viaje3 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo3.png");
    }
    if (_icono_destino1 == null) {
      _icono_destino1 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino1.png");
    }
    if (_icono_destino2 == null) {
      _icono_destino2 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino2.png");
    }
    if (_icono_destino3 == null) {
      _icono_destino3 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino3.png");
    }
  }

  Future<void> _posicion_camara(double _zoom) async {
    //recibe una posicion y la distancia de altura, actualiza la camara del mapa
    if (widget._pos == null || _zoom == null || _zoom < 0) return;
    await _controlador.animateCamera(
      maps.CameraUpdate.newCameraPosition(
        maps.CameraPosition(
            target: maps.LatLng(
              widget._pos.latitude,
              widget._pos.longitude,
            ),
            zoom: _zoom,
            tilt: 45,
            bearing: widget._pos.heading),
      ),
    );
  }

  void _revisarViajesCandeladosAlIniciar() async {
    if (_miViaje.estado_viaje1 == 4) {
      await _viaje_cancelado_cliente(1);
    }

    if (_miViaje.estado_viaje2 == 4) {
      await _viaje_cancelado_cliente(2);
    }

    if (_miViaje.estado_viaje3 == 4) {
      await _viaje_cancelado_cliente(3);
    }

    try {
      setState(() {});
    } catch (e) {
      print(
          "ERROR AL REFRESCAR PANTALLA DESPUES DE LA CANCELACION INICIAL DE VIAJES");
    }

    return;
  }

  Future<void> _actualizar_mi_marcador(Position _pos) async {
    ///Recibe la nueva ubicación
    if (_miUbicacion == null ||
        GeolocatorPlatform.instance.distanceBetween(_miViaje.lat_chofer,
                _miViaje.lon_chofer, _pos.latitude, _pos.longitude) >
            15 ||
        _cambio_estado_2_nueva_pos(_pos)) {
      if (_icono_auto == null) {
        _icono_auto = await maps.BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: s, devicePixelRatio: 0.5),
            "assets/logos/iconoRide.png");
      }
      bool _actualizado = false;
      _miUbicacion = null;
      _miUbicacion = maps.Marker(
          markerId: const maps.MarkerId("mi_posicion"),
          infoWindow: const maps.InfoWindow(title: "YO"),
          icon: _icono_auto,
          position: maps.LatLng(_pos.latitude, _pos.longitude),
          onTap: () async {
            _vista_alta = !_vista_alta;
            await _centrar_viaje();
            var _posi = await _f.obtener_ubicacion(context);
            await _actualizar_mi_marcador(_posi);
            setState(() {});
          });

      //actualiza la variable local que mantiene la posicion
      widget._pos = _pos;

      //actualiza las cordenadas del viaje actual
      _miViaje.lat_chofer = _pos.latitude;
      _miViaje.lon_chofer = _pos.longitude;

      //variable de control para llevar las actualizaciones del mapa

      //revisa si aun hay viajes donde el usuario esta esperando al conductor, si los hay, revisa si esta ya muy
      //cerca de alguno para cambiar su estado, lo que avisara al usuario que el chofer llego a la vez que al chofer
      //le activa el boton de iniciar el viaje en el que esta cerca.
      if (_cambio_estado_2() ||
          _miViaje.estado_viaje1 == 1 ||
          _miViaje.estado_viaje2 == 1 ||
          _miViaje.estado_viaje3 == 1) {
        _actualizado = true;
        await _actualizar_ubicacion_en_firestore();
        await _centrar_viaje();
        setState(() {});
      }
      if (!_actualizado) {
        await _centrar_viaje();
        setState(() {});
      }
    }
  }

  num _absoluto(num _n) {
    if (_n < 0) return (_n * -1);
    return _n;
  }

  bool _cambio_estado_2_nueva_pos(Position _pos) {
    bool _cambio = false;

    //revisamos uno a uno los viajes en curso paraa ver si estamos en camino al viajero y ya llegamos
    //al lugar de origen para avisar al chofer que diga cuando el viaje iniciará
    if (_miViaje.uid_v1 != null &&
        _miViaje.uid_v1 != "" &&
        _miViaje.estado_viaje1 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(_pos.latitude,
                _pos.longitude, _miViaje.lat_origen1, _miViaje.lon_origen1)) <
            80) {
      _cambio = true;
    }

    if (_miViaje.uid_v2 != null &&
        _miViaje.uid_v2 != "" &&
        _miViaje.estado_viaje2 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(_pos.latitude,
                _pos.longitude, _miViaje.lat_origen2, _miViaje.lon_origen2)) <
            80) {
      _cambio = true;
    }

    if (_miViaje.uid_v3 != null &&
        _miViaje.uid_v3 != "" &&
        _miViaje.estado_viaje3 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(_pos.latitude,
                _pos.longitude, _miViaje.lat_origen3, _miViaje.lon_origen3)) <
            80) {
      _cambio = true;
    }

    print("cambio _cambio_estado_2_nueva_pos $_cambio");

    return _cambio;
  }

  bool _cambio_estado_2() {
    bool _cambio = false;

    //revisamos uno a uno los viajes en curso paraa ver si estamos en camino al viajero y ya llegamos
    //al lugar de origen para avisar al chofer que diga cuando el viaje iniciará
    if (_miViaje.uid_v1 != null &&
        _miViaje.uid_v1 != "" &&
        _miViaje.estado_viaje1 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(
                _miViaje.lat_chofer,
                _miViaje.lon_chofer,
                _miViaje.lat_origen1,
                _miViaje.lon_origen1)) <
            80) {
      _miViaje.estado_viaje1 = 2;
      _cambio = true;
    }

    if (_miViaje.uid_v2 != null &&
        _miViaje.uid_v2 != "" &&
        _miViaje.estado_viaje2 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(
                _miViaje.lat_chofer,
                _miViaje.lon_chofer,
                _miViaje.lat_origen2,
                _miViaje.lon_origen2)) <
            80) {
      _miViaje.estado_viaje2 = 2;
      _cambio = true;
    }

    if (_miViaje.uid_v3 != null &&
        _miViaje.uid_v3 != "" &&
        _miViaje.estado_viaje3 == 1 &&
        _absoluto(GeolocatorPlatform.instance.distanceBetween(
                _miViaje.lat_chofer,
                _miViaje.lon_chofer,
                _miViaje.lat_origen3,
                _miViaje.lon_origen3)) <
            80) {
      _miViaje.estado_viaje3 = 2;
      _cambio = true;
    }
    return _cambio;
  }

  Widget _aviso_inicio_de_viaje() {
    if (_miViaje.estado_viaje1 != 2 &&
        _miViaje.estado_viaje2 != 2 &&
        _miViaje.estado_viaje3 != 2) return _f.invisible();

    List<Widget> _llegadas = [];

    if (_miViaje.estado_viaje1 == 2) {
      var _c = Container(
        width: s.width,
        margin: EdgeInsets.fromLTRB(
            s.width * .05, s.height * .035, s.width * .05, s.height * .035),
        child: ElevatedButton(
          style: _style,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "${_miViaje.nombre_v1.toUpperCase()} ESTÁ ABORDO",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () async {
            if (!await ConnectionVerify.connectionStatus()) {
              await _f.dialogo_sin_internet(context);
              return;
            }
            _miViaje.estado_viaje1 = 3;
            _miViaje.lat_origen1 = widget._pos.latitude;
            _miViaje.lon_origen1 = widget._pos.longitude;
            _miViaje.fecha1 =
                DateTime.now().subtract(Duration(microseconds: 1)).toString();

            await _actualizar_marcadores();
            await BD.bd.actulizar_viaje(_miViaje, _misDatos, context);
            await _centrar_viaje();
            setState(() {});
          },
        ),
      );
      _llegadas.add(_c);
    }

    if (_miViaje.estado_viaje2 == 2) {
      var _d = Container(
        width: s.width,
        margin: EdgeInsets.fromLTRB(
            s.width * .05, s.height * .035, s.width * .05, s.height * .035),
        child: ElevatedButton(
          style: _style,
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                " pulse cuando ${_miViaje.nombre_v2} este a bordo",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                textAlign: TextAlign.center,
              )),
          onPressed: () async {
            if (!await ConnectionVerify.connectionStatus()) {
              await _f.dialogo_sin_internet(context);
              return;
            }
            _miViaje.estado_viaje2 = 3;
            _miViaje.lat_origen2 = widget._pos.latitude;
            _miViaje.lon_origen2 = widget._pos.longitude;
            _miViaje.fecha2 =
                DateTime.now().subtract(Duration(microseconds: 1)).toString();

            await _actualizar_marcadores();

            await BD.bd.actulizar_viaje(_miViaje, _misDatos, context);
            await _centrar_viaje();
            setState(() {});
          },
        ),
      );
      _llegadas.add(_d);
    }

    if (_miViaje.estado_viaje3 == 2) {
      var _c = Container(
        width: s.width,
        margin: EdgeInsets.fromLTRB(
            s.width * .05, s.height * .035, s.width * .05, s.height * .035),
        child: ElevatedButton(
          style: _style,
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                " pulse cuando ${_miViaje.nombre_v3} este a bordo",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                textAlign: TextAlign.center,
              )),
          onPressed: () async {
            _miViaje.estado_viaje3 = 3;
            _miViaje.lat_origen3 = widget._pos.latitude;
            _miViaje.lon_origen3 = widget._pos.longitude;
            _miViaje.fecha3 =
                DateTime.now().subtract(Duration(microseconds: 1)).toString();
            if (!await ConnectionVerify.connectionStatus()) {
              await _f.dialogo_sin_internet(context);
              return;
            }
            await _actualizar_marcadores();

            await BD.bd.actulizar_viaje(_miViaje, _misDatos, context);
            await _centrar_viaje();
            setState(() {});
          },
        ),
      );
      _llegadas.add(_c);
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_llegadas.length, (ind) => _llegadas[ind]));
  }

  Future<void> _actualizar_viajero1_origen() async {
    if (_icono_viaje1 == null) {
      _icono_viaje1 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo1.png");
    }
    _destino1 = maps.Marker(
        markerId: const maps.MarkerId("proximo viaje"),
        infoWindow: const maps.InfoWindow(title: "VIAJERO 1"),
        icon: _icono_viaje1,
        position: maps.LatLng(_miViaje.lat_origen1, _miViaje.lon_origen1),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_origen1}", context));
  }

  Future<void> _actualizar_viajero1_destino() async {
    if (_icono_destino1 == null) {
      _icono_destino1 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino1.png");
    }
    _destino1 = maps.Marker(
        markerId: const maps.MarkerId("proximo destino"),
        infoWindow: const maps.InfoWindow(title: "DESTINO 1"),
        icon: _icono_destino1,
        position: maps.LatLng(_miViaje.lat_destino1, _miViaje.lon_destino1),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_destino1}", context));
  }

  Future<void> _actualizar_viajero2_origen() async {
    if (_icono_viaje2 == null) {
      _icono_viaje2 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo2.png");
    }
    _destino2 = maps.Marker(
        markerId: const maps.MarkerId("segundo viaje"),
        infoWindow: const maps.InfoWindow(title: "VIAJERO 2"),
        icon: _icono_viaje2,
        position: maps.LatLng(_miViaje.lat_origen2, _miViaje.lon_origen2),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_origen2}", context));
  }

  Future<void> _actualizar_viajero2_destino() async {
    if (_icono_destino2 == null) {
      _icono_destino2 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino2.png");
    }
    _destino2 = maps.Marker(
        markerId: const maps.MarkerId("segundo destino"),
        infoWindow: const maps.InfoWindow(title: "DESTINO 2"),
        icon: _icono_destino2,
        position: maps.LatLng(_miViaje.lat_destino2, _miViaje.lon_destino2),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_destino2}", context));
  }

  Future<void> _actualizar_viajero3_origen() async {
    if (_icono_viaje3 == null) {
      _icono_viaje3 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/yo3.png");
    }

    _destino3 = maps.Marker(
        markerId: const maps.MarkerId("último viaje"),
        infoWindow: const maps.InfoWindow(title: "VIAJERO 3"),
        icon: _icono_viaje3,
        position: maps.LatLng(_miViaje.lat_origen3, _miViaje.lon_origen3),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_origen3}", context));
  }

  Future<void> _actualizar_viajero3_destino() async {
    if (_icono_destino3 == null) {
      _icono_destino3 = await maps.BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: s, devicePixelRatio: 0.5),
          "assets/logos/destino3.png");
    }

    _destino3 = maps.Marker(
        markerId: const maps.MarkerId("último destino"),
        infoWindow: const maps.InfoWindow(title: "viajero 3"),
        icon: _icono_destino3,
        position: maps.LatLng(_miViaje.lat_destino3, _miViaje.lon_destino3),
        onTap: () async => await _f.dialogo(
            "DIRECCIÓN DE DESTINO", "${_miViaje.dir_destino3}", context));
  }

  Future<bool> _actualizar_ubicacion_en_firestore() async {
    if (_miViaje.estado_viaje1 > 2 &&
        _miViaje.estado_viaje2 > 2 &&
        _miViaje.estado_viaje3 > 2 &&
        _miViaje.estado_viaje1 < 1 &&
        _miViaje.estado_viaje2 < 1 &&
        _miViaje.estado_viaje3 < 1) return false;

    if (!await ConnectionVerify.connectionStatus()) {
      _f.dialogo_sin_internet(context);
      return false;
    }
    await BD.bd.actulizar_viaje(_miViaje, _misDatos, context);
    return true;
  }

  /*void _escuchar_Solicitudes() async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("viajes_en_curso");
    _streamSub = reference.snapshots().listen((_event) {
      if (_event.docs.isNotEmpty) {
        _solicitudes = [];
        _event.docs.forEach((_viaje) {
          Reg_solicitud_viaje _v = Reg_solicitud_viaje.fromJson(_viaje.data());
          _v.id = _viaje.id;
          _solicitudes.add(_v);
        });
        _streamSub.cancel();
        setState(() {});
      }
    });
  }*/

  Widget _mensje_viajes(int index) {
    return Container(
      width: s.width,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          s.width * .025, s.height * .015, s.width * .025, s.height * .015),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        // ignore: prefer_const_literals_to_create_immutables
        boxShadow: [
          BoxShadow(
              color: Colors.black38,
              spreadRadius: 3,
              blurRadius: 9,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _solicitudes[index].num_pasajeros == 3
                    ? "VIAJE"
                    : "VIAJE COMPARTIDO",
                style: TextStyle(
                    color: Colors.green[900],
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  _f.dialogoImagen(_solicitudes[index].foto, context, s);
                },
                child: Container(
                  width: s.width * .1,
                  height: s.width * .1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(s.width * .025),
                      color: Colors.white,
                      image: DecorationImage(
                          image: NetworkImage(_solicitudes[index].foto),
                          fit: BoxFit.cover)),
                ),
              )
            ],
          ),
          Divider(
            endIndent: s.width * .15,
            indent: s.width * .15,
            color: Colors.green[900],
          ),
          /*Text.rich(TextSpan(
            text: "COSTO:",
            children: [
              TextSpan(
                text: "\$${_solicitudes[index].costo_viaje}.",
                style: TextStyle(
                    color: Colors.green[900],
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
            ],
            style: TextStyle(
                color: Colors.green[900],
                fontWeight: FontWeight.w400,
                fontSize: 16),
          )),*/
          if (_solicitudes[index].num_pasajeros != 3)
            Text.rich(TextSpan(
              children: [
                TextSpan(
                  text: "PASAJEROS: ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 17),
                ),
                TextSpan(
                  text: "${_solicitudes[index].num_pasajeros}\n",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 17),
                ),
              ],
            )),
          Text.rich(TextSpan(
            text: "ORIGEN: ",
            children: [
              TextSpan(
                text: "${_solicitudes[index].direccion_origen}\n",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
            ],
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
          )),
          Text.rich(TextSpan(
            text: "DESTINO: ",
            children: [
              TextSpan(
                text: "${_solicitudes[index].direccion_destino}\n",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
            ],
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16),
          )),
          Divider(
            endIndent: s.width * .15,
            indent: s.width * .15,
            color: Colors.green[900],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: s.width * .3,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.yellow[900];
                            }
                            return Colors.white; // Use the component's default.
                          },
                        ),
                      ),
                      child: Text(
                        "DESCARTAR",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () async {
                        await _f.dialogo(
                            "", "MANTENGA OPRIMIDO PARA DESCARTAR", context);
                        // _solicitudes.removeAt(index);
                        // await _listener_de_solicitudes();

                        setState(() {});
                      })),
              SizedBox(
                width: s.width * .4,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.yellow[900];
                          } else {
                            return Colors.green[900];
                          }
                          // Use the component's default.
                        },
                      ),
                    ),
                    child: Text(
                      "ACEPTAR VIAJE",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      //creamos un viaje actualizado antes de actualizar el original
                      Reg_viaje _viaje_actualizado = _f.clonar_viaje(_miViaje);
                      _viaje_actualizado = _f.agregar_un_viajero(
                          _solicitudes[index], _viaje_actualizado);

                      //gurdamosuna copia de la solicitud para el paso posterior
                      Reg_solicitud_viaje _solicitud = _solicitudes[index];

                      //intentamos responder a la solicitud usando el viaje actualizzado
                      if (!await BD.bd.agregar_solicitud_a_viaje(
                          _solicitudes[index],
                          _viaje_actualizado,
                          _misDatos,
                          _path1,
                          context)) {
                        return;
                      }

                      //si todo salio bien ahora si actualizamos el viaje original con los datos
                      _miViaje = _viaje_actualizado;

                      //eliminamos la solicitud agregada si aun no se elimina automaticamente con el listener
                      if (_solicitudes.any((element) =>
                          element.uid_viajero == _solicitud.uid_viajero)) {
                        _solicitudes.removeWhere((element) =>
                            element.uid_viajero == _solicitud.uid_viajero);
                      }
                      //revisamos si ya no hay asientos libres para detener el streamer de solicitudes y no consumir conexiones
                      if (_revisar_asientos_libres() == 0) {
                        _listener_solicitudes.pause();
                      }
                      _Crear_listener_de_viaje();

                      //Actualizamos los marcadores y la camara, depues refrescamos la pantalla

                      await _actualizar_marcadores();
                      _actualizar_mi_marcador(widget._pos);
                      await _centrar_viaje();
                      setState(() {});
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _actualizar_marcadores() async {
    //borramos todos los marcadores de viaje
    _destino1 = null;
    _destino2 = null;
    _destino3 = null;

    //ahora revisamos el primer viaje para ver si hay viajes pendientes
    if (_miViaje.uid_v1 != null && _miViaje.uid_v1 != "") {
      //si el conductor aun no llega por el viajero hacemos que el marcador sea el de origen, destino o dejarllo en nulo
      if (_miViaje.estado_viaje1 == 1 || _miViaje.estado_viaje1 == 2) {
        await _actualizar_viajero1_origen();
      } else if (_miViaje.estado_viaje1 == 3) {
        await _actualizar_viajero1_destino();
      }
    }

    //hacemos lo mismo con el viaje 2
    if (_miViaje.uid_v2 != null && _miViaje.uid_v2 != "") {
      if (_miViaje.estado_viaje2 == 1 || _miViaje.estado_viaje2 == 2) {
        await _actualizar_viajero2_origen();
      } else if (_miViaje.estado_viaje2 == 3) {
        await _actualizar_viajero2_destino();
      }
    }

    //por ultimo repetimos con el viajero 3
    if (_miViaje.uid_v3 != null && _miViaje.uid_v3 != "") {
      if (_miViaje.estado_viaje3 == 1 || _miViaje.estado_viaje3 == 2) {
        await _actualizar_viajero3_origen();
      } else if (_miViaje.estado_viaje3 == 3) {
        await _actualizar_viajero3_destino();
      }
    }

    return;
  }

  Future<void> permisos_ubicacion(BuildContext context) async {
    ///Esta funcion revisa si hay permisos para solicitar la ubicacion de usuario y si el
    ///gps esta apagado o prendido. En caso de estar apagado devuelve una posicion de valor imposible
    /// y la retorna.
    /// si no hay permisos para obtener la ubicacion, entonces intenta obtenerlos, si son denegados retorna la
    /// posicion imposible.
    /// Si los permisos estas activos entonces retorna la ubicacion actual
    final _geo = GeolocatorPlatform.instance;
    DateTime _falsa = DateTime.now();

    if (!await _geo.isLocationServiceEnabled()) {
      return;
    }

    var _permisos = await _geo.checkPermission();
    if (_permisos == LocationPermission.denied) {
      _permisos = await Geolocator.requestPermission();
      if (_permisos == LocationPermission.denied) {
        return;
      }
    }

    if (_permisos == LocationPermission.deniedForever) {
      await _geo.openAppSettings();
      return;
    }

    return;
  }

  void _escuchar_posicion() async {
    //nos aseguramoe de tner los permisos

    while (!_permisos_gps_habilitaados) {
      var _respuesta = await GeolocatorPlatform.instance.requestPermission();
      if (_respuesta == LocationPermission.whileInUse ||
          _respuesta == LocationPermission.always) {
        _permisos_gps_habilitaados = true;
      }
    }

    if (_listenerGPS != null && !_listenerGPS.isPaused) {
      return;
    }

    if (_listenerGPS != null && _listenerGPS.isPaused) {
      _listenerGPS.resume();
      return;
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _listenerGPS =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (_evento) async {
      if (_evento != null) {
        widget._pos = _evento;
        await _centrar_viaje();
        await _actualizar_mi_marcador(_evento);
        _permisos_gps_habilitaados = true;
      } else {
        _permisos_gps_habilitaados = false;
      }
      setState(() {});
    }, onError: (e) async {
      print("Hubo un error con el GPS $e");
    }, onDone: () async {
      print("El GPS terminó correctamente");
    });
  }

  Future<void> _trazar_ruta() async {
    ///1esta funcion vuelve a clacular el pilyline de acuerdo a los
    ///paramétros del viaje
    _ruta.clear();
    if (_destino1 == null && _destino2 == null && _destino3 == null) return;
    List<maps.LatLng> _puntos = [];

    _puntos.add(_miUbicacion.position);
    if (_destino1 != null && _destino2 == null && _destino3 == null) {
      _puntos.add(_destino1.position);
    } else if (_destino1 != null && _destino2 != null && _destino3 == null) {
      double _p1, _p2;
      _p1 = GeolocatorPlatform.instance.distanceBetween(
          _destino1.position.latitude,
          _destino1.position.longitude,
          _miUbicacion.position.latitude,
          _miUbicacion.position.longitude);
      _p2 = GeolocatorPlatform.instance.distanceBetween(
          _destino2.position.latitude,
          _destino2.position.longitude,
          _miUbicacion.position.latitude,
          _miUbicacion.position.longitude);

      if (_p1 > _p2) {
        _puntos.add(_destino2.position);
        _puntos.add(_destino1.position);
      } else {
        _puntos.add(_destino1.position);
        _puntos.add(_destino2.position);
      }
    } else if (_destino1 != null && _destino2 != null && _destino3 != null) {
      double _p1, _p2, _p3;
      _p1 = GeolocatorPlatform.instance.distanceBetween(
          _destino1.position.latitude,
          _destino1.position.longitude,
          _miUbicacion.position.latitude,
          _miUbicacion.position.longitude);
      _p2 = GeolocatorPlatform.instance.distanceBetween(
          _destino2.position.latitude,
          _destino2.position.longitude,
          _miUbicacion.position.latitude,
          _miUbicacion.position.longitude);
      _p3 = GeolocatorPlatform.instance.distanceBetween(
          _destino3.position.latitude,
          _destino3.position.longitude,
          _miUbicacion.position.latitude,
          _miUbicacion.position.longitude);

      if (_p1 <= _p2 && _p2 <= _p3) {
        _puntos.add(_destino1.position);
        _puntos.add(_destino2.position);
        _puntos.add(_destino3.position);
      } else if (_p1 <= _p3 && _p3 < _p2) {
        _puntos.add(_destino1.position);
        _puntos.add(_destino3.position);
        _puntos.add(_destino2.position);
      } else if (_p2 <= _p1 && _p1 < _p3) {
        _puntos.add(_destino2.position);
        _puntos.add(_destino1.position);
        _puntos.add(_destino3.position);
      } else if (_p2 <= _p3 && _p3 < _p1) {
        _puntos.add(_destino2.position);
        _puntos.add(_destino3.position);
        _puntos.add(_destino1.position);
      } else if (_p3 <= _p1 && _p1 < _p2) {
        _puntos.add(_destino3.position);
        _puntos.add(_destino1.position);
        _puntos.add(_destino2.position);
      } else {
        _puntos.add(_destino3.position);
        _puntos.add(_destino2.position);
        _puntos.add(_destino1.position);
      }
    }
    _ruta.add(maps.Polyline(
      polylineId: const maps.PolylineId("VIAJE*"),
      points: _puntos,
      color: Colors.green[900],
      width: 3,
    ));
  }

  Future<void> _centrar_viaje() async {
    if (_destino1 == null && _destino2 == null && _destino3 == null) {
      ///si no hay viajeros en el auto o solicitando viaje, se centra la cámara en la
      ///posicion de condductor
      await _trazar_ruta();
      await _posicion_camara(17);
      return;
    }

    ///el siguiente bloque solo se ejecuta si hay una solicitud aceptada o viaje activo
    ///Trazamos la ruta sugerida par ael conductor
    await _trazar_ruta();

    //Creamos 4 delimitantes que marcan la zona donde rehubicaremos la camara

    //con esos datos creamos un objetos LatLngBounds para pasarlo al controlador de la camara

    //Si el conductor activó la vista centrada en su auto
    if (_vista_alta) {
      await _posicion_camara(17);
      return;
    } else {
      ///si esta activa la vista que abaraca todos los ciajeros
      num _izquierda = _izquierda_f();
      if (_izquierda == null) return;
      num _derecha = _derecha_f();
      if (_derecha == null) return;
      num _arriba = _arriba_f();
      if (_arriba == null) return;
      num _debajo = _abajo_f();
      if (_debajo == null) return;
      maps.LatLngBounds _bounds = maps.LatLngBounds(
          northeast: maps.LatLng(_derecha, _arriba),
          southwest: maps.LatLng(_izquierda, _debajo));
      double _distancia;
      if (_miViaje.estado_viaje1 == 0 &&
          _miViaje.estado_viaje2 == 0 &&
          _miViaje.estado_viaje3 == 0) {
        _distancia = 130;
      } else {
        _distancia = 70;
      }
      try {
        await _controlador.animateCamera(
            maps.CameraUpdate.newLatLngBounds(_bounds, _distancia));
      } catch (e) {
        await _f.dialogo("", "$e", context);
      }

      return;
    }
  }

  num _izquierda_f() {
    ///esta funcion devuelve el valor mas pequeño del cuadrante izquierdo de todas las latitudes de los marcadores diponibles
    List<num> _latitudes = [];
    if (_miUbicacion != null) {
      _latitudes.add(_miUbicacion.position.latitude);
    }
    if (_destino1 != null) {
      _latitudes.add(_destino1.position.latitude);
    }
    if (_destino2 != null) {
      _latitudes.add(_destino2.position.latitude);
    }
    if (_destino3 != null) {
      _latitudes.add(_destino3.position.latitude);
    }

    if (_latitudes.isEmpty) return null;
    if (_latitudes.length == 1) return _latitudes.first;

    num _minimo = _latitudes.first;

    for (var i = 1; i < _latitudes.length; i++) {
      if (_latitudes[i] < _minimo) _minimo = _latitudes[i];
    }

    return _minimo;
  }

  num _derecha_f() {
    ///esta funcion devuelve el valor mas grande del cuadrante derecho de todas las latitudes de los marcadores diponibles
    List<num> _latitudes = [];
    if (_miUbicacion != null) {
      _latitudes.add(_miUbicacion.position.latitude);
    }
    if (_destino1 != null) {
      _latitudes.add(_destino1.position.latitude);
    }
    if (_destino2 != null) {
      _latitudes.add(_destino2.position.latitude);
    }
    if (_destino3 != null) {
      _latitudes.add(_destino3.position.latitude);
    }

    if (_latitudes.isEmpty) return null;
    if (_latitudes.length == 1) return _latitudes.first;

    num _maximo = _latitudes.first;

    for (var i = 1; i < _latitudes.length; i++) {
      if (_latitudes[i] > _maximo) _maximo = _latitudes[i];
    }

    return _maximo;
  }

  num _arriba_f() {
    ///esta funcion devuelve el valor mas grande del cuadrante alto de todas las longitudes de los marcadores diponibles
    List<num> _longitudes = [];
    if (_miUbicacion != null) {
      _longitudes.add(_miUbicacion.position.longitude);
    }
    if (_destino1 != null) {
      _longitudes.add(_destino1.position.longitude);
    }
    if (_destino2 != null) {
      _longitudes.add(_destino2.position.longitude);
    }
    if (_destino3 != null) {
      _longitudes.add(_destino3.position.longitude);
    }

    if (_longitudes.isEmpty) return null;
    if (_longitudes.length == 1) return _longitudes.first;

    num _maximo = _longitudes.first;

    for (var i = 1; i < _longitudes.length; i++) {
      if (_longitudes[i] > _maximo) _maximo = _longitudes[i];
    }

    return _maximo;
  }

  num _abajo_f() {
    ///esta funcion devuelve el valor mas pequeño del cuadrante bajo de todas las longitudes de los marcadores diponibles
    List<num> _longitudes = [];
    if (_miUbicacion != null) {
      _longitudes.add(_miUbicacion.position.longitude);
    }
    if (_destino1 != null) {
      _longitudes.add(_destino1.position.longitude);
    }
    if (_destino2 != null) {
      _longitudes.add(_destino2.position.longitude);
    }
    if (_destino3 != null) {
      _longitudes.add(_destino3.position.longitude);
    }

    if (_longitudes.isEmpty) return null;
    if (_longitudes.length == 1) return _longitudes.first;

    num _minimo = _longitudes.first;

    for (var i = 1; i < _longitudes.length; i++) {
      if (_longitudes[i] < _minimo) _minimo = _longitudes[i];
    }

    return _minimo;
  }

  Future<void> _crear_listener_de_solicitudes() {
    ///Antes de invocar esta funcion es muy importante que el listener de solicitudes sea nulo
    ///primero hacermos el el path actual y el anterior sean el mismo, no hay que igualar una a otra o haran
    ///referencia a la misma variable, hay que asignarles yn valor desde instancias diferentes
    _path1 = Ciudades(4000).carpeta(widget._pos);
    _path2 = Ciudades(4000).carpeta(widget._pos);

    ///La variable asientos_libres1 se actualiza dentro de la función, asi que solo asignamos el valor retornado
    _asientos_libres2 = _revisar_asientos_libres();

    ///instanciamos el linestener de solicitudes
    _listener_solicitudes = FirebaseFirestore.instance
        .collection(_path1)
        .snapshots()
        .listen((_event) {
      print("se detecto un evento ${_event.docs.length}");

      ///cada que hay un cambio limpiamos la lista de solicitudes
      _solicitudes.clear();

      ///Revisamos todos los documentos de la instantanea
      if (_event.docs.isNotEmpty) {
        ///Si una solicitud no tiene el uid del chofer, significa que no ha sido aceptada
        ///también debemos verificar que las solicitudes que mostremos coincidan con los
        ///asientos libres diponibles actuales
        _event.docs.forEach((element) {
          if (element.data()["uid_chofer"] == null &&
              element.data()["num_pasajeros"] <= (_asientos_libres1)) {
            ///si todas las condiciones se cumplen agregamos la solicitud a la lista
            Reg_solicitud_viaje _v =
                Reg_solicitud_viaje.fromJson(element.data());
            _v.id = element.id;
            _solicitudes.add(_v);
          }
        });
      }

      ///refrescamos la pantalla
      setState(() {});
    });
  }

  Future<void> _escuchar_solicitudes() async {
    ///verificar si se esta dentro de una zona con servicio
    if (_path1 == "") {
      if (_listener_solicitudes != null) {
        await _listener_solicitudes.cancel();
        _listener_solicitudes = null;
      }
      return;
    }

    ///verificar si hay asientos libres
    if (_asientos_libres1 == 0) {
      if (_listener_solicitudes != null) {
        await _listener_solicitudes.cancel();
        _listener_solicitudes = null;
      }
      return;
    }

    ///verificar si el path actual es iguaal al anterior
    if (_path1 == _path2) {
      ///si es el mismo, ahora verificar que los asientos diisponibles son iguales
      ///que en el ultimo refresco de pantalla, tambien se verifica que el listener este
      ///activo
      if (_asientos_libres1 == _asientos_libres2 &&
          _listener_solicitudes != null) {
        return;
      }
    }

    if (_listener_solicitudes != null) {
      await _listener_solicitudes.cancel();
      _listener_solicitudes = null;
    }

    _crear_listener_de_solicitudes();
    return;
  }

  int _revisar_asientos_libres() {
    ///Revisa las solicitudes aceptadas y revisa la cantidad de pasajeros de cada una, devuelve la cantidad de asientos libres
    ///
    int _viajando = 0;
    if (_miViaje.uid_v1 != null && _miViaje.uid_v1 != "") {
      _viajando += _miViaje.pasajeros1;
    }
    if (_miViaje.uid_v2 != null && _miViaje.uid_v2 != "") {
      _viajando += _miViaje.pasajeros2;
    }
    if (_miViaje.uid_v3 != null && _miViaje.uid_v3 != "") {
      _viajando += _miViaje.pasajeros3;
    }

    if (_viajando >= 3) {
      _asientos_libres1 = 0;
      return 0;
    }

    _asientos_libres1 = 3 - _viajando;
    return (3 - _viajando);
  }

  Future<void> _Crear_listener_de_viaje() async {
    if (_listener_viaje != null && !_listener_viaje.isPaused) {
      return;
    } else if (_listener_viaje != null && _listener_viaje.isPaused) {
      _listener_viaje.resume();
      return;
    }

    if (!await ConnectionVerify.connectionStatus()) {
      await _listener_viaje.cancel();
      _listener_viaje = null;
      return;
    }

    _listener_viaje = FirebaseFirestore.instance
        .collection("viajes")
        .doc(_miViaje.uid_chofer)
        .snapshots()
        .listen((event) async {
      Reg_viaje _snap = Reg_viaje.fromJson(event.data());

      if (_snap.estado_viaje1 == 4) {
        await _viaje_cancelado_cliente(1);
      }

      if (_snap.estado_viaje2 == 4) {
        await _viaje_cancelado_cliente(2);
      }

      if (_snap.estado_viaje3 == 4) {
        await _viaje_cancelado_cliente(3);
      }

      if (!_hay_colicitudes_aceptadas()) {
        _listener_viaje.pause;
      }
    });
  }

  Future<void> _viaje_cancelado_cliente(int _num) async {
    String _nombreViajero = "";
    if (_num == 1) {
      _nombreViajero = _miViaje.nombre_v1;
      if (_f.compararFechaConHoy_minutos(_miViaje.fecha1) > 6) {
        if (!await BD.bd.agregar_cargo_a_viajero(
            _miViaje.uid_v1, widget._tarifas.penalizacion, 0)) {
          await _f.dialogo(
              "Error", "al agregar un cargo al viajero 1", context);
          return;
        }
      } else {
        if (!await BD.bd.agregar_cargo_a_viajero(_miViaje.uid_v1, 0, 0)) {
          await _f.dialogo("Error", "al cancelar el viaje 1", context);
          return;
        }
      }
      var _v = _f.eliminar_un_viajero(1, _miViaje);
      if (_v != null) _miViaje = _v;
    } else if (_num == 2) {
      _nombreViajero = _miViaje.nombre_v2;
      if (_f.compararFechaConHoy_minutos(_miViaje.fecha2) > 6) {
        if (!await BD.bd.agregar_cargo_a_viajero(
            _miViaje.uid_v2, widget._tarifas.penalizacion, 0)) {
          await _f.dialogo(
              "Error", "al agregar un cargo al viajero 2", context);
          return;
        }
      } else {
        if (!await BD.bd.agregar_cargo_a_viajero(_miViaje.uid_v2, 0, 0)) {
          await _f.dialogo("Error", "al cancelar el viaje 2", context);
          return;
        }
      }
      var _v = _f.eliminar_un_viajero(2, _miViaje);
      if (_v != null) _miViaje = _v;
    }
    if (_num == 3) {
      _nombreViajero = _miViaje.nombre_v3;
      if (_f.compararFechaConHoy_minutos(_miViaje.fecha3) > 6) {
        if (!await BD.bd.agregar_cargo_a_viajero(
            _miViaje.uid_v3, widget._tarifas.penalizacion, 0)) {
          await _f.dialogo(
              "Error", "al agregar un cargo al viajero 3", context);
          return;
        }
      } else {
        if (!await BD.bd.agregar_cargo_a_viajero(_miViaje.uid_v3, 0, 0)) {
          await _f.dialogo("Error", "al cancelar el viaje 3", context);
          return;
        }
      }
      var _v = _f.eliminar_un_viajero(3, _miViaje);
      if (_v != null) _miViaje = _v;
    }

    if (!await BD.bd.actulizar_viaje(_miViaje, _misDatos, context)) {
      await _f.dialogo("error", "al actualizar un vaije cancelado", context);
    }

    await _f.dialogo(
        "VIAJE CANCELADO",
        "La solicitud $_num  de viaje, a nombre de $_nombreViajero fue cancelada por el usuario.",
        context);

    await _actualizar_marcadores();
    await _crear_listener_de_solicitudes();
    await _centrar_viaje();
    try {
      setState(() {});
    } catch (e) {
      print(
          "ERROR AL REFRESCAR LA PANTALLA TRAS ELIMINAR UN VIAJERO Y ACTUALIZAR SU MARCADOR");
    }

    return;
  }

  bool _hay_colicitudes_aceptadas() {
    if (_miViaje.estado_viaje1 == 1 ||
        _miViaje.estado_viaje1 == 2 ||
        _miViaje.estado_viaje2 == 1 ||
        _miViaje.estado_viaje2 == 2 ||
        _miViaje.estado_viaje3 == 1 ||
        _miViaje.estado_viaje3 == 2) return true;
    return false;
  }

  Widget _pantalla_sin_ubicacion() {
    if (_pantalla == 1) {
      return _f.invisible();
    } else {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.only(left: s.width * .1, right: s.width * .1),
          width: s.width,
          height: s.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.grey[50],
                Colors.grey[100],
                Colors.grey[200],
                Colors.grey[300],
                Colors.grey[400],
                Colors.grey[500],
                Colors.grey[600],
                Colors.grey[700],
                Colors.grey[800],
                Colors.grey[900],
                Colors.black
              ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(text: "No hay conexión a internet.\n\n\n", children: [
                  TextSpan(
                    text: "Para continuar es necesario estar conectado.",
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w300,
                        fontSize: 30),
                  ),
                ]),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: s.height * .05,
              ),
              Image.asset(
                "assets/logos/nowifi.png",
                fit: BoxFit.fitWidth,
              )
            ],
          ),
        ),
      );
    }
  }

  Widget _avisoFueraDeZona() {
    if (_path1 != "" || widget._pos == null) {
      return _f.invisible();
    }

    return SizedBox(
      width: s.width,
      height: s.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: s.width,
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white70,
                      Colors.white60,
                      Colors.white54,
                      Colors.white38,
                      Colors.white30,
                      Colors.white24,
                      Colors.white12,
                      Colors.white10,
                    ])),
            padding: EdgeInsets.fromLTRB(
                s.width * .05, s.height * .025, s.width * .05, s.height * .1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "USTED ESTA FUERA DE LA ZONA DE COVERTURA DE SERVICIO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 168, 13, 2),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "En esta zona no recibirá solicitudes de socios viajeros",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(child: _f.invisible()),
        ],
      ),
    );
  }

  Widget _avisoGPSApagado() {
    if (!_gps_habilitado) {
      return _f.invisible();
    }

    return SizedBox(
      width: s.width,
      height: s.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: s.width,
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white70,
                      Colors.white60,
                      Colors.white54,
                      Colors.white38,
                      Colors.white30,
                      Colors.white24,
                      Colors.white12,
                      Colors.white10,
                    ])),
            padding: EdgeInsets.fromLTRB(
                s.width * .05, s.height * .025, s.width * .05, s.height * .1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "SIN SERVICIO DE UBICACIÓN",
                  style: TextStyle(
                      color: Color.fromARGB(255, 168, 13, 2),
                      fontWeight: FontWeight.w600,
                      fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Su GPS esta apagado o no contamos con los permisos para obtener su ubicación ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  "assets/logos/globo.gif",
                  width: s.width * .35,
                )
              ],
            ),
          ),
          Expanded(child: _f.invisible()),
        ],
      ),
    );
  }
}

class Resultados_viaje {
  Resultados_viaje(
      this._precio, this.ditancia, this.nombre, this.uid, this.turno);

  num _precio, ditancia;
  String nombre, uid;
  int turno;
}
