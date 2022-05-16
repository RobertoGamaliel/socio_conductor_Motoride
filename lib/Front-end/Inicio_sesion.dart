// ignore_for_file: prefer_const_constructors

import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socio_conductor/Back-end/BD.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Tarifas_M.dart';
import 'package:socio_conductor/Front-end/CambioContrasena.dart';
import 'package:socio_conductor/Front-end/PaginaAdministrador.dart';
import 'package:socio_conductor/Front-end/Pagina_Mapa.dart';

///Esta es la pantalla que se abre al iniciar la aplicacion, ahora mismo utiliza el perfil
///de socio conductor solo para realizar las pruebas.
class Inicio_de_sesion extends StatefulWidget {
  Inicio_de_sesion({Key key}) : super(key: key);
  @override
  _Inicio_de_sesionState createState() => _Inicio_de_sesionState();
}

class _Inicio_de_sesionState extends State<Inicio_de_sesion> {
  bool _showPassword = false, _cargando = false;
  String _mail = "", _cs = "";
  final Funciones _f = new Funciones();
  Perfil_conductor_M _misDatos;
  int _result = 0;
  Size s;

  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;
    /*if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser.uid != null)
      return Pagina_Mapa(_misDatos);*/

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          title: const Text('SOCIO CONDUCTOR'),
          centerTitle: true,
          actions: [],
        ),
        body: Stack(children: [
          _color_fondo(s),
          _pantalla_formularios_y_boton(s),
          _f.pantalla_carga_blurr(_cargando, s)
        ]));
  }

  Widget _color_fondo(Size s) {
    return Container(
      width: s.width,
      color: Colors.white,
      child: ListView(
        children: [
          Container(
            width: s.width,
            height: s.height * .25,
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.green[50],
                      Colors.green[100],
                      Colors.green[200],
                      Colors.green[300],
                      Colors.green[400],
                      Colors.green[500],
                      Colors.green[600],
                      Colors.green[700],
                      Colors.green[800],
                      Colors.green[900],
                      Colors.black
                    ])),
          ),
        ],
      ),
    );
  }

  Widget _pantalla_formularios_y_boton(Size s) {
    return Container(
      width: s.width,
      height: s.height,
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(
          s.width * .05, s.height * .05, s.width * .05, s.width * .05),
      child: ListView(
        children: [
          _logo(s),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(s.width * .025, s.height * .01,
                      s.width * .025, s.height * .01),
                  child: Center(
                    child: Text(
                        'Inicie sesión con sus datos de socio conductor.',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.green[900],
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                  )),
              Divider(
                color: Colors.green[600],
                indent: s.width * .15,
                endIndent: s.width * .15,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(s.width * .025, s.height * .01,
                    s.width * .025, s.height * .01),
                child: TextField(
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      hintText: 'Correo electronico'),
                  onChanged: (String u) {
                    _mail = u;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(s.width * .025, s.height * .015,
                    s.width * .025, s.height * .035),
                child: TextField(
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.security),
                    suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: _showPassword ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        }),
                  ),
                  onChanged: (c) {
                    _cs = c;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    color: Colors.black,
                    child: InkWell(
                      splashColor: Colors.yellow,
                      highlightColor: Colors.green,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        //Evaluar que el e-mail tenga el formato correcto y que ademas dea de gmail
                        if (!_f.evaluar_email(_mail)) {
                          await _f.dialogo(
                              "PROBLEMA CON EL E-MAIL",
                              "Revise su dirección de correo electrónico",
                              context);
                          return;
                        }

                        //Revisar que se ingresó una contraseña
                        if (_cs == null || _cs.length < 6) {
                          await _f.dialogo("PROBLEMA CON LA CONTRASEÑA",
                              "Contraseña corta o nula.", context);
                          return;
                        }

                        //se activa la pantalla de carga
                        setState(() {
                          _cargando = true;
                        });

                        //descargar ubicacion
                        Position _pos = await permisos_ubicacion(context);
                        if (_pos == null) {
                          //se activa la pantalla de carga
                          setState(() {
                            _cargando = false;
                          });
                          return;
                        }

                        //verificar si hay internet
                        if (!await ConnectionVerify.connectionStatus()) {
                          _f.dialogo_sin_internet(context);
                          setState(() {
                            _cargando = false;
                          });
                          return;
                        }

                        //obtener credencial de autenticacion con el inicio de sesion.
                        _misDatos =
                            await BD.bd.iniciar_sesion(_mail, _cs, context);
                        if (_misDatos == null) {
                          setState(() {
                            _cargando = false;
                          });
                          return;
                        }

                        /*if (_cs == "nuevoconductor") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CambioContrasena(_cs, _mail)));
                          return;
                        }*/

                        if (FirebaseAuth.instance.currentUser.uid ==
                                "e27A4oWLRiWVdnilrxC2LWKcSrI2" ||
                            FirebaseAuth.instance.currentUser.uid ==
                                "zITIWl5PXedQDh3eNHPeRw7oBbc2") {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PaginaAdministrador()));
                          return;
                        }

                        Tarifas_M _tarifas;
                        if ((_tarifas = await BD.bd.obtener_tarifas(context)) ==
                            null) {
                          await _f.dialogo(
                              "ERROR",
                              "Hubo un error al recuperar las tarifas",
                              context);
                          setState(() {
                            _cargando = false;
                          });
                          return;
                        }

                        Reg_viaje _miViaje = await BD.bd
                            .recueperar_viaje(_misDatos, _pos, context);

                        if (_miViaje == null) {
                          setState(() {
                            _cargando = false;
                          });
                          return;
                        }
                        setState(() {
                          _cargando = false;
                        });

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Pagina_Mapa(
                                    _misDatos, _miViaje, _tarifas, _pos)));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: const Text(
                          'INICIAR SESIÓN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.transparent,
                            border: Border.all(color: Colors.green, width: 4)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logo(Size s) {
    return Container(
      width: s.width,
      height: s.width * .25,
      margin: EdgeInsets.only(bottom: 15, top: 15),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/logos/logoExtendidoBlanco.png"),
            fit: BoxFit.contain),
        color: Colors.transparent,
      ),
      alignment: Alignment.center,
    );
  }

  Future<Position> permisos_ubicacion(BuildContext context) async {
    ///Esta funcion revisa si hay permisos para solicitar la ubicacion de usuario y si el
    ///gps esta apagado o prendido. En caso de estar apagado devuelve una posicion de valor imposible
    /// y la retorna.
    /// si no hay permisos para obtener la ubicacion, entonces intenta obtenerlos, si son denegados retorna la
    /// posicion imposible.
    /// Si los permisos estas activos entonces retorna la ubicacion actual
    final _geo = GeolocatorPlatform.instance;

    if (!await _geo.isLocationServiceEnabled()) {
      ///verificamos si el gps esta encendido
      Widget _contenido = Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "GPS APAGADO\n",
            style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.w600,
                fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Text(
            "El GPS del dispositivo esta apagado, enciéndalo y vuelva a intentarlo\n",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w300, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Image.asset("assets/logos/mundo.gif", width: s.width * .3)
        ],
      ));
      await _f.dialogoWidget(_contenido, context);
      return null;
    }

    var _permisos = await _geo.checkPermission();
    //verificamos si tenemos permisos para obtener la ubicación

    if (_permisos == LocationPermission.denied ||
        _permisos == LocationPermission.unableToDetermine) {
      _permisos = await Geolocator.requestPermission();
      if (_permisos != LocationPermission.always &&
          _permisos != LocationPermission.whileInUse) {
        Widget _contenido = Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "SIN ACCESO A SU UBICACIÓN\n",
              style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w600,
                  fontSize: 24),
              textAlign: TextAlign.center,
            ),
            Text(
              "Para poder continuar es necesario conocer su ubicación, vuelva intentar iniciar sesión y acepte la solicitud para acceder a la ubicación.\n",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Image.asset("assets/logos/mundo.gif", width: s.width * .3)
          ],
        ));
        await _f.dialogoWidget(_contenido, context);
        return null;
      }
    }

    if (_permisos == LocationPermission.deniedForever) {
      Widget _contenido = Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "ACCESO A LA UBICACIÓN BLOQUEADO\n",
            style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.w600,
                fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Text(
            "Para poder continuar es necesario conocer su ubicación, Se abrirá el menú de permisos de ubicación.\n",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w300, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Image.asset("assets/logos/globo.gif", width: s.width * .3)
        ],
      ));
      await _f.dialogoWidget(_contenido, context);
      await _geo.openAppSettings();
      return null;
    }

    var _pos = await _geo.getCurrentPosition();
    if (_pos == null) {
      await _f.dialogo(
          "Hubo un problema",
          "No conseguimos obtener su ubicación, por favor espere unos segundos e inténtelo nuevamente.",
          context);
      return null;
    }

    return _pos;
  }
}
