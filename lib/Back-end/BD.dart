// ignore_for_file: unnecessary_new

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Mi_Perfil_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_solicitud_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_viaje.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Tarifas_M.dart';
import 'package:sqflite/sqflite.dart';

class BD {
  /*
   BD es la clase que realiza las funciones de base de datos, 
   Hay funciones que hacen modificaciones a la base de datos local y a la base de datos en firestore.
    Normalmente encontrara una o mas funciones que hacen modificaciones a la base de datos local respecto a una clase especifica
    y seguidamente funciones para hacer modificaciones en la base de datos de firestore.
    Por ejemplo: 
    una funcion para guardar un error en la base de datos, 
    despues una funcion para eliminar un error de la base de datos local,
    despues una funcion para leer los errores de la base de datos local,
    despues una función para subir un error a firestore.
    El objetivo de este orden es que una vez encontremos una funcion que realice cambios 
    asociados a un objeto especifico, tener la certeza que todas las funciones asociadas a este objeto estan cerca de alli.
    
    Todos los metodos estan comentados, describiendo un resumen general del usode dicha funcion.
    La base de datros local Es SqLite, tiene algunas limitaciones respecto a MySql.
    -solo acepta variables: Text, String (tambien creo que se usa para guardar datos como imagenes), 
      Integer (int), Double. no acepta variables booleanas ni tinyint, etc.
  */
  BD._bd();
  static final BD bd = BD._bd();
  static Database _database;
  static final Funciones _f = new Funciones();

  Future<Database> get _databaseI async {
    if (_database != null) return _database;

    _database = await initDB(); // genera la BD si no existe
    return _database;
  }

  initDB() async {
    //initDB recupera la base de datos en el path indicado, si la base de datos no contiene nada se ejecuta la creacion de la
    //base de datos, si la base de datos si tiene informacion se retorna.
    Directory directorioDeDocumentos = await getApplicationDocumentsDirectory();
    final path = join(directorioDeDocumentos.path, 'LocDB.db');
    return await openDatabase(path, // abre la BD en el path indicado
        version: 1, // version de estructura de BD
        onOpen: (db) {}, // ultima accion a generar
        onCreate: (Database db, int version) async {
      // crea la BD si no existe

      //Estos son metodos raw, envian un comando en lenguaje Sql cada uno
      await db.execute("CREATE TABLE Error("
          "id INTEGER PRIMARY KEY,"
          "funcionID INTEGER,"
          "clase TEXT,"
          "mensaje TEXT,"
          "fecha TEXT,"
          "usuario TEXT,"
          "id_firestore TEXT,"
          "nota TEXT"
          " ) ");

      await db.execute('CREATE TABLE Perfil_conductor_M('
          'id INTEGER PRIMARY KEY,'
          'correo TEXT,'
          'uid TEXT,'
          'RFC TEXT,'
          'cs TEXT,'
          'CURP TEXT,'
          'foto TEXT,'
          'nombres TEXT,'
          'aP TEXT,'
          'aM TEXT,'
          'direccion TEXT,'
          'NLicencia TEXT,'
          'NTarje TEXT,'
          'tipo_perfil TEXT,'
          'cA INTEGER,'
          'viajes INTEGER,'
          'registro TEXT,'
          'sesion TEXT,'
          'telefono INTEGER,'
          'r1 INTEGER,'
          'r2 INTEGER,'
          'r3 INTEGER,'
          'r4 INTEGER,'
          'r5 INTEGER,'
          'r6 INTEGER,'
          'r7 INTEGER,'
          'r8 INTEGER,'
          'r9 INTEGER,'
          'r10 INTEGER)');

      await db.execute('CREATE TABLE viaje('
          'id INTEGER,'
          'viajes_chofer INTEGER,'
          'puntos_chofer INTEGER,'
          'puntos_v1 INTEGER,'
          'puntos_v2 INTEGER,'
          'puntos_v3 INTEGER,'
          'viajes_v1 INTEGER,'
          'viajes_v2 INTEGER,'
          'viajes_v3 INTEGER,'
          'estado_viaje1 INTEGER,'
          'estado_viaje2 INTEGER,'
          'estado_viaje3 INTEGER,'
          'pasajeros1 INTEGER,'
          'pasajeros2 INTEGER,'
          'pasajeros3 INTEGER,'
          'lat_chofer DOUBLE,'
          'lon_chofer DOUBLE,'
          'lat_origen1 DOUBLE,'
          'lon_origen1 DOUBLE,'
          'lat_destino1 DOUBLE,'
          'lon_destino1 DOUBLE,'
          'lat_origen2 DOUBLE,'
          'lon_origen2 DOUBLE,'
          'lat_destino2 DOUBLE,'
          'lon_destino2 DOUBLE,'
          'lat_origen3 DOUBLE,'
          'lon_origen3 DOUBLE,'
          'lat_destino3 DOUBLE,'
          'lon_destino3 DOUBLE,'
          'costo_v1 DOUBLE,'
          'costo_v2 DOUBLE,'
          'costo_v3 DOUBLE,'
          'uid_chofer TEXT,'
          'uid_v1 TEXT,'
          'uid_v2 TEXT,'
          'uid_v3 TEXT,'
          'vehiculo TEXT,'
          'placas TEXT,'
          'foto_chofer TEXT,'
          'foto_v1 TEXT,'
          'foto_v2 TEXT,'
          'foto_v3 TEXT,'
          'dir_origen1 TEXT,'
          'dir_destino1 TEXT,'
          'dir_origen2 TEXT,'
          'dir_destino2 TEXT,'
          'dir_origen3 TEXT,'
          'dir_destino3 TEXT,'
          'nombre_chofer TEXT,'
          'nombre_v1 TEXT,'
          'nombre_v2 TEXT,'
          'nombre_v3 TEXT,'
          'fecha1 TEXT,'
          'fecha2 TEXT,'
          'fecha3 TEXT)');
    });
  }

