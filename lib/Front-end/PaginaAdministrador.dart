// ignore_for_file: unnecessary_string_interpolations

import 'dart:io';
import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socio_conductor/Back-end/FuncionesAdministrador.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Perfil_conductor_M.dart';

class PaginaAdministrador extends StatefulWidget {
  PaginaAdministrador();

  @override
  State<PaginaAdministrador> createState() => _PaginaAdministradorState();
}

class _PaginaAdministradorState extends State<PaginaAdministrador> {
  Size s;
  String _cs1, _cs2, _csAdmin, _maiAdmin;
  bool _pssw1 = true, _pssw2 = true, _cargando = false;
  final Perfil_conductor_M _misDatos = Perfil_conductor_M();
  final formKey = GlobalKey<FormState>();
  final FuncionesAdministrador _f = FuncionesAdministrador();
  final TextEditingController controlNom = TextEditingController(),
      controlAp = TextEditingController(),
      controlAm = TextEditingController(),
      controlmail = TextEditingController(),
      controlDir = TextEditingController(),
      controlLice = TextEditingController(),
      controlTarj = TextEditingController(),
      controlRFC = TextEditingController(),
      controlCURP = TextEditingController(),
      controlTel = TextEditingController();
  XFile _imagen_credencial, _imagen_selfie;
  final ImagePicker _picker = ImagePicker();
  String _path_credencial, _path_selfie;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null ||
        FirebaseAuth.instance.currentUser.uid == null) {
      Navigator.pop(context);
    }
    s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("ADMINISTRA ${FirebaseAuth.instance.currentUser.uid}"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.grey[300],
        width: s.width,
        height: s.height,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Stack(
              children: [_formulario(), _f.pantalla_carga_blurr(_cargando, s)],
            )
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    return Container(
      width: s.width,
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: s.height * .05),
      color: Colors.white,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: s.height * .025,
            ),
            const Text(
              "AGREGAR UN CONDUCTOR\n",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlNom,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    //icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Nombre(s):',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_nombres) => _misDatos.nombres = _nombres,
                  validator: _validar_nombres,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlAp,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    //icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Apellido paterno:',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_ap) => _misDatos.aP = _ap,
                  validator: _validar_nombres,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlAm,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Apellido materno:',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_am) => _misDatos.aM = _am,
                  validator: _validar_nombres,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlmail,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Email (Google):',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_mail) => _misDatos.correo = _mail,
                  validator: _validar_mail,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlTel,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Número telefónico (10 digitos):',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_tel) => _misDatos.telefono = int.parse(_tel),
                  validator: _validar_telefono,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlDir,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Dirección:',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_dir) => _misDatos.direccion = _dir,
                  validator: _validar_cd,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlLice,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Licencia (Número):',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_lic) => _misDatos.NLicencia = _lic,
                  validator: _validarTarjetonLicencia,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlTarj,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'Targetón (Número):',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_tarje) => _misDatos.NTarje = _tarje,
                  validator: _validarTarjetonLicencia,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlRFC,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'RFC:',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_rfc) => _misDatos.RFC = _rfc,
                  validator: _validarRFC,
                )),
            SizedBox(
                width: s.width * .8,
                child: TextFormField(
                  controller: controlCURP,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.person, color: Colors.green[800]),
                    labelText: 'CURP:',
                    labelStyle: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  onSaved: (_curp) => _misDatos.CURP = _curp,
                  validator: _validarRFC,
                )),
            /*SizedBox(
                        width: s.width * 0.8,
                        child: TextFormField(
                          obscureText: _pssw1,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: !_pssw1
                                      ? Colors.red[900]
                                      : Colors.green[800],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pssw1 = !_pssw1;
                                  });
                                }),
                            labelText: 'Contraseña:',
                            helperText: 'Mínimo de 6 caracteres.',
                            labelStyle: const TextStyle(
                                color: Colors.black, fontSize: 17),
                          ),
                          validator: _validar_cs1,
                          onSaved: (cs1) {
                            _cs1 = cs1;
                          },
                        )),
                    SizedBox(
                        width: s.width * 0.8,
                        child: TextFormField(
                          obscureText: _pssw2,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: !_pssw2
                                      ? Colors.red[900]
                                      : Colors.green[800],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pssw2 = !_pssw2;
                                  });
                                }),
                            labelText: 'Repita la contraseña:',
                            labelStyle: const TextStyle(
                                color: Colors.black, fontSize: 17),
                          ),
                          validator: _validar_cs2,
                          onSaved: (cs2) {
                            _cs2 = cs2;
                          },
                        )),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(s.width * .05, s.height * .025,
                      s.width * .05, s.height * .025),
                  width: s.width * .35,
                  height: s.height * .12,
                  decoration: BoxDecoration(
                      color: _imagen_selfie == null
                          ? Colors.grey[200]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(s.width * .1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "FOTO DE\nUSUARIO",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(10),
                        icon: Icon(_imagen_selfie == null
                            ? Icons.camera_alt
                            : Icons.person),
                        onPressed: () async {
                          XFile _img;
                          try {
                            _img = await _picker.pickImage(
                                source: ImageSource.camera,
                                maxHeight: 600,
                                maxWidth: 800,
                                preferredCameraDevice: CameraDevice.rear,
                                imageQuality: 100);
                          } catch (e) {
                            // ignore: avoid_print
                            print("error $e");
                            return;
                          }

                          if (_img != null) {
                            _imagen_selfie = _img;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(s.width * .05, s.height * .025,
                      s.width * .05, s.height * .025),
                  width: s.width * .35,
                  height: s.height * .12,
                  decoration: BoxDecoration(
                      color: _imagen_credencial == null
                          ? Colors.grey[200]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(s.width * .1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "FOTO DE SU\nCREDENCIAL",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(15),
                        icon: Icon(_imagen_credencial == null
                            ? Icons.camera_alt
                            : Icons.credit_card),
                        onPressed: () async {
                          XFile _imgc;
                          try {
                            _imgc = await _picker.pickImage(
                                source: ImageSource.camera,
                                maxHeight: 900,
                                maxWidth: 900,
                                preferredCameraDevice: CameraDevice.rear,
                                imageQuality: 100);
                          } catch (e) {
                            return;
                          }

                          if (_imgc != null) {
                            _imagen_credencial = _imgc;
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_imagen_selfie != null)
                  SizedBox(
                    width: s.width * .35,
                    height: s.width * .35,
                    child: Image.file(File(_imagen_selfie.path)),
                  ),
                if (_imagen_credencial != null)
                  SizedBox(
                    width: s.width * .35,
                    height: s.width * .35,
                    child: Image.file(File(_imagen_credencial.path)),
                  ),
              ],
            ),
            SizedBox(
              height: s.height * .025,
            ),
            Center(
              child: ElevatedButton(
                child: const Text("AGREGAR CONDUCTOR"),
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
                onPressed: () async {
                  setState(() {
                    _cargando = true;
                  });
                  int _respuesta = await _validaciones();
                  if (_respuesta == 2) {
                    setState(() {
                      _cargando = false;
                    });
                    Navigator.pop(context, "salir");
                    return;
                  }
                  if (_respuesta == 1) {
                    setState(() {
                      _cargando = false;
                    });
                    return;
                  }

                  controlNom.clear();
                  controlAp.clear();
                  controlAm.clear();
                  controlmail.clear();
                  controlTel.clear();
                  controlDir.clear();
                  controlLice.clear();
                  controlTarj.clear();
                  controlRFC.clear();
                  controlCURP.clear();
                  _imagen_credencial = null;
                  _imagen_selfie = null;

                  await _f.dialogo(
                      "CREACION EXITOSA",
                      "El nuevo perfil de socio conductor fue creado exitosamente. Para que ${_misDatos.nombres} pueda iniciar sesión, utilice el correo ${_misDatos.correo} y la contraseña 'nuevoconductor', cuando el conductor inicie sesión por primera vez se le pedirá que cambie su contraseña por una nueva.",
                      context);

                  setState(() {
                    _cargando = false;
                  });
                },
              ),
            ),
            SizedBox(
              height: s.height * .025,
            )
          ],
        ),
      ),
    );
  }

  String _validar_nombres(String _nombre) {
    if (_nombre == null || _nombre == "") {
      return "Campo requerido";
    } else if (!_f.validarNombres(_nombre)) {
      return 'Nombre inválido';
    } else if (_nombre.length <= 2) {
      return 'Nombre muy corto';
    }

    return null;
  }

  String _validar_mail(String _mail) {
    if (_mail == null || _mail == "") {
      return "Campo requerido";
    } else if (!_f.evaluar_email(_mail)) {
      return 'Email no inválido';
    }

    return null;
  }

  String _validar_telefono(String _tel) {
    if (_tel == null || _tel == "") {
      return "Campo requerido";
    } else if (!_f.evaluar_telefono(_tel)) {
      return 'Número telefónico no inválido';
    }

    return null;
  }

  String _validar_cd(String _cd) {
    if (_cd == null || _cd == "") {
      return "Campo requerido";
    } else if (_cd.length < 10) {
      return 'Dirección muy corta';
    }

    return null;
  }

  String _validar_cs1(String _cs) {
    if (_cs == null || _cs == "") {
      return "Campo requerido";
    } else if (_cs.length < 6) {
      return 'Contraseña muy corta';
    }
    _cs1 = _cs;
    return null;
  }

  String _validar_cs2(String _cs) {
    if (_cs == null || _cs == "") {
      return "Campo requerido";
    } else if (_cs != _cs1) {
      return 'Las contraseñas no coinciden';
    }
    _cs2 = _cs;

    return null;
  }

  String _validarRFC(String _rfc) {
    return null;
    if (_f.verificar_RFC(_rfc)) {
      return null;
    } else {
      return "RFC no valido";
    }
  }

  String _validarCURP(String _curp) {
    return null;
    if (_f.validar_CURP(_curp)) {
      return null;
    } else {
      return "CURP no valido";
    }
  }

  String _validarTarjetonLicencia(String _tar) {
    if (_tar == null || _tar == "") {
      return "Campo requerido";
    }
    return null;
  }

  Future<int> _validaciones() async {
    if (!formKey.currentState.validate()) {
      _f.dialogo(
          "ERRORES EN SUS DATOS",
          "Hay errores en los datos, corríjalos y vuelva  intentarlo.",
          context);
      setState(() {});
      return 1;
    }

    if (_imagen_credencial == null) {
      _f.dialogo("ERRORES EN SUS DATOS",
          "No ha ingresado la imagen de la credencial del chofer.", context);
      setState(() {});
      return 1;
    }

    if (_imagen_credencial == null) {
      _f.dialogo("ERRORES EN SUS DATOS",
          "No ha ingresado la imagen de perfil del chofer.", context);
      setState(() {});
      return 1;
    }

    formKey.currentState.save();
    _misDatos.tipo_perfil = "G65I89#36.ñlo*Zgsfp960";
    _misDatos.cA = 0;
    _misDatos.viajes = 0;
    _misDatos.registro =
        DateTime.now().subtract(const Duration(microseconds: 1)).toString();
    _misDatos.sesion =
        DateTime.now().subtract(const Duration(microseconds: 1)).toString();
    _misDatos.r1 = 0;
    _misDatos.r2 = 0;
    _misDatos.r3 = 0;
    _misDatos.r4 = 0;
    _misDatos.r5 = 0;
    _misDatos.r6 = 0;
    _misDatos.r7 = 0;
    _misDatos.r8 = 0;
    _misDatos.r9 = 0;
    _misDatos.r10 = 0;
    return await _f.crearNuevoConductor(context, _misDatos,
        File(_imagen_selfie.path), File(_imagen_credencial.path));
  }
}
