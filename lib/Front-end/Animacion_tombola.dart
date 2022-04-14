// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';

class Animacion_tombola extends StatefulWidget {
  Animacion_tombola({Key key}) : super(key: key);
  @override
  _Animacion_tombolaState createState() => _Animacion_tombolaState();
}

class _Animacion_tombolaState extends State<Animacion_tombola>
    with SingleTickerProviderStateMixin {
  List<bool> _seleccion = [false, false, false];
  List<String> _resultados_tombola = [];
  String _estadisticas_tombola = "";
  int _duracion_animacion = 10;
  double _rotacion = 0, _suma_valores = 0;
  int _eleccion = 1, _resultado_tombola;
  bool _salir_pantalla = false, _tombola_iniciada = false;

  AnimationController animationController;
  Widget _imagen1 = Image.asset(
        "assets/logos/ride.png",
        width: 60,
      ),
      _imagen2 = Image.asset("assets/logos/tombola_desc.png"),
      _imagen3 = Image.asset("assets/logos/tombola_10.png");
  @override
  void initState() {
    //super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    animationController.addListener(() {
      _suma_valores += animationController.value;
      print(animationController.value);
      if (animationController.value < .25) {
        _rotacion += (1 - animationController.value) * Random().nextInt(5) + 5;
      } else if (animationController.value < .4) {
        _rotacion +=
            (1 - animationController.value) * (Random().nextInt(5)) + 3;
      } else if (animationController.value < .5) {
        _rotacion +=
            (1 - animationController.value) * (Random().nextInt(3)) + 2;
      } else if (animationController.value < .6) {
        _rotacion +=
            (1 - animationController.value) * (Random().nextInt(3)) + 1;
      } else if (animationController.value < .7) {
        _rotacion +=
            (1 - animationController.value) * (Random().nextInt(2)) + 1;
      } else if (animationController.value < .8) {
        _rotacion += (1 - animationController.value);
      } else if (animationController.value < .9) {
        _rotacion += (1 - animationController.value) * .5;
      } else {
        _rotacion += (1 - animationController.value) * .25;
      }

      setState(() {});
    });
  }

  Size s;
  StreamController<int> selected = StreamController<int>();

  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;

    Future<bool> _onWillPop() async {
      if (!_salir_pantalla) {
        await Funciones().dialogo("ACTIVAR TOMBOLA",
            "PARA CONTINUAR REQUIERE ACTIVAR LA TOMBOLA", context);
        return false;
      }
      Navigator.pop(context, _estado_tombola());
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: BounceInDown(
          duration: Duration(milliseconds: 1500),
          from: s.height,
          child: Container(
            width: s.width,
            height: s.height,
            decoration: _fondo(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _texto_tombola(),
                _rueda_giratoria(),
                _resultado_tombola_imagen(),
                _boton_regresar(),
                /*Container(
              padding: EdgeInsets.only(top: s.width * .1),
              alignment: Alignment.bottomCenter,
              child: Text(
                  "azul: $eleccion1  purpura:$eleccion3  ambar:$eleccion2\nrep: ${eleccion1 + eleccion2 + eleccion3}"),
            )*/
              ],
            ),
          ),
        )));
  }

  Widget _rueda(Size size, double index, String _texto, Color _color) {
    var _angle = 2 * pi / 3;
    double _rotacion_individual = _rotacion;
    for (int i = 0; i < index; i++) {
      _rotacion_individual += _angle = 2 * pi / 3;
    }
    return Transform.rotate(
        angle: _rotacion_individual,
        child: ClipPath(
          clipper: _LuckPath(_angle),
          child: Container(
            height: size.height / 2,
            width: size.height / 2,
            color: _color,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: s.height / 4, width: s.width / 4),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(index == 1
                            ? "assets/logos/tombola_gratis.png"
                            : index == 2
                                ? "assets/logos/tombola_desc.png"
                                : "assets/logos/tombola_10.png"),
                        filterQuality: FilterQuality.medium,
                        fit: BoxFit.contain)),
              ),
            ),
          ),
        ));
  }

  BoxDecoration _fondo() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 4)
      ],
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.green[50],
            Colors.green[100],
            Colors.green[200],
            Colors.green[300],
            Colors.green[400],
          ]),
    );
  }

  Widget _texto_tombola() {
    return Padding(
      padding: EdgeInsets.only(top: s.height * .05),
      child: Text.rich(TextSpan(children: [
        TextSpan(
          text: "TOMBOLA",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w400, fontSize: 25),
        ),
        TextSpan(
          text: " MotoRide",
          style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
              fontSize: 28),
        )
      ])),
    );
  }

  Widget _resultado_tombola_imagen() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 20),
      width: s.width * .3,
      height: s.width * .3,
      decoration: BoxDecoration(
          color: !_tombola_iniciada
              ? Colors.white
              : _estado_tombola() == 1
                  ? Colors.blue[50]
                  : _estado_tombola() == 2
                      ? Colors.amber[50]
                      : Colors.purple[50],
          shape: BoxShape.circle,
          image: DecorationImage(
              image: AssetImage(!_tombola_iniciada
                  ? "assets/logos/INSTRUCCIONES_TOMBOLA.png"
                  : _estado_tombola() == 1
                      ? "assets/logos/tombola_gratis.png"
                      : _estado_tombola() == 2
                          ? "assets/logos/tombola_desc.png"
                          : "assets/logos/tombola_10.png"),
              filterQuality: FilterQuality.medium,
              fit: BoxFit.contain),
          boxShadow: [
            BoxShadow(
                color: !_tombola_iniciada
                    ? Colors.green[900]
                    : _estado_tombola() == 1
                        ? Colors.blue
                        : _estado_tombola() == 2
                            ? Colors.amber
                            : Colors.purple,
                spreadRadius: 1,
                blurRadius: 15)
          ]),
    );
  }

  Widget _rueda_giratoria() {
    return Container(
      width: s.height / 2,
      height: s.height / 2,
      margin: EdgeInsets.all(s.width * .05),
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: Colors.black38, spreadRadius: 5, blurRadius: 15)
      ]),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          _rueda(s, 1, "gratis", Colors.blue[300]),
          _rueda(s, 2, "50", Colors.amber[300]),
          _rueda(s, 3, "10", Colors.purple[300]),
          Container(
            padding: EdgeInsets.only(bottom: s.width * .1),
            width: s.height / 2,
            height: s.height / 2,
            child: Center(
                child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                color: Colors.amber[900],
                height: s.width * .25,
                width: 20,
              ),
            )),
          ),
          Container(
            width: s.height / 2,
            height: s.height / 2,
            child: Center(
                child: GestureDetector(
              onTap: () async {
                //se activa la variable que indicara que el resultado visual se muestre debajo de la tombola
                _tombola_iniciada = true;
                //Al ser pulsado gestiona la animacion, solo se activa si la animacion no esta en curso y si el resultado no se ha dado ya
                if (!animationController.isAnimating && !_salir_pantalla) {
                  //se ajusta a cero la rotacion
                  _rotacion = 0;

                  //se activa la animacion, agregamos un await para que las siguientes lineas no se ejecuten hasta que
                  //la animacion termine.
                  await animationController
                      .forward(
                    from: 0.0,
                  )
                      .then((_) {
                    //una vez termina se llama al a funcion que calculca el resultado de acuerdo a la rotacion final
                    _eleccion = _estado_tombola();
                  });

                  //este blo que es para asegurarno de que la animacion no termine justo en el centro de dos opciones y/o
                  //por si no es casi visible cual es la opcion en la que cayó sea ligeramente mas visible, ademas de agregar
                  //cierto factor aleatorio final
                  if ((_rotacion % (2 * pi)) > 5.2 &&
                      (_rotacion % (2 * pi)) < 5.3) {
                    _rotacion = 5.3;
                  } else if ((_rotacion % (2 * pi)) < 1.1 &&
                      (_rotacion % (2 * pi)) > 1) {
                    _rotacion = 1.1;
                  } else if ((_rotacion % (2 * pi)) > 3.1 &&
                      (_rotacion % (2 * pi)) < 3.2) {
                    _rotacion = 3.2;
                  }
                  _rotacion = (_rotacion % (2 * pi));
                }

                //cuando el proceso de la tombola temrina esta variable activa el boton para volver a la pantalla del mapa con el resultado
                _salir_pantalla = true;
              },
              child: Container(
                width: s.width * .19,
                height: s.width * .19,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber[900], width: 3),
                    shape: BoxShape.circle,
                    color: Colors.amber[600],
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38, spreadRadius: 1, blurRadius: 3)
                    ]),
                child: Text(
                  "INICIAR",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _boton_regresar() {
    if (_salir_pantalla) {
      return Padding(
        padding: EdgeInsets.only(top: s.height * .01),
        child: ElevatedButton(
          child: Text(
            "APLICAR RESULTADO",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.yellow[900];
                } else {
                  return Colors.green[900];
                }
              },
            ),
          ),
          onPressed: () {
            //al ser presionado retorna a la pantalla del mapa el resultado de la tombola
            Navigator.pop(context, _estado_tombola());
          },
        ),
      );
    } else {
      return Funciones().invisible();
    }
  }

  int _estado_tombola() {
    if (_rotacion % (2 * pi) > 1.1 && _rotacion % (2 * pi) < 3.11) {
      return 2;
    } else if (_rotacion % (2 * pi) < 1.1 || _rotacion % (2 * pi) > 5.25) {
      return 3;
    } else if (_rotacion % (2 * pi) > 3.15 && _rotacion % (2 * pi) < 5.25) {
      return 1;
    }
    return 0;
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, 0);
    //path.lineTo(0, size.height - 1);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