  Future<bool> limipiar_perfil_local() async {
    ///Borra los datos guardados en la base de datos local de la tabla
    ///que guarda eñperfil de usuario, si hay algun error imprime en consola el error y retirna falso
    ///si el provceso se realiza exitosamente retona verdadero
    Database _db = await _databaseI;
    List<Map<String, Object>> _resp;

    try {
      _resp = await _db.query("Perfil_conductor_M", orderBy: 'id DESC');
    } catch (e) {
      print("error al obtener la base de datos local $e");
      return false;
    }

    if (_resp == null || _resp.isEmpty) return true;

    List<Perfil_conductor_M> _perfiles;
    try {
      _perfiles = _resp.map((c) => Perfil_conductor_M.fromJson(c)).toList();
    } catch (e) {
      print(
          "error al convertir los perfiles locales a objetos Perfil_conductor_M $e");
      return false;
    }

    for (var i = 0; i < _perfiles.length; i++) {
      try {
        await _db
            .delete('Perfil_conductor_M', // elimina registro considerando id
                where: 'id=?',
                whereArgs: [_perfiles[i].id]);
      } catch (e) {
        print(
            "error al borrar el perfil ${i + 1} de la lista de perfiles guardalos locales $e");
        return false;
      }
    }

    return true;
  }

  Future<bool> _crear_perfil_local_interno(
      final Perfil_conductor_M _misDatos) async {
    Database _bd = await _databaseI;

    if (!await limipiar_perfil_local()) return false;

    try {
      await _bd.insert('Perfil_conductor_M', _misDatos.toJson());
    } catch (e) {
      print("error al guardar un perfil local $e");
      return false;
    }

    return true;
  }

  Future<Perfil_conductor_M> _recuperar_perfil_local_interno() async {
    Database _bd = await _databaseI;
    List<Map<String, Object>> _res;
    try {
      _res = await _bd.query('Perfil_conductor_M');
    } catch (e) {
      print("error al recuperar perfil local $e");
      return null;
    }

    if (_res.isEmpty) return null;
    return Perfil_conductor_M.fromJson(_res.first);
  }

