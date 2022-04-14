import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';
import 'package:socio_conductor/Back-end/Modelos_base_datos/Reg_viaje.dart';
import 'package:socio_conductor/Front-end/PaginaAdministrador.dart';

class PAgina_opciones extends StatefulWidget {
  PAgina_opciones(this._miViaje);
  Reg_viaje _miViaje;
  @override
  _PAgina_opcionesState createState() => _PAgina_opcionesState();
}

class _PAgina_opcionesState extends State<PAgina_opciones> {
  Funciones _f = Funciones();
  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('OPCIONES'),
        centerTitle: true,
        actions: [],
      ),
      body: Container(
        width: s.width,
        height: s.height,
        child: ListView(
          children: [
            SizedBox(
              height: s.height * .025,
            ),
            Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(
                                        color: Colors.green, width: 4)))),
                    onPressed: () async {
                      if (widget._miViaje.estado_viaje1 != 0 ||
                          widget._miViaje.estado_viaje2 != 0 ||
                          widget._miViaje.estado_viaje3 != 0) {
                        await _f.dialogo(
                            "NO ES POSIBLE CERRAR SESIÓN",
                            "Usted tiene uno o más viajes activos, para cerrar sesión es necesario que finalice todos los viajes activos.",
                            context);
                        return;
                      }
                      if (!await ConnectionVerify.connectionStatus()) {
                        _f.dialogo_sin_internet(context);
                        return;
                      }
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context, "cerrar");
                    },
                    child: const Text("\nCERRAR SESIÓN\n"))),
          ],
        ),
      ),
    );
  }
}
