// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Info_Viaje_cliente.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_solicitud_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_viaje.dart';

class Funciones {
  Funciones();

  Future<void> dialogoWidget(Widget _contenido, BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        scrollable: true,
        content: _contenido,
        actions: [
          ElevatedButton(
            child: const Text('REGRESAR'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.yellow[900];
                } else {
                  return Colors.black;
                }
              }),
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          )
        ],
      ),
    );
  }

  Future<bool> dialogoConRespuesta(
      String titulo, String contenido, BuildContext context) async {
    bool _respuesta = false;
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        scrollable: true,
        title: Text(titulo, textAlign: TextAlign.center),
        content: Text(contenido),
        actions: [
          OutlineButton(
              shape: StadiumBorder(),
              onPressed: () {
                _respuesta = true;
                Navigator.pop(context, true);
              },
              child: Text('Si')),
          OutlineButton(
              shape: StadiumBorder(),
              onPressed: () {
                _respuesta = false;
                Navigator.pop(context, false);
              },
              child: Text('No')),
        ],
      ),
    );
    if (_respuesta == null) return false;
    return _respuesta;
  }

  int compararFechaConHoy(String _fecharecibida) {
    DateTime _fechaDelPedido = DateTime.parse(_fecharecibida),
        _hoy = DateTime.now();
    return (_fechaDelPedido.difference(_hoy).inDays).round();
  }

  int compararFechaConHoy_minutos(String _fecharecibida) {
    DateTime _fechaDelPedido = DateTime.parse(_fecharecibida),
        _hoy = DateTime.now();
    return (_fechaDelPedido.difference(_hoy).inMinutes).round();
  }

  String tiempo_desde(String _fecharecibida) {
    DateTime _f = DateTime.parse(_fecharecibida), _hoy = DateTime.now();
    return "${_f.hour > 12 ? _f.hour - 12 : _f.hour} : ${_f.minute} :${_f.second} ${_f.hour > 11 ? 'pm' : 'am'}";
  }

  bool verificar_vencimiento_memebresia(String _fecha_membresia) {
    if (_fecha_membresia == null || _fecha_membresia.length < 20) return false;
    if (compararFechaConHoy_minutos(_fecha_membresia) < 0) return false;
    return true;
  }

  Future<void> dialogo(
      String titulo, String contenido, BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        scrollable: true,
        title: Text(titulo, textAlign: TextAlign.center),
        content: Text(contenido, textAlign: TextAlign.center),
        actions: [
          FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: Text('DE ACUERDO')),
        ],
      ),
    );
  }

  Future<void> dialogoImagen(
      String imagenNetwork, BuildContext context, Size s) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        scrollable: true,
        content: Container(
          width: s.width * .5,
          height: s.width * .5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(s.width * .05),
              color: Colors.white,
              image: DecorationImage(
                  image: NetworkImage(imagenNetwork), fit: BoxFit.cover)),
        ),
        actions: [
          FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: Text('REGRESAR')),
        ],
      ),
    );
  }

  Future<void> dialogo_infor_viaje(
      Info_Viaje_cliente _v, int _num, BuildContext context, Size s) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        scrollable: true,
        titlePadding: EdgeInsets.all(5),
        contentPadding: EdgeInsets.all(20),
        title: Text(
          "INFORMACIÓN DEL VIAJE $_num",
          style: TextStyle(
            color: Colors.green[900],
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: s.width * .35,
              height: s.width * .35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(s.width * .05),
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(_v.foto), fit: BoxFit.cover)),
            ),
            SizedBox(
              height: s.height * .025,
            ),
            Text.rich(TextSpan(
              text: _v.estado == 1 || _v.estado == 2
                  ? "RECOGER EN:\n"
                  : "DESTINO:\n",
              children: [
                TextSpan(
                  text:
                      "${_v.estado == 1 || _v.estado == 2 ? _v.dir_origen : _v.dir_destino}\n",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ],
              style: TextStyle(
                  color: Colors.green[900],
                  fontWeight: FontWeight.w400,
                  fontSize: 18),
            )),
            Text.rich(
              TextSpan(
                  text: "\nNOMBRE DEL VIAJERO:\n",
                  style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w400,
                      fontSize: 15),
                  children: [
                    TextSpan(
                      text: "${_v.nombre}.",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ]),
              textAlign: TextAlign.center,
            ),
            Text.rich(
              TextSpan(
                  text: "\nCOSTO DEL VIAJE:\n",
                  style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w400,
                      fontSize: 15),
                  children: [
                    TextSpan(
                      text: "\$${_v.costo}",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ]),
              textAlign: TextAlign.center,
            ),
            if (_v.pasajeros != 3)
              Text.rich(
                TextSpan(
                    text: "\nVIAJE COMPARTIDO: ",
                    style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                    children: [
                      TextSpan(
                        text: "\n PASAJEROS: ${_v.pasajeros}",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                    ]),
                textAlign: TextAlign.center,
              ),
            Text.rich(
              TextSpan(
                  text: _v.estado == 1 || _v.estado == 2
                      ? "\nHORA DE SOLICITUD:\n"
                      : "\nHORA INICIO DEL VIAJE:\n",
                  style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.w400,
                      fontSize: 15),
                  children: [
                    TextSpan(
                      text: "${tiempo_desde(_v.fecha)}.",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ]),
              textAlign: TextAlign.center,
            ),
            Text(
              "\nCALIFICACIÓN DE ${_v.nombre.toUpperCase()}:",
              style: TextStyle(
                  color: Colors.green[900],
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
            RatingBar.builder(
              initialRating: _v.viajes >= 1 ? (_v.puntos / _v.viajes) : 5,
              minRating: 1,
              ignoreGestures: true,
              direction: Axis.horizontal,
              allowHalfRating: false,
              unratedColor: Colors.amber.withAlpha(50),
              itemCount: 5,
              itemSize: 40.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (du) {},
              updateOnDrag: false,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: Text(
              'REGRESAR',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Colors.yellow[900];
                return Colors.black; // Use the component's default.
              },
            )),
          ),
        ],
      ),
    );
  }

  Future<Position> obtener_ubicacion(BuildContext context) async {
    ///verifica si hay acceso a la ubicacion y si el gps esta encendido, si no hay permisos
    ///solicita los permisos, si aun asi sigue sin haber permisos o si el gps esta apagado devuelve nulo

    final _geo = GeolocatorPlatform.instance;
    DateTime _falsa = DateTime.now();

    if (!await _geo.isLocationServiceEnabled()) {
      await dialogo(
          "SIN PERMISOS DE UBICACIÓN",
          "Para poder localizar su ubicación es necesario tener encendido el servicio de ubicación y darnos permiso de conocerla. Active el GPS en su dispositivo y vuelva a intentarlo.",
          context);
      return null;
    }

    var _permisos = await _geo.checkPermission();
    if (_permisos == LocationPermission.denied) {
      _permisos = await Geolocator.requestPermission();
      if (_permisos == LocationPermission.denied) {
        return null;
      }
    }

    if (_permisos == LocationPermission.deniedForever) {
      await _geo.openAppSettings();
      return null;
    }

    return await _geo.getCurrentPosition();
  }

  Reg_viaje crear_un_viage(Perfil_conductor_M _misDatos, Position _gps) {
    final Reg_viaje _viajeActual = Reg_viaje(
      viajes_chofer: _misDatos.viajes < 1 ? 1 : _misDatos.viajes,
      puntos_chofer: _misDatos.cA < 5 ? 5 : _misDatos.cA,
      estado_viaje1: 0,
      estado_viaje2: 0,
      estado_viaje3: 0,
      pasajeros1: 0,
      pasajeros2: 0,
      pasajeros3: 0,
      lat_chofer: _gps.latitude,
      lon_chofer: _gps.longitude,
      lat_origen1: 0,
      lat_destino1: 0,
      lat_origen2: 0,
      lat_destino2: 0,
      lat_origen3: 0,
      lat_destino3: 0,
      lon_origen1: 0,
      lon_destino1: 0,
      lon_origen2: 0,
      lon_destino2: 0,
      lon_origen3: 0,
      lon_destino3: 0,
      costo_v1: 0,
      costo_v2: 0,
      costo_v3: 0,
      uid_chofer: _misDatos.uid,
      uid_v1: "",
      uid_v2: "",
      uid_v3: "",
      vehiculo: "Auto blanco 4 puertas",
      placas: "J63G58F",
      foto_chofer: _misDatos.foto,
      foto_v1: "",
      foto_v2: "",
      foto_v3: "",
      dir_destino1: "",
      dir_destino2: "",
      dir_destino3: "",
      dir_origen1: "",
      dir_origen2: "",
      dir_origen3: "",
      nombre_chofer: _misDatos.nombres + " " + _misDatos.aP,
      nombre_v1: "",
      nombre_v2: "",
      nombre_v3: "",
      fecha1: "",
      fecha2: "",
      fecha3: "",
      puntos_v1: 0,
      puntos_v2: 0,
      puntos_v3: 0,
      viajes_v1: 0,
      viajes_v2: 0,
      viajes_v3: 0,
    );

    return _viajeActual;
  }

  Future<void> dialogo_sin_internet(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        scrollable: true,
        title: Text("SIN INTERNET",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.green[900]),
            textAlign: TextAlign.center),
        content: Stack(
          //<div>Iconos diseñados por <a href="https://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.es/" title="Flaticon">www.flaticon.es</a></div>
          children: [
            Text("Por favor conectese a internet y vuelva a intentarlo.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center)
          ],
        ),
        actions: [
          FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
              color: Colors.green[100],
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: Text('DE ACUERDO')),
        ],
      ),
    );
  }

  Widget pantalla_carga_blurr(bool _cargando, Size s) {
    return _cargando
        ? BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              width: s.width,
              height: s.height,
              color: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.green, strokeWidth: 8.0),
                    SizedBox(
                      height: s.height * .1,
                    ),
                    Text(
                      'CARGANDO',
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            ))
        : Container(width: 0, height: 0);
  }

  Widget pantalla_carga_espera(bool _cargando, Size s) {
    return _cargando
        ? BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              width: s.width,
              height: s.height,
              color: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.green, strokeWidth: 8.0),
                    SizedBox(
                      height: s.height * .1,
                    ),
                    Text(
                      'TERMINANDO VIAJE',
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ))
        : Container(width: 0, height: 0);
  }

  bool revisar_gmail(String _correo) {
    //esta funcion busca el @ del correo y despues evalua que sea un correo de gmail, si no lo es retorna falso. siempre debe usarse
    //despues de evaluar que el correo tenga el formato correcto con la funcion  evaluar_email().
    if (_correo == null || _correo.length < 11) return false;
    int _index = 0;
    if (_correo == null) return false;
    _correo = _correo.toLowerCase();
    for (int i = 0; i < _correo.length; i++) {
      if (_correo.substring(i, i + 1) == "@") {
        _index = i;
        i = _correo.length + 100;
      }
    }

    if (_index == 0) return false;
    if (_correo.substring(_index, _correo.length) == "@gmail.com") return true;

    return false;
  }

  bool evaluar_email(String _mail) {
    //recibe una cadena con un email y evalua si los caracteres proporcionados son correctos

    if (_mail == null || _mail == "") return false;
    bool _respuesta =
        (RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                .hasMatch(_mail) &&
            revisar_gmail(_mail));
    return _respuesta;
  }

  bool evaluar_nombre(String _nombre) {
    if (_nombre == null || _nombre == "" || _nombre.length <= 2) return false;
    //recibe una cadena con un nombre de usuario evalua si los caracteres proporcionados son correctos
    return RegExp(r"^[a-zA-Z0-9_]+").hasMatch(_nombre);
  }

  bool evaluar_telefono(String _tel) {
    //recibe una cadena el numero telefonico evalua si los caracteres proporcionados son solo numeros y son 10 digitos
    if (_tel == null) return false;
    if (_tel.length != 10) return false;
    List<String> _numeros = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    for (int i = 0; i < 10; i++) {
      if (!_numeros.any((element) => element == _tel.substring(i, i + 1)))
        return false;
    }
    return true;
  }

  String formatoDeFechaHora(String _a) {
    DateTime _f = DateTime.parse(_a);
    String _dia = "";
    if (_f == null) return "";
    if (_f.weekday == 1)
      _dia = "Lunes";
    else if (_f.weekday == 2)
      _dia = "Martes";
    else if (_f.weekday == 3)
      _dia = "Miércoles";
    else if (_f.weekday == 4)
      _dia = "Jueves";
    else if (_f.weekday == 5)
      _dia = "Viernes";
    else if (_f.weekday == 6)
      _dia = "Sábado";
    else if (_f.weekday == 7) _dia = "Domingo";
    _dia += " ${_f.day} de ";

    if (_f.month == 1)
      _dia += "Enero";
    else if (_f.month == 2)
      _dia += "Febrero";
    else if (_f.month == 3)
      _dia += "Marzo";
    else if (_f.month == 4)
      _dia += "Abril";
    else if (_f.month == 5)
      _dia += "Mayo";
    else if (_f.month == 6)
      _dia += "Junio";
    else if (_f.month == 7)
      _dia += "Julio";
    else if (_f.month == 8)
      _dia += "Agosto";
    else if (_f.month == 9)
      _dia += "Septiembre";
    else if (_f.month == 10)
      _dia += "Octubre";
    else if (_f.month == 11)
      _dia += "Noviembre";
    else if (_f.month == 12) _dia += "Diciembre";

    _dia += " del ${_f.year}  ";

    _dia += "${_f.hour}:${_f.minute}:${_f.second}";

    return _dia;
  }

  String formatoHora(String _a) {
    if (_a == null || _a == "") return "-";
    DateTime _f = DateTime.parse(_a);
    String _dia = "";

    if (_f.hour < 12) return "${_f.hour}:${_f.minute} AM";
    if (_f.hour == 12) return "${_f.hour}:${_f.minute} PM";
    return "${_f.hour - 12}:${_f.minute} PM";
  }

  String formatoDeFecha(String _a) {
    DateTime _f = DateTime.parse(_a);
    String _dia = "";
    if (_f == null) return "";
    if (_f.weekday == 1)
      _dia = "Lunes";
    else if (_f.weekday == 2)
      _dia = "Martes";
    else if (_f.weekday == 3)
      _dia = "Miércoles";
    else if (_f.weekday == 4)
      _dia = "Jueves";
    else if (_f.weekday == 5)
      _dia = "Viernes";
    else if (_f.weekday == 6)
      _dia = "Sábado";
    else if (_f.weekday == 7) _dia = "Domingo";
    _dia += " ${_f.day} de ";

    if (_f.month == 1)
      _dia += "Enero";
    else if (_f.month == 2)
      _dia += "Febrero";
    else if (_f.month == 3)
      _dia += "Marzo";
    else if (_f.month == 4)
      _dia += "Abril";
    else if (_f.month == 5)
      _dia += "Mayo";
    else if (_f.month == 6)
      _dia += "Junio";
    else if (_f.month == 7)
      _dia += "Julio";
    else if (_f.month == 8)
      _dia += "Agosto";
    else if (_f.month == 9)
      _dia += "Septiembre";
    else if (_f.month == 10)
      _dia += "Octubre";
    else if (_f.month == 11)
      _dia += "Noviembre";
    else if (_f.month == 12) _dia += "Diciembre";

    _dia += " del ${_f.year}";

    return _dia;
  }

  Future<List<Reg_viaje>> escuchar_viajes(
      int _asientos_disponibles, BuildContext context) async {
    QuerySnapshot<Map<String, dynamic>> _viajes;

    try {
      _viajes = await FirebaseFirestore.instance
          .collection("viajes_en_curso")
          .where("numero_viajeros", isLessThanOrEqualTo: _asientos_disponibles)
          .get();
    } catch (e) {
      await dialogo("GUBO PROBLEMAS", "Al descargar los viajes", context);
      return [];
    }

    List<Reg_viaje> _solicitudes = [];
    if (_viajes.docs.length > 0) {
      _viajes.docs.forEach((_viaje) {
        Reg_viaje _v = Reg_viaje.fromJson(_viaje.data());
        _solicitudes.add(_v);
      });
    }

    if (_solicitudes.isNotEmpty) return _solicitudes;

    var _listener = FirebaseFirestore.instance
        .collection("viajes_en_curso")
        .where("numero_viajeros", isLessThanOrEqualTo: _asientos_disponibles);

    int _segundo = 0;

    while (_segundo > 60 && _solicitudes.isEmpty) {
      _listener.snapshots().listen((event) {
        if (event.docs.length > 0) {
          event.docs.forEach((_viaje) {
            Reg_viaje _v = Reg_viaje.fromJson(_viaje.data());
            _solicitudes.add(_v);
          });
        }
      });
      await Future.delayed(const Duration(seconds: 2));
      _segundo++;
    }

    return _solicitudes;
  }

  Widget invisible() {
    return Container(
      width: 0,
      height: 0,
    );
  }

  String _cambioIndice(String _indice) {
    if (_indice == "1)") return "2)";
    if (_indice == "2)") return "3)";
    if (_indice == "3)") return "4)";
    if (_indice == "4)") return "5)";
    if (_indice == "5)") return "6)";
    if (_indice == "6)") return "7)";
    if (_indice == "7)") return "8)";
    if (_indice == "8)") return "9)";
    if (_indice == "9)") return "10)";
    if (_indice == "10)") return "11)";
    if (_indice == "11)") return "12)";
    return "13)";
  }

  Future<bool> verificar_datos_para_crear_perfil(
      String _foto,
      String _nombres,
      String _aP,
      String _aM,
      String _direccion,
      String _correo,
      String _cs1,
      String _cs2,
      String _telefono,
      BuildContext context) async {
    int _paso = 1;
    String _errores = "", _indice = "1)";

    if (!evaluar_nombre(_nombres)) {
      _errores += "$_indice Error con el nombre de usuario.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (!evaluar_nombre(_aP)) {
      _errores += "$_indice Error con su apellido paterno.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (!evaluar_nombre(_aM)) {
      _errores += "$_indice Error con el apellido materno.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (_direccion == null || _direccion == "") {
      _errores += "$_indice No se ingresó ninguna dirección.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (_telefono == null ||
        _telefono.length != 10 ||
        !evaluar_telefono(_telefono)) {
      _errores += "$_indice Número telefónico inválido o nulo.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (!evaluar_email(_correo)) {
      _errores += "$_indice Error en su correo electrónico.\n\n";
      _indice = _cambioIndice(_indice);
    }

    if (_cs2 == null || _cs2.length < 6) {
      _errores += "$_indice Error en la contraseña de verificación.\n";
    }

    if (_cs1 == null || _cs1.length < 6) {
      _errores += "$_indice Error en la contraseña.\n";
    }

    if (_cs1 != _cs2) {
      _errores += "$_indice Las contraseñas no coinciden.\n";
    }

    if (_errores != "") {
      Funciones _f = new Funciones();
      await _f.dialogo("ERRORES EN SUS DATOS",
          "Se detectaron los siguientes errores:\n\n$_errores", context);
      return false;
    }

    return true;
  }

  Reg_viaje eliminar_un_viajero(int _viajero, Reg_viaje _viaje) {
    if (_viajero > 3 || _viajero < 1 || _viajero == null || _viaje == null) {
      return _viaje;
    }

    Reg_viaje _viaje_n;
    if (_viajero == 1) {
      _viaje_n = Reg_viaje(
          viajes_chofer: _viaje.viajes_chofer,
          puntos_chofer: _viaje.puntos_chofer,
          estado_viaje1: _viaje.estado_viaje2,
          estado_viaje2: _viaje.estado_viaje3,
          estado_viaje3: 0,
          pasajeros1: _viaje.pasajeros2,
          pasajeros2: _viaje.pasajeros3,
          pasajeros3: 0,
          lat_chofer: _viaje.lat_chofer,
          lon_chofer: _viaje.lon_chofer,
          lat_origen1: _viaje.lat_origen2,
          lat_destino1: _viaje.lat_destino2,
          lat_origen2: _viaje.lat_origen3,
          lat_destino2: _viaje.lat_destino3,
          lat_origen3: 0,
          lat_destino3: 0,
          lon_origen1: _viaje.lon_origen2,
          lon_destino1: _viaje.lon_destino2,
          lon_origen2: _viaje.lon_origen3,
          lon_destino2: _viaje.lon_destino3,
          lon_origen3: 0,
          lon_destino3: 0,
          costo_v1: _viaje.costo_v2,
          costo_v2: _viaje.costo_v3,
          costo_v3: 0,
          uid_chofer: _viaje.uid_chofer,
          uid_v1: _viaje.uid_v2,
          uid_v2: _viaje.uid_v3,
          uid_v3: "",
          vehiculo: _viaje.vehiculo,
          placas: _viaje.placas,
          foto_chofer: _viaje.foto_chofer,
          foto_v1: _viaje.foto_v2,
          foto_v2: _viaje.foto_v3,
          foto_v3: "",
          dir_destino1: _viaje.dir_destino2,
          dir_destino2: _viaje.dir_destino3,
          dir_destino3: "",
          dir_origen1: _viaje.dir_origen2,
          dir_origen2: _viaje.dir_origen3,
          dir_origen3: "",
          nombre_chofer: _viaje.nombre_chofer,
          nombre_v1: _viaje.nombre_v2,
          nombre_v2: _viaje.nombre_v3,
          nombre_v3: "",
          fecha1: _viaje.fecha2,
          fecha2: _viaje.fecha3,
          fecha3: "",
          puntos_v1: _viaje.puntos_v2,
          puntos_v2: _viaje.puntos_v3,
          puntos_v3: 0,
          viajes_v1: _viaje.viajes_v2,
          viajes_v2: _viaje.viajes_v3,
          viajes_v3: 0,
          raites1: _viaje.raites2,
          raites2: _viaje.raites3,
          raites3: 0);
      return _viaje_n;
    }

    if (_viajero == 2) {
      _viaje_n = Reg_viaje(
          viajes_chofer: _viaje.viajes_chofer,
          puntos_chofer: _viaje.puntos_chofer,
          estado_viaje1: _viaje.estado_viaje1,
          estado_viaje2: _viaje.estado_viaje3,
          estado_viaje3: 0,
          pasajeros1: _viaje.pasajeros1,
          pasajeros2: _viaje.pasajeros3,
          pasajeros3: 0,
          lat_chofer: _viaje.lat_chofer,
          lon_chofer: _viaje.lon_chofer,
          lat_origen1: _viaje.lat_origen1,
          lat_destino1: _viaje.lat_destino1,
          lat_origen2: _viaje.lat_origen3,
          lat_destino2: _viaje.lat_destino3,
          lat_origen3: 0,
          lat_destino3: 0,
          lon_origen1: _viaje.lon_origen1,
          lon_destino1: _viaje.lon_destino1,
          lon_origen2: _viaje.lon_origen3,
          lon_destino2: _viaje.lon_destino3,
          lon_origen3: 0,
          lon_destino3: 0,
          costo_v1: _viaje.costo_v1,
          costo_v2: _viaje.costo_v3,
          costo_v3: 0,
          uid_chofer: _viaje.uid_chofer,
          uid_v1: _viaje.uid_v1,
          uid_v2: _viaje.uid_v3,
          uid_v3: "",
          vehiculo: _viaje.vehiculo,
          placas: _viaje.placas,
          foto_chofer: _viaje.foto_chofer,
          foto_v1: _viaje.foto_v1,
          foto_v2: _viaje.foto_v3,
          foto_v3: "",
          dir_destino1: _viaje.dir_destino1,
          dir_destino2: _viaje.dir_destino3,
          dir_destino3: "",
          dir_origen1: _viaje.dir_origen1,
          dir_origen2: _viaje.dir_origen3,
          dir_origen3: "",
          nombre_chofer: _viaje.nombre_chofer,
          nombre_v1: _viaje.nombre_v1,
          nombre_v2: _viaje.nombre_v3,
          nombre_v3: "",
          fecha1: _viaje.fecha1,
          fecha2: _viaje.fecha3,
          fecha3: "",
          puntos_v1: _viaje.puntos_v1,
          puntos_v2: _viaje.puntos_v3,
          puntos_v3: 0,
          viajes_v1: _viaje.viajes_v1,
          viajes_v2: _viaje.viajes_v3,
          viajes_v3: 0,
          raites1: _viaje.raites1,
          raites2: _viaje.raites3,
          raites3: 0);
      return _viaje_n;
    }

    if (_viajero == 3) {
      _viaje_n = Reg_viaje(
          viajes_chofer: _viaje.viajes_chofer,
          puntos_chofer: _viaje.puntos_chofer,
          estado_viaje1: _viaje.estado_viaje1,
          estado_viaje2: _viaje.estado_viaje2,
          estado_viaje3: 0,
          pasajeros1: _viaje.pasajeros1,
          pasajeros2: _viaje.pasajeros2,
          pasajeros3: 0,
          lat_chofer: _viaje.lat_chofer,
          lon_chofer: _viaje.lon_chofer,
          lat_origen1: _viaje.lat_origen1,
          lat_destino1: _viaje.lat_destino1,
          lat_origen2: _viaje.lat_origen2,
          lat_destino2: _viaje.lat_destino2,
          lat_origen3: 0,
          lat_destino3: 0,
          lon_origen1: _viaje.lon_origen1,
          lon_destino1: _viaje.lon_destino1,
          lon_origen2: _viaje.lon_origen2,
          lon_destino2: _viaje.lon_destino2,
          lon_origen3: 0,
          lon_destino3: 0,
          costo_v1: _viaje.costo_v1,
          costo_v2: _viaje.costo_v2,
          costo_v3: 0,
          uid_chofer: _viaje.uid_chofer,
          uid_v1: _viaje.uid_v1,
          uid_v2: _viaje.uid_v2,
          uid_v3: "",
          vehiculo: _viaje.vehiculo,
          placas: _viaje.placas,
          foto_chofer: _viaje.foto_chofer,
          foto_v1: _viaje.foto_v1,
          foto_v2: _viaje.foto_v2,
          foto_v3: "",
          dir_destino1: _viaje.dir_destino1,
          dir_destino2: _viaje.dir_destino2,
          dir_destino3: "",
          dir_origen1: _viaje.dir_origen1,
          dir_origen2: _viaje.dir_origen2,
          dir_origen3: "",
          nombre_chofer: _viaje.nombre_chofer,
          nombre_v1: _viaje.nombre_v1,
          nombre_v2: _viaje.nombre_v2,
          nombre_v3: "",
          fecha1: _viaje.fecha1,
          fecha2: _viaje.fecha2,
          fecha3: "",
          puntos_v1: _viaje.puntos_v1,
          puntos_v2: _viaje.puntos_v2,
          puntos_v3: 0,
          viajes_v1: _viaje.viajes_v1,
          viajes_v2: _viaje.viajes_v2,
          viajes_v3: 0,
          raites1: _viaje.raites1,
          raites2: _viaje.raites2,
          raites3: 0);
      return _viaje_n;
    }
  }

  Reg_viaje clonar_viaje(Reg_viaje _o) {
    if (_o == null) return null;
    Reg_viaje _n = Reg_viaje(
        uid_chofer: _o.uid_chofer,
        uid_v1: _o.uid_v1,
        uid_v2: _o.uid_v2,
        uid_v3: _o.uid_v3,
        vehiculo: _o.vehiculo,
        placas: _o.placas,
        foto_chofer: _o.foto_chofer,
        foto_v1: _o.foto_v1,
        foto_v2: _o.foto_v2,
        foto_v3: _o.foto_v3,
        dir_origen1: _o.dir_origen1,
        dir_destino1: _o.dir_destino1,
        dir_origen2: _o.dir_origen2,
        dir_destino2: _o.dir_destino2,
        dir_origen3: _o.dir_origen3,
        dir_destino3: _o.dir_destino3,
        nombre_chofer: _o.nombre_chofer,
        nombre_v1: _o.nombre_v1,
        nombre_v2: _o.nombre_v2,
        nombre_v3: _o.nombre_v3,
        fecha1: _o.fecha1,
        fecha2: _o.fecha2,
        fecha3: _o.fecha3,
        lat_chofer: _o.lat_chofer,
        lon_chofer: _o.lon_chofer,
        lat_origen1: _o.lat_origen1,
        lon_origen1: _o.lon_origen1,
        lat_destino1: _o.lat_destino1,
        lon_destino1: _o.lon_destino1,
        lat_origen2: _o.lat_origen2,
        lon_origen2: _o.lon_origen2,
        lat_destino2: _o.lat_destino2,
        lon_destino2: _o.lon_destino2,
        lat_origen3: _o.lat_origen3,
        lon_origen3: _o.lon_origen3,
        lat_destino3: _o.lat_destino3,
        lon_destino3: _o.lon_destino3,
        costo_v1: _o.costo_v1,
        costo_v2: _o.costo_v2,
        costo_v3: _o.costo_v3,
        id: _o.id,
        viajes_chofer: _o.viajes_chofer,
        puntos_chofer: _o.puntos_chofer,
        puntos_v1: _o.puntos_v1,
        puntos_v2: _o.puntos_v2,
        puntos_v3: _o.puntos_v3,
        viajes_v1: _o.viajes_v1,
        viajes_v2: _o.viajes_v2,
        viajes_v3: _o.viajes_v3,
        estado_viaje1: _o.estado_viaje1,
        estado_viaje2: _o.estado_viaje2,
        estado_viaje3: _o.estado_viaje3,
        pasajeros1: _o.pasajeros1,
        pasajeros2: _o.pasajeros2,
        pasajeros3: _o.pasajeros3,
        raites1: _o.raites1,
        raites2: _o.raites2,
        raites3: _o.raites3);

    return _n;
  }

  Info_Viaje_cliente info_de_viaje(Reg_viaje _v, int _turno) {
    if (_turno == 1) {
      return Info_Viaje_cliente(
          _v.uid_v1,
          _v.foto_v1,
          _v.dir_origen1,
          _v.dir_destino1,
          _v.nombre_v1,
          _v.fecha1,
          _v.lat_origen1,
          _v.lon_origen1,
          _v.lat_destino1,
          _v.lon_destino1,
          _v.costo_v1,
          _v.puntos_v1,
          _v.viajes_v1,
          _v.estado_viaje1,
          _v.pasajeros1,
          _v.raites1);
    } else if (_turno == 2) {
      return Info_Viaje_cliente(
          _v.uid_v2,
          _v.foto_v2,
          _v.dir_origen2,
          _v.dir_destino2,
          _v.nombre_v2,
          _v.fecha2,
          _v.lat_origen2,
          _v.lon_origen2,
          _v.lat_destino2,
          _v.lon_destino2,
          _v.costo_v2,
          _v.puntos_v2,
          _v.viajes_v2,
          _v.estado_viaje2,
          _v.pasajeros2,
          _v.raites2);
    } else if (_turno == 3) {
      return Info_Viaje_cliente(
          _v.uid_v3,
          _v.foto_v3,
          _v.dir_origen3,
          _v.dir_destino3,
          _v.nombre_v3,
          _v.fecha3,
          _v.lat_origen3,
          _v.lon_origen3,
          _v.lat_destino3,
          _v.lon_destino3,
          _v.costo_v3,
          _v.puntos_v3,
          _v.viajes_v3,
          _v.estado_viaje3,
          _v.pasajeros3,
          _v.raites3);
    }
  }

  Reg_viaje agregar_un_viajero(Reg_solicitud_viaje _s, Reg_viaje _v) {
    if (_s == null || _v == null) {
      return _v;
    }

    if (_v.uid_v1 == null || _v.uid_v1 == "") {
      _v.uid_v1 = _s.uid_viajero;
      _v.foto_v1 = _s.foto;
      _v.estado_viaje1 = 1;
      _v.pasajeros1 = _s.num_pasajeros;
      _v.lat_origen1 = _s.lat_origen;
      _v.lon_origen1 = _s.lon_origen;
      _v.lat_destino1 = _s.lat_destino;
      _v.lon_destino1 = _s.lon_destino;
      _v.costo_v1 = _s.costo_viaje;
      _v.dir_destino1 = _s.direccion_destino;
      _v.dir_origen1 = _s.direccion_origen;
      _v.nombre_v1 = _s.nombre_viajero;
      _v.fecha1 = _s.fecha;
      //puntos_v1: _viaje.puntos_v2,
      //viajes_v1: _viaje.viajes_v2,

      return _v;
    } else if (_v.uid_v2 == null || _v.uid_v2 == "") {
      _v.uid_v2 = _s.uid_viajero;
      _v.estado_viaje2 = 1;
      _v.foto_v2 = _s.foto;
      _v.pasajeros2 = _s.num_pasajeros;
      _v.lat_origen2 = _s.lat_origen;
      _v.lon_origen2 = _s.lon_origen;
      _v.lat_destino2 = _s.lat_destino;
      _v.lon_destino2 = _s.lon_destino;
      _v.costo_v2 = _s.costo_viaje;
      _v.dir_destino2 = _s.direccion_destino;
      _v.dir_origen2 = _s.direccion_origen;
      _v.nombre_v2 = _s.nombre_viajero;
      _v.fecha2 = _s.fecha;
      //puntos_v1: _viaje.puntos_v2,
      //viajes_v1: _viaje.viajes_v2,

      return _v;
    } else if (_v.uid_v3 == null || _v.uid_v3 == "") {
      _v.uid_v3 = _s.uid_viajero;
      _v.estado_viaje3 = 1;
      _v.foto_v3 = _s.foto;
      _v.pasajeros3 = _s.num_pasajeros;
      _v.lat_origen3 = _s.lat_origen;
      _v.lon_origen3 = _s.lon_origen;
      _v.lat_destino3 = _s.lat_destino;
      _v.lon_destino3 = _s.lon_destino;
      _v.costo_v3 = _s.costo_viaje;
      _v.dir_destino3 = _s.direccion_destino;
      _v.dir_origen3 = _s.direccion_origen;
      _v.nombre_v3 = _s.nombre_viajero;
      _v.fecha3 = _s.fecha;
      //puntos_v1: _viaje.puntos_v2,
      //viajes_v1: _viaje.viajes_v2,

      return _v;
    }
  }
}