  Future<bool> autenticar_con_usuario_y_contrasena(
      BuildContext context, String _user, String _password) async {
    //esta funcion realiza el inicio de sesion para validadr las acciones que requieran autenticacion
    //se revisa que el usuario ya haya iniciado sesion al menos una vez para usar sus datos
    //Si al autenticacion se realiza exitosamente retornará verdadero, si no retorna falso y guarda el error
    // si el correo o la contraseña estan vacios retona tambien falso

    FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null && _auth.currentUser.uid != null) return true;
    //verificar si el cliente ya ha indiciado sesion

    bool _error_op = false;

    if (_auth == null ||
        _auth.currentUser == null ||
        _auth.currentUser.uid == null) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: _user, password: _password);
      } catch (e) {
        _error_op = true;
      }

      return !_error_op;
    }
  }

  Future<Perfil_conductor_M> iniciar_sesion(
      String _correo, String _cs, BuildContext context) async {
    /// Algoritmo de inicio de sesión socio conductor. Determina si el usuario que inicia sesion es el mismo
    /// que tiene datos locales, que sea un perfil de conductor, valido y activo, ademas de descargar o crear un nuevo viaje.

    ///1)	 Autenticar con los datos recibidos. si ocurre algun error al autenticar retorna nulo
    FirebaseAuth _aut = FirebaseAuth.instance;
    try {
      await _aut.signInWithEmailAndPassword(email: _correo, password: _cs);
    } catch (e) {
      await Funciones().dialogo(
          "ERROR", "El usuario y/o contraseña son incorrectos.", context);
      return null;
    }

    if (_aut == null ||
        _aut.currentUser == null ||
        _aut.currentUser.uid == null) {
      await Funciones().dialogo(
          "ERROR", "El usuario y/o contraseña son incorrectos.", context);
      return null;
    }

    ///2)	Extraer datos locales:
    ///Verificar si:
    /// a) Hay datos en la base de datos local
    /// b) El usuario que esta iniciando sesión el el msimo que el de la base de datos local comparando el uid
    /// c) Verificar que el token de perfil sea el mismo que deben tener los conductores
    /// d-1) Verificar que se registró una última sesión (para evitar errore)
    /// d-2) Verificar que la ultima vez que se descargó el perfil a los sumo 1 hora
    /// Si alfuno de los casos anteriores no se cumple, se limpia la base de datos local y se camnia al valor
    /// de la variable _renovar_datos a verdadero

    Perfil_conductor_M _misDatos = await _recuperar_perfil_local_interno();
    if (_misDatos != null &&
        _misDatos.uid == _aut.currentUser.uid &&
        _misDatos.tipo_perfil == "G65I89#36.ñlo*Zgsfp960" &&
        _misDatos.sesion != null &&
        Funciones().compararFechaConHoy_minutos(_misDatos.sesion) < 60) {
      return _misDatos;
    }

    await limipiar_perfil_local();

    ///4)	Si _renovar_datos es verdadero entonces se intenta obtener datos de firestore con el uid nuevo.
    ///Si no hay éxito retornar valor nulo y avisar de error.
    _misDatos = await _descargar_perfil_conductor_firestore(context);
    if (_misDatos == null) {
      await Funciones().dialogo(
          "ERROR",
          "Hubo un problema al obtener su perfil, revise sus datos y su conexión a internet.",
          context);
      return null;
    }

    /// Si el nuevo perfil no tiene el token correcto se retorna un aviso de irregularidad porque es
    /// un posible intento de fraude, retornamos nulo si lo detectamos
    if (_misDatos.tipo_perfil != "G65I89#36.ñlo*Zgsfp960") {
      await _f.dialogo(
          "HUBO UN PROBLEMA",
          "Se ha detectado una irregularidad con su perfil, no es posible continuar.",
          context);
      return null;
    }

    ///Si llegamos hasta aqui entonces guardamos los datos en la base de datos local
    await _crear_perfil_local_interno(_misDatos);

    return _misDatos;
  }

  Future<Perfil_conductor_M> _descargar_perfil_conductor_firestore(
      BuildContext context) async {
    ///Esta funcion descarga el perfil de firestore, si no existe el uid o hay algun problema se retona nulo.
    final _aut = FirebaseAuth.instance;
    if (_aut == null ||
        _aut.currentUser == null ||
        _aut.currentUser.uid == null) {
      await Funciones().dialogo("ERROR", "No ha iniciado sesión.", context);
      return null;
    }
    if (!await ConnectionVerify.connectionStatus()) {
      return null;
    }
    try {
      final _datos = await FirebaseFirestore.instance
          .collection("conductores")
          .doc(_aut.currentUser.uid)
          .get();
      Perfil_conductor_M _misDatos = Perfil_conductor_M.fromJson(_datos.data());
      _misDatos.uid = _datos.id;
      _misDatos.sesion = DateTime.now().toString();
      return _misDatos;
    } catch (e) {
      await _aut.signOut();

      return null;
    }
  }

  Future<Perfil_conductor_M> obtener_misDatos(
      BuildContext context, String _user, String _cs, Position _gps) async {
    ///Esta funcion obtiene los datos de firestore del perfil de conductor de un
    ///socio. si existe algun problema al realizar las operaciones se retorna un
    ///valor nulo y en algunos casos un dialogo de notificación.

    //recupera el perfil guardado en la bas de datos local si es que lo hay
    final Perfil_conductor_M _miPerfil =
        await _recuperar_perfil_local_interno();

    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return null;
    }

    //Se utiliza el usuario y contraseña para autenticar.
    if (!await autenticar_con_usuario_y_contrasena(context, _user, _cs)) {
      await _f.dialogo(
          "Error de inicio de sesión",
          "Hay un problema con los datos de inicio de sesión que ingresó, revise su correo y contraseña.",
          context);
      print(
          "hubo un problea al autenticar en la funcion obtener_misDatos_firestore() en la clase base de datos");
      return null;
    }

    //si la autenticacion es exitosa, se compara la contrseña y correo gardadados en los datos locales para
    //verificar que es el mismo usuario que la ultima vez se conectó.
    //ademas se verifica la fecha de la ultima actualizacion del perfil
    if (_miPerfil != null &&
        _miPerfil.sesion != null &&
        Funciones().compararFechaConHoy_minutos(_miPerfil.sesion) < 60 &&
        _miPerfil.tipo_perfil == "G65I89#36.ñlo*Zgsfp96" &&
        _miPerfil.cs == _cs &&
        _miPerfil.correo == _user) return _miPerfil;

    //si los anterior no funciona pasadmos a limpiar la base de datos local y descargar el perfll del usuario en firestore
    await limipiar_perfil_local();
    final _uid = FirebaseAuth.instance.currentUser.uid;
    Perfil_conductor_M _misDatos;
    try {
      final _resp = await FirebaseFirestore.instance
          .collection("conductores")
          .doc(_uid)
          .get();
      print("datos descargados resp ${_resp.data()}");
      _misDatos = Perfil_conductor_M.fromJson(_resp.data());
      _misDatos.uid = _resp.id;
      _misDatos.sesion =
          DateTime.now().subtract(const Duration(microseconds: 1)).toString();
    } catch (e) {
      print(
          "Hubo un error al obtener los datos de firestore, funcion obtener_misDatos_firestore() en la clase base de datos, error:\n$e");
      return null;
    }

    print("datos descargados ${_misDatos.id} $_uid");
    if (_misDatos == null || _misDatos.cs != _cs) {
      await _f.dialogo("HUBO UN PROBLEMA",
          "revise su informacion de inicio de sesión.", context);
      return null;
    }

    if (_misDatos.tipo_perfil != "G65I89#36.ñlo*Zgsfp960") {
      await _f.dialogo(
          "HUBO UN PROBLEMA",
          "Se ha detectado una irregularidad con su perfil, no es posible continuar.",
          context);
      return null;
    }

    try {
      _misDatos.cs = _cs;
      await _crear_perfil_local_interno(_misDatos);
    } catch (e) {
      await _f.dialogo("error al crear el perfil local", "$e", context);
    }

    if (!(await recueperar_viaje(_misDatos, _gps, context) == null))
      return null;

    return _misDatos;
  }

  Future<Reg_viaje> recueperar_viaje(
      Perfil_conductor_M _misDatos, Position _gps, BuildContext context) async {
    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return null;
    }

    //verificar si ya hay un viaje existente en firestore
    Reg_viaje _viaje;
    try {
      final _resp = await FirebaseFirestore.instance
          .collection("viajes")
          .doc(_misDatos.uid)
          .get();
      if (_resp.exists && _resp.data().isNotEmpty) {
        _viaje = Reg_viaje.fromJson(_resp.data());
      }
    } catch (e) {}
    //si ya hay un viaje devuelve ese viaje
    if (_viaje != null) {
      return _viaje;
    }

    _viaje = await _crear_viaje(_misDatos, _gps);
    if (_viaje == null) {
      await _f.dialogo(
          "ERROR",
          "Tuvimos un problema al recuperar los datos de su viaje, por favor intente mas tarde.",
          context);
      return null;
    }

    return _viaje;
    //si no, entonces crea un viaje
  }

  Future<Reg_viaje> _crear_viaje(
      Perfil_conductor_M _misDatos, Position _gps) async {
    ///esta funcion privada crea un viaje ( es decir, un chofer disponible para aceptar viajes)
    ///si existe algun problema retoan falso.
    final Reg_viaje _viajeActual = new Reg_viaje(
      viajes_chofer: (_misDatos.viajes != null && _misDatos.viajes < 1)
          ? 1
          : _misDatos.viajes,
      puntos_chofer:
          (_misDatos.cA != null && _misDatos.cA < 5) ? 5 : _misDatos.cA,
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

    try {
      await FirebaseFirestore.instance
          .collection("viajes")
          .doc(_misDatos.uid)
          .set(_viajeActual.toJson());
    } catch (e) {
      return null;
    }
    return _viajeActual;
  }

  Future<bool> actulizar_viaje(Reg_viaje _miViaje, Perfil_conductor_M _misDatos,
      BuildContext context) async {
    if (!await _autenticar(_misDatos)) return false;
    try {
      await FirebaseFirestore.instance
          .collection("viajes")
          .doc(_misDatos.uid)
          .update(_miViaje.toJson());
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> agregar_solicitud_a_viaje(
      Reg_solicitud_viaje _solicitud,
      Reg_viaje _viaje,
      Perfil_conductor_M _misDatos,
      BuildContext context) async {
    //comprobacion de conecxion
    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return false;
    }

    //autenticacion
    if (!await _autenticar(_misDatos)) return false;
    _solicitud.uid_chofer = _misDatos.uid;
    try {
      await FirebaseFirestore.instance
          .collection("Manzanillo")
          .doc(_solicitud.id)
          .update(_solicitud.toJson());
    } catch (e) {
      print("error al aceptar la solicitud de viaje en firestore $e");
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection("viajes")
          .doc(_misDatos.uid)
          .update(_viaje.toJson());
    } catch (e) {
      print("error al actualizar el viaje $e");
      return false;
    }

    return true;
  }

  Future<List<Reg_solicitud_viaje>> recuperar_viajes_en_curso() async {
    final _aut = FirebaseAuth.instance;
    if (_aut == null ||
        _aut.currentUser == null ||
        _aut.currentUser.uid == null) return null;
    if (!await ConnectionVerify.connectionStatus()) return null;

    final _resp = await FirebaseFirestore.instance
        .collection("solicitudes_aceptadas_Manzanillo")
        .where("uid_chofer", isEqualTo: _aut.currentUser.uid)
        .where("rating_viajero", isNotEqualTo: null)
        .get();
    if (_resp.docs.isEmpty) return [];

    List<Reg_solicitud_viaje> _viajes = [];
    _resp.docs.forEach((element) {
      var _v = Reg_solicitud_viaje.fromJson(element.data());
      _v.id = element.id;
      _viajes.add(_v);
    });
    _viajes.sort((a, b) => Funciones()
        .compararFechaConHoy_minutos(a.fecha)
        .compareTo(Funciones().compararFechaConHoy_minutos(b.fecha)));
    return _viajes;
  }

  Future<int> completar(BuildContext context) async {
    ///Esta función recibe los daatos necesarios para crear un perfil de socio conductor en firestore:
    ///1) recibe los datos
    ///2) los valida
    ///3) si existe algun error en algun paso envia el paso donde sucedió el error
    ///valores de retorno:
    ///0 - sin internet
    ///1 - datos invalidos
    ///2 - problema al crear autenticacion
    ///3 - error al obtener la credencial de usuario
    ///4 - error al crear el perfil de usuario en firestore
    ///5 - proceso exitoso

    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return 0;
    }

    String _uid = FirebaseAuth.instance.currentUser.uid;

    final Perfil_conductor_M _misDatos =
        await _recuperar_perfil_local_interno();

    if (_misDatos == null) {
      await _f.dialogo(
          "ERROR",
          "Por favor comuníquese al correo XXXXXX@gmail.com para darle soporte de como resolver su problema",
          context);
      return 4;
    }

    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return 0;
    }

    try {
      await FirebaseFirestore.instance
          .collection("conductores")
          .doc(_misDatos.uid)
          .set(_misDatos.toJson());
    } catch (e) {
      print("Error de paso 4 $e");
      await _f.dialogo(
          "ERRROR AL CREAR SU PERFIL DE CONDUCTOR",
          "Hubo un error al crear su perfil de socio conductor. Espere un par de minutos y utilice este botón para intentar nuevamente crear su perfil.",
          context);
      return 4;
    }

    return 5;
  }

  Future<bool> _autenticar(Perfil_conductor_M _misDatos) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth != null &&
        _auth.currentUser != null &&
        _auth.currentUser.uid != null) return true;
    if (!await ConnectionVerify.connectionStatus()) return false;
    try {
      await _auth.signInWithEmailAndPassword(
          email: _misDatos.correo, password: _misDatos.cs);
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<Perfil_conductor_M> inicio_rapido() async {
    Perfil_conductor_M _misDatos;
    DocumentSnapshot<Map<String, dynamic>> _doc;
    try {
      _misDatos = await _recuperar_perfil_local_interno();
    } catch (e) {
      return null;
    }

    if (_misDatos == null || _misDatos.cs == null || _misDatos.correo == null) {
      return null;
    }

    if (!await _autenticar(_misDatos)) return null;

    try {
      _doc = await FirebaseFirestore.instance
          .collection("conductores")
          .doc(_misDatos.uid)
          .get();
    } catch (e) {
      return null;
    }
    final _cs = _misDatos.cs;
    try {
      _misDatos = Perfil_conductor_M.fromJson(_doc.data());
      _misDatos.cs = _cs;
      _crear_perfil_local_interno(_misDatos);
    } catch (e) {
      return null;
    }

    return _misDatos;
  }

  Future<bool> aceptar_solicitud_viaje(Reg_solicitud_viaje _solicitud,
      Perfil_conductor_M _misDatos, BuildContext context) async {
    if (!await _autenticar(_misDatos)) {
      await _f.dialogo("Problema de autenticacion",
          "no fue posible autenticarlo como usuario registrado", context);
      return false;
    }

    ///agrego la uid del chofer para ceptar el viaje
    _solicitud.uid_chofer = _misDatos.uid;

    ///veerifico que la ubicacion del chofer no sea nula
  }

  Future<Tarifas_M> obtener_tarifas(BuildContext context) async {
    if (!await ConnectionVerify.connectionStatus()) {
      await _f.dialogo_sin_internet(context);
      return null;
    }
    Tarifas_M _tarifas;
    try {
      final _res =
          await FirebaseFirestore.instance.collection("tarifas").doc("1").get();
      _tarifas = Tarifas_M.fromJson(_res.data());
    } catch (e) {
      await _f.dialogo(
          "HUBO UN PROBELMA",
          "Tuvimos un problema al obtener la información necesaria para iniciar el viaje.",
          context);
      return null;
    }

    return _tarifas;
  }

  Future<bool> agregar_cargo_a_viajero(
      String _id, double _cargo, int _raite) async {
    if (_id == null || _id == "" || _cargo == null) return false;
    if (!await ConnectionVerify.connectionStatus()) return false;
    Mi_Perfil_M _perfil;
    try {
      final _res = await FirebaseFirestore.instance
          .collection("viajeros")
          .doc(_id)
          .get();
      _perfil = Mi_Perfil_M.fromJson(_res.data());
    } catch (e) {
      print("error al descargar el perfil del viajero $e");
      return false;
    }

    _perfil.pago_adeudo += _cargo;
    _perfil.id_conductor = null;
    _perfil.raites += _raite;

    try {
      await FirebaseFirestore.instance
          .collection("viajeros")
          .doc(_id)
          .update(_perfil.toJson());
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<Mi_Perfil_M> obtener_perfil_viajero(String _id) async {
    Mi_Perfil_M _perfil_viajero;
    try {
      final _resp = await FirebaseFirestore.instance
          .collection("viajeros")
          .doc(_id)
          .get();
      if (_resp != null &&
          _resp.exists &&
          _resp.data() != null &&
          _resp.data().isNotEmpty) {
        _perfil_viajero = Mi_Perfil_M.fromJson(_resp.data());
        _perfil_viajero.id_firestore = _resp.id;
      }
    } catch (e) {
      return null;
    }
    return _perfil_viajero;
  }

  Future<bool> _actualizar_viaje_firestore(Reg_viaje _viaje) async {
    try {
      await FirebaseFirestore.instance
          .collection("viajes")
          .doc(_viaje.uid_chofer)
          .update(_viaje.toJson());
    } catch (e) {
      print("error al actualizar el viaje en firestore $e");
      return false;
    }

    return true;
  }

  Future<Reg_viaje> concluir_viaje(int _num_viaje, Reg_viaje _viaje) async {
    if (_num_viaje == null ||
        _num_viaje < 0 ||
        _num_viaje > 3 ||
        _viaje == null ||
        !await ConnectionVerify.connectionStatus()) return null;
    var _v = _f.clonar_viaje(_viaje);
    _v = _f.eliminar_un_viajero(_num_viaje, _viaje);
    await Future.delayed(Duration(seconds: 2));
    if (!await _actualizar_viaje_firestore(_v)) return null;
    return _v;
  }

  Reg_viaje _cambiar_viaje(int _num_viaje, Reg_viaje _viaje) {
    if (_num_viaje == 1) {
      _viaje.estado_viaje1 = 0;
      _viaje.uid_v1 = "";
      _viaje.puntos_v1 = 0;
      _viaje.viajes_v1 = 0;
      _viaje.lat_origen1 = 0;
      _viaje.lat_destino1 = 0;
      _viaje.costo_v1 = 0;
      _viaje.dir_origen1 = "";
      _viaje.dir_destino1 = "";
      _viaje.nombre_v1 = "";
      _viaje.fecha1 = "";
    } else if (_num_viaje == 2) {
      _viaje.estado_viaje2 = 0;
      _viaje.uid_v2 = "";
      _viaje.puntos_v2 = 0;
      _viaje.viajes_v2 = 0;
      _viaje.lat_origen2 = 0;
      _viaje.lat_destino2 = 0;
      _viaje.costo_v2 = 0;
      _viaje.dir_origen2 = "";
      _viaje.dir_destino2 = "";
      _viaje.nombre_v2 = "";
      _viaje.fecha2 = "";
    } else if (_num_viaje == 3) {
      _viaje.estado_viaje3 = 0;
      _viaje.uid_v3 = "";
      _viaje.puntos_v3 = 0;
      _viaje.viajes_v3 = 0;
      _viaje.lat_origen3 = 0;
      _viaje.lat_destino3 = 0;
      _viaje.costo_v3 = 0;
      _viaje.dir_origen3 = "";
      _viaje.dir_destino3 = "";
      _viaje.nombre_v3 = "";
      _viaje.fecha3 = "";
    }

    return _viaje;
  }
}
