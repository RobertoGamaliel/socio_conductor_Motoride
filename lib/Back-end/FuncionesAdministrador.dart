import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socio_conductor/Back-end/BD.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';

import 'Funciones.dart';

class FuncionesAdministrador extends Funciones {
  FuncionesAdministrador();
  bool validarNombres(String _nombre) {
    if (_nombre == null) {
      return false;
    }
    final RegExp nameExp = RegExp(r'^[A-Za-záéíóúüÑñ ]+$');
    return nameExp.hasMatch(_nombre);
  }

  bool validar_CURP(String _curp) {
    ///utiliza una expresion regular para verificar el formato de la curp
    return RegExp(
            r"^[A-Z]{1}[AEIOU]{1}[A-Z]{2}[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[HM]{1}(AS|BC|BS|CC|CS|CH|CL|CM|DF|DG|GT|GR|HG|JC|MC|MN|MS|NT|NL|OC|PL|QT|QR|SP|SL|SR|TC|TS|TL|VZ|YN|ZS|NE)[B-DF-HJ-NP-TV-Z]{3}[0-9A-Z]{1}[0-9]{1}")
        .hasMatch(_curp);
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

  bool verificar_RFC(String _rfc) {
    return RegExp(
            r"^([A-ZÑ&]{3,4}) ?(?:- ?)?(\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])) ?(?:- ?)?([A-Z\d]{2})([A\d])")
        .hasMatch(_rfc);
  }

  Future<String> _crear_cuenta(String _mailAdmin, String _csAdmin, String _mail,
      BuildContext context) async {
    ///Esta funcion crea una cuenta de usuario nueva, al crearla se mantiene iniciada la sesión con el usuario nuevo
    /// "***creacion error": hubó un error al crear el nuevo usuario
    /// "***error": errores inherentes al funcionamiento de firestore o internet
    /// "": Creacion exitosa

    ///verifica que hay internet
    if (!await ConnectionVerify.connectionStatus()) {
      await dialogo_sin_internet(context);
      return "**error";
    }

    ///Crea una nueva cuenta de usuario, si el proceso es exitoso, retorna la crredencial del nuevo usuario
    UserCredential _credencial;
    try {
      _credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _mail, password: "nuevoconductor");
    } catch (e) {
      print("Error al crear nuevo usuario $e");
      return "***creacion error";
    }

    return "";
  }

  Future<int> crearNuevoConductor(
      BuildContext context,
      Perfil_conductor_M _misDatos,
      File _ImagenSelfie,
      File _imagenCredencial) async {
    ///Esta funcion es parte del middelware de esta aplicacion.
    ///Permite crear un perfil de usuario a partir de de un perfil con los datos de entrada
    ///ya verificadas.
    ///La aplicacion verifica que el usuario que accede es el mismo que inicialmente ha accedido
    ///con las credenciales de solcio administrador, si no es asi entonces elimina la base de datos
    ///local, cierra sesion y envia un valor especial.
    ///Si el usuario es el correcto, crea :
    /// 1) Una nueva cuenta de usuario conductor
    ///     si hay algun error devuelve un valor de error de funcionamiento.
    /// 2) carga las fotos de perfil y credencial del usuario
    ///     si hay algun error elimina el nuevo usuario recien creado y
    ///     devuelve un valor de error de funcionamiento.
    /// 3) Crea El perfil de usuario en firestore.
    ///      Si hay algún error elimina el usuario recien creado y las fotos de perfil
    ///       y retoorna un valor de error de funcionamiento
    /// en cualquiera de los casos de error de funcionamiento o de exito se inicia sesión con las credenciales del administrador al terminar
    /// valores de retorno:
    ///  1: error de funcionamiento o de conexión
    ///  2: violacion de seguirdad
    ///  3: operación exitosa
    String _uid, _csAdmin, _mailAdmin;

    //copiamos el uid (su credencial) actual del usuario
    try {
      _uid = FirebaseAuth.instance.currentUser.uid;
      // ignore: empty_catches
    } catch (e) {}

    ///Si el usuario no tiene una uid asociada esta aqui de manera ilicita
    if (_uid == null) {
      dialogo(
          "Error",
          "Violacion de seguridad, usted no deberia estar en esta sección",
          context);
      //await BD.bd.limipiar_perfil_local();
      //await FirebaseAuth.instance.signOut();
      //Navigator.pop(context, "violacion");
    }

    ///Pedimos las credenciales del usuario para verificar su autenticidad y se
    ///aplican validaciones
    List<String> _resp = await _dialogoInicioSesion(context);
    FocusScope.of(context).requestFocus(FocusNode());
    if (_resp[0] == "" && _resp[1] == "") {
      await dialogo("ERROR", "No ingresó E-mail ni contraseña", context);
      return 1;
    }

    if (_resp[0] == "") {
      await dialogo("ERROR", "No ingresó E-mail", context);
      return 1;
    }

    if (_resp[1] == "") {
      await dialogo("ERROR", "No ingresó contraseña", context);
      return 1;
    }

    if (!evaluar_email(_resp[0])) {
      await dialogo("ERROR", "Email no valido", context);
      return 1;
    }

    //Comprobamos si hay internet
    if (!await ConnectionVerify.connectionStatus()) {
      await dialogo_sin_internet(context);
      return 1;
    }

    ///Si las validaciones fueron correctas pasamos a iniciar sesión con las credenciales
    try {
      var _nuid = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _resp[0], password: _resp[1]);

      ///Si las credenciales obtenidas son distintas a las credenciales nuevas hay un posible
      ///intento de acceso ilicito.
      if (_nuid.user.uid != _uid) {
        await BD.bd.limipiar_perfil_local();
        await FirebaseAuth.instance.signOut();
        await dialogo(
            "Error",
            "Violacion de seguridad, usted no inció sesión con la misma cuenta con la que entró.",
            context);
        return 2;
      }

      ///si lo anterior no se cumple se respaldan los datos dados por el usuario
      _csAdmin = _resp[1];
      _mailAdmin = _resp[0];
    } catch (e) {
      ///Si ocurre un error de funcionamiento al iniciar sesion o de credenciales no
      ///validas (equivocacion al introducir sus datos) solo se retorna un error de
      ///funcionamiento
      await dialogo("ERROR", "al iniciar sesión", context);
      return 1;
    }

