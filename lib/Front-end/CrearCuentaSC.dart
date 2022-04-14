import 'package:flutter/material.dart';

class CrearCuentaSC extends StatefulWidget {
  CrearCuentaSC();
  @override
  _CrearCuentaSCState createState() => _CrearCuentaSCState();
}

class _CrearCuentaSCState extends State<CrearCuentaSC> {
  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        actions: [],
      ),
      body: Container(
        width: s.width,
        height: s.height,
      ),
    );
  }
}
