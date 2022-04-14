import 'package:flutter/material.dart';

class Pagina_inicio extends StatefulWidget {
  Pagina_inicio();
  @override
  _Pagina_inicioState createState() => _Pagina_inicioState();
}

class _Pagina_inicioState extends State<Pagina_inicio> {
  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('SOCIO CONDUCTOR'),
          centerTitle: true,
          actions: [],
        ),
        body: Stack(
          children: [
            _fondo(s),
            Container(
              width: s.width,
              height: s.height,
              child: ListView(
                children: [
                  // _logo(s),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Material(
                        color: Colors.black,
                        child: InkWell(
                          splashColor: Colors.green[200].withOpacity(.4),
                          highlightColor: Colors.green[200].withOpacity(.4),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(10),
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
                                border: Border.all(
                                    color: Colors.white60, width: 4)),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _fondo(Size s) {
    return Container(
      width: s.width,
      height: s.height,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: .5),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 4)
          ],
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
    );
  }

  Widget _logo(Size s) {
    return Container(
      width: 150,
      height: 180,
      margin: EdgeInsets.only(
        bottom: s.width * .1,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/logos/logoExtendidoBlanco.png"),
            fit: BoxFit.contain),
        color: Colors.transparent,
      ),
      alignment: Alignment.center,
    );
  }
}