    //Comprobamos si hay internet nuevaamente
    if (!await ConnectionVerify.connectionStatus()) {
      await dialogo_sin_internet(context);
      return 1;
    }

    ///Intentamos crear la nueva cuenta de usuario
    /// "***creacion error": hubó un error al crear el nuevo usuario
    /// "***error": errores inherentes al funcionamiento de firestore o internet
    /// "": Creacion exitos
    String _resultado =
        await _crear_cuenta(_csAdmin, _mailAdmin, _misDatos.correo, context);
    if (_resultado == "***creacion error") {
      dialogo(
          "ERROR", "Hubó un error al crear la cuenta de conductor", context);
      return 1;
    }

    if (_resultado == "**error") {
      return 1;
    }

    ///Si cremaos exitosamente la cuenta hora subimos las fotos de perfil y credencial
    ///si surge error algún Borramos el perfil y retornamos eerror de funcionamiento
    Reference _referencia1 = FirebaseStorage.instance.ref(
            "fotos/conductores/${FirebaseAuth.instance.currentUser.uid}/perfil.jpg"),
        _referencia2 = FirebaseStorage.instance.ref(
            "fotos/conductores/${FirebaseAuth.instance.currentUser.uid}/credencial.jpg");
    try {
      await _referencia1.putFile(_ImagenSelfie);
      await _referencia2.putFile(_imagenCredencial);
      _misDatos.foto = await _referencia1.getDownloadURL();
    } catch (e) {
      await FirebaseAuth.instance.currentUser.delete();
      return 1;
    }

    ///Si todo salió bien, creamos el perfil de usuario en firestore
    if (await _crear_perfil_conductor_firestore(
            _misDatos, FirebaseAuth.instance.currentUser.uid) ==
        null) {
      await FirebaseAuth.instance.currentUser.delete();
      dialogo(
          "ERROR", "Hubó un error al crear el perfil de conductor", context);
      return 1;
    }

    ///Si creamos el perfil con exito, solo volvemos a iniciar sesion con las credenciales del
    ///administrador y retornamos el valor de exito
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _mailAdmin, password: _csAdmin);
    return 3;
  }

  Future<Perfil_conductor_M> _crear_perfil_conductor_firestore(
      Perfil_conductor_M _misDatos, String _uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("conductores")
          .doc(_uid)
          .set(_misDatos.toJson());
    } catch (e) {
      return null;
    }
    return _misDatos;
  }

  Future<List<String>> _dialogoInicioSesion(BuildContext context) async {
    Size s = MediaQuery.of(context).size;
    String _mail = "", _cs = "";
    bool _respuesta = false;
    final formKey = GlobalKey<FormState>();
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        scrollable: true,
        title: const Text("INICIE SESIÓN", textAlign: TextAlign.center),
        content: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Para continuar inicie sesión nuevamente con su cuenta de administrador",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    width: s.width * .6,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: _mail,
                      decoration: const InputDecoration(
                        //icon: Icon(Icons.person, color: Colors.green[800]),
                        labelText: 'Email:',
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      onSaved: (_ap) => _mail = _ap,
                      validator: (_email) {
                        return null;
                      },
                    )),
                SizedBox(
                    width: s.width * .6,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: "",
                      obscureText: true,
                      decoration: const InputDecoration(
                        //icon: Icon(Icons.person, color: Colors.green[800]),
                        labelText: 'Contraseña:',
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      onSaved: (_constrasena) => _cs = _constrasena,
                      validator: null,
                    )),
              ],
            )),
        actions: [
          OutlineButton(
              shape: const StadiumBorder(),
              onPressed: () {
                formKey.currentState.save();
                Navigator.pop(context);
              },
              child: const Text('Continuar')),
        ],
      ),
    );

    return [_mail, _cs];
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
}
