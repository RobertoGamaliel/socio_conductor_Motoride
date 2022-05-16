// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CambioContrasena extends StatefulWidget {
  String _cs, _mail;
  CambioContrasena(this._cs, this._mail);
  @override
  _CambioContrasenaState createState() => _CambioContrasenaState();
}

class _CambioContrasenaState extends State<CambioContrasena> {
  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('CAMBIO DE CONTRASEÑA'),
        centerTitle: true,
        actions: [],
      ),
      body: Container(
        width: s.width,
        height: s.height,
        padding: EdgeInsets.fromLTRB(
            s.width * .025, s.height * .02, s.width * .025, s.height * .02),
        child: ListView(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "Cambio de contraseña requerido\n",
              style: TextStyle(
                  color: Color.fromARGB(255, 85, 15, 2),
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Text(
              "Usted esta usando una contraseña genérica, para asegurar la seguridad de su cuenta, solo podrá acceder al sistema una vez que actualice su contraseña.",
              style: TextStyle(
                  color: Color.fromARGB(255, 2, 62, 11),
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: s.height * .05,
            ),
            Container(
              width: s.width * .7,
              height: s.height * .07,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
              ),
            )
          ],
        ),
      ),
    );
  }
}
