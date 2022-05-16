import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socio_conductor/Back-end/Funciones.dart';

class Ciudades {
  int _n, _lado;
  Map<dynamic, dynamic> _ciudades;
  DateTime _fecha;
  Map<dynamic, dynamic> _cd = {
    "Manzanillo": {
      "maxLat": 19.18064377438938,
      "minLat": 18.996392081557282,
      "maxLon": -104.1809867,
      "minLon": -104.4323747,
      "pikUp1": 314635685
    },
    /* "Armeria": {
      "maxLat": 18.970489,
      "minLat": 18.925574,
      "maxLon": -103.9230326,
      "minLon": -103.9921037
    },
    "Tecoman": {
      "maxLat": 18.970489,
      "minLat": 18.859246,
      "maxLon": -103.8225957,
      "minLon": -103.9230327
    },
    "Guadalajara": {
      "maxLat": 20.869528,
      "minLat": 20.393750,
      "maxLon": -103.033229,
      "minLon": -103.677477
    },
    "Colima": {
      "maxLat": 19.324938,
      "minLat": 19.189646,
      "maxLon": -103.662784,
      "minLon": -103.818755
    },
    "Ensenada": {
      "maxLat": 31.93137218718552,
      "minLat": 31.6963986124058,
      "maxLon": -116.52358140796422,
      "minLon": -116.74437079578638
    },*/
  };

  Map<dynamic, dynamic> _limites = {
    "Manzanillo": {
      1: {
        "maxLat": 19.06072,
        "minLat": 19.03906,
        "maxLon": -104.29544,
        "minLon": -104.33467
      },
      2: {
        "maxLat": 19.07511,
        "minLat": 19.03906,
        "maxLon": -104.26874,
        "minLon": -104.29544
      },
      3: {
        "maxLat": 19.07249,
        "minLat": 19.03906,
        "maxLon": -104.21587,
        "minLon": -104.26874
      },
      4: {
        "maxLat": 19.03906,
        "minLat": 18.99793,
        "maxLon": -104.25656,
        "minLon": -104.33825
      },
      5: {
        "maxLat": 19.08728,
        "minLat": 19.06136,
        "maxLon": -104.29456,
        "minLon": -104.31194
      },
      6: {
        "maxLat": 19.10115,
        "minLat": 19.07479,
        "maxLon": -104.25766,
        "minLon": -104.29695
      },
      7: {
        "maxLat": 19.11486,
        "minLat": 19.08435,
        "maxLon": -104.29268,
        "minLon": -104.33538
      },
      8: {
        "maxLat": 19.14595,
        "minLat": 19.11486,
        "maxLon": -104.30646,
        "minLon": -104.32879
      },
      9: {
        "maxLat": 19.11486,
        "minLat": 19.08989,
        "maxLon": -104.33538,
        "minLon": -104.35691
      },
      10: {
        "maxLat": 19.14301,
        "minLat": 19.11486,
        "maxLon": -104.32879,
        "minLon": -104.37007
      },
      11: {
        "maxLat": 19.15929,
        "minLat": 19.08269,
        "maxLon": -104.37007,
        "minLon": -104.45856
      },
      12: {
        "maxLat": 19.13747,
        "minLat": 19.10115,
        "maxLon": -104.25236,
        "minLon": -104.29352
      },
      13: {
        "maxLat": 19.22346,
        "minLat": 19.14301,
        "maxLon": -104.32247,
        "minLon": -104.37007
      },
    },
    "Ensenada": {
      1: {
        "maxLat": 31.88921,
        "minLat": 31.85962,
        "maxLon": -116.64682,
        "minLon": -116.67604
      },
      2: {
        "maxLat": 31.90497,
        "minLat": 31.88289,
        "maxLon": -116.58066,
        "minLon": -116.64682
      },
      3: {
        "maxLat": 31.88289,
        "minLat": 31.85097,
        "maxLon": -116.60547,
        "minLon": -116.64682
      },
      4: {
        "maxLat": 31.88289,
        "minLat": 31.85097,
        "maxLon": -116.57914,
        "minLon": -116.60547
      },
      5: {
        "maxLat": 31.85097,
        "minLat": 31.79108,
        "maxLon": -116.57968,
        "minLon": -116.6237
      }
    },
    "Pachuca": {
      1: {
        "maxLat": 20.1722,
        "minLat": 20.12373,
        "maxLon": -98.77998,
        "minLon": -98.84134
      },
      2: {
        "maxLat": 20.1722,
        "minLat": 20.12373,
        "maxLon": -98.70123,
        "minLon": -98.84134
      },
      3: {
        "maxLat": 20.16167,
        "minLat": 20.1214,
        "maxLon": -98.64761,
        "minLon": -98.70123
      },
      4: {
        "maxLat": 20.1214,
        "minLat": 20.00815,
        "maxLon": -98.64761,
        "minLon": -98.70123
      },
      5: {
        "maxLat": 20.12373,
        "minLat": 20.0075,
        "maxLon": -98.70123,
        "minLon": -98.7612
      },
      6: {
        "maxLat": 20.12373,
        "minLat": 20.04629,
        "maxLon": -98.7612,
        "minLon": -98.85287
      },
      7: {
        "maxLat": 20.04629,
        "minLat": 19.95079,
        "maxLon": -98.7612,
        "minLon": -98.88407
      },
      8: {
        "maxLat": 20.1722,
        "minLat": 20.06274,
        "maxLon": -98.84134,
        "minLon": -98.94557
      },
    }
  };

  Ciudades(this._lado);

  List<double> consultaCordenadasCiudadActual(LatLng _pos) {
    String _ciudadActual = nombreCiudadActual(_pos);
    if (_ciudadActual == "") return [];
    return cordenadasCiudadActual(_ciudadActual);
  }

  List<List<double>> consultaSubCordenadas(LatLng _pos) {
    List<double> _lim = consultaCordenadasCiudadActual(_pos);
    return subIntervalos_cordenadas(_lim[0], _lim[1], _lim[2], _lim[3], _lado);
  }

  Map<dynamic, dynamic> consultaMapaSubIntervalos(LatLng _pos) {
    return mapaSubIntervalos(consultaSubCordenadas(_pos));
  }

  String consultaNumeroZona(LatLng _pos) {
    return numero_de_zona(_pos, mapaSubIntervalos(consultaSubCordenadas(_pos)));
  }

  List<int> consultaSecuencia(LatLng _pos) {
    return secuenciaDeEscaneo(int.parse(consultaNumeroZona(_pos)));
  }

  List<String> ciudades_disponibles() {
    ///retorna un arreglo de Strings con todas las ciudades
    ///en las que actualmente se da servicio
    if (_cd == null) return [];
    List<String> _citys = [];
    _cd.forEach((key, value) {
      _citys.add(key.toString());
    });
    return _citys;
  }

  String nombreCiudadActual(LatLng _pos) {
    ///Recibe las cordenadas del usuario, si se encuentra en el rango de una ciudad disponible
    ///retorna el nombre de la ciudad, de lo contrario retorna 'Fuera de rango'.
    ///En caso de tener probelmas con el acceso al objeto de las ciudades retona 'Sin ciudades activas'
    if (_cd == null) return "";
    String _city = "";

    try {
      _cd.forEach((key, value) {
        if (_pos.latitude >= value["minLat"] &&
            _pos.latitude <= value["maxLat"] &&
            _pos.longitude >= value["minLon"] &&
            _pos.longitude <= value["maxLon"]) {
          _city = key.toString();
          return;
        }
      });
    } catch (e) {
      return "";
    }

    return _city;
  }

  List<double> cordenadasCiudadActual(String _nombre) {
    ///Recibe un String con el nombre de una ciudad. Si la ciudad esta diponible
    ///retorna sus cordenadas de rango en una lista con los indices:
    ///index = 0: Latitud maxima
    ///index = 1: Latitud minima
    ///index = 2: Longitud maxima
    ///index = 3: Longitud minima
    ///Si la ciudad no se encuentra envia una lista vacia
    List<double> _cordenadas = [];
    try {
      _cd.forEach((key, value) {
        if (key == _nombre) {
          _cordenadas.add(value["maxLat"]);
          _cordenadas.add(value["minLat"]);
          _cordenadas.add(value["maxLon"]);
          _cordenadas.add(value["minLon"]);
          return;
        }
      });
    } catch (e) {
      print("error en  $e");
    }

    return _cordenadas;
  }

  String numero_de_zona(LatLng _pos, Map<dynamic, dynamic> _zonas) {
    ///Recibe un objeto Mapa con las diferentes zonas delimitadas de una ciudad y
    ///una posicion, determina si la posicion corresponde a una de las zonas delimitadas.
    ///Si pertenece a una, manda el numero de zona, si no manda una cadena vacia.
    if (_zonas == null || _zonas.isEmpty) return "";
    String _zo = "";
    _zonas["cordenadas"].forEach((key, value) {
      if (value["minLat"] <= _pos.latitude &&
          value["maxLat"] >= _pos.latitude &&
          value["maxLon"] >= _pos.longitude &&
          value["minLon"] <= _pos.longitude) {
        _zo += key.toString();
        return;
      }
    });
    return _zo;
  }

  Set<Polyline> limites_polylinea() {
    ///retorna un set de polylines que trazan los limites actuales de las ciudades
    ///almacenadas en la instancia del objeto
    Set<Polyline> _polys = Set();

    if (_cd == null) return _polys;

    try {
      _cd.forEach((key, value) {
        List<LatLng> _lineas = [];
        _lineas.add(LatLng(value["maxLat"], value["minLon"]));
        _lineas.add(LatLng(value["maxLat"], value["maxLon"]));
        _lineas.add(LatLng(value["minLat"], value["maxLon"]));
        _lineas.add(LatLng(value["minLat"], value["minLon"]));
        _lineas.add(LatLng(value["maxLat"], value["minLon"]));

        var _poly = Polyline(
          polylineId: PolylineId(key),
          points: _lineas,
          color: Color.fromARGB(78, 0, 0, 0),
          width: 5,
        );

        _polys.add(_poly);
      });
    } catch (e) {
      Set<Polyline> _p = Set();
      return _p;
    }

    return _polys;
  }

  Set<Polyline> polilynesSubZonas(Map<dynamic, dynamic> _zonas) {
    ///Recibe unobejto Map con las cordenadas de las diferentes
    ///sub-zonas y retorna un arraglo de polilynes que trzan la
    ///matriz de sub-zonas.
    ///Si recibe un objeto vacio o de configuracion incorrecta retorna un arreglo
    ///de polylines vacio.

    Set<Polyline> _trazado = Set();
    try {
      if (_zonas["cd"] == null) return _trazado;
    } catch (e) {
      print("Error polilynesSubZonas() $e");
      return _trazado;
    }

    Map<dynamic, dynamic> _subZonas;

    try {
      _subZonas = _zonas["cordenadas"];
    } catch (e) {
      return _trazado;
    }

    try {
      _subZonas.forEach((key, value) {
        List<double> _adre = [];

        _adre.add(value["maxLat"]);
        _adre.add(value["minLat"]);
        _adre.add(value["maxLon"]);
        _adre.add(value["minLon"]);

        _trazado.add(subZona_polyline(_adre, key));
      });
    } catch (e) {
      return Set();
    }

    return _trazado;
  }

  Polyline subZona_polyline(List<double> _cordenadas, String _id) {
    ///Recibe una lista con rangos de latitud y longitud de una zona rectangular y
    ///su identificador, normalmente será la zona a la que corresponde dicha sección.
    ///Retorna una polylinea para dibujar en Google maps.
    ///La lista debe tener la siguiente configuración:
    ///index = 0: Latitud máxima
    ///index = 1: Latitud mínima
    ///index = 2: Longitud máxima
    ///index = 3: Longitud mínima
    ///si se reciben valores inconsistentes retorna un polyline vacío.

    if (_cordenadas.length != 4) {
      return Polyline(
        polylineId: PolylineId(_id),
        points: [],
        color: Color.fromARGB(255, 5, 94, 167),
        width: 1,
      );
    }
    if (_cordenadas[0] == null ||
        _cordenadas[1] == null ||
        _cordenadas[2] == null ||
        _cordenadas[3] == null) {
      return Polyline(
        polylineId: PolylineId(_id),
        points: [],
        color: Colors.blue,
        width: 1,
      );
    }

    if (_cordenadas[0] < _cordenadas[1] || _cordenadas[2] < _cordenadas[3]) {
      return Polyline(
        polylineId: PolylineId(_id),
        points: [],
        color: Colors.blue,
        width: 1,
      );
    }

    List<LatLng> _lineas = [];
    _lineas.add(LatLng(_cordenadas[0], _cordenadas[3]));
    _lineas.add(LatLng(_cordenadas[0], _cordenadas[2]));
    _lineas.add(LatLng(_cordenadas[1], _cordenadas[2]));
    _lineas.add(LatLng(_cordenadas[1], _cordenadas[3]));
    _lineas.add(LatLng(_cordenadas[0], _cordenadas[3]));

    var _poly = Polyline(
      polylineId: PolylineId(_id),
      points: _lineas,
      color: Color.fromARGB(255, 70, 159, 231),
      width: 1,
    );

    return _poly;
  }

  List<Polyline> subAreas_polyline(Map<dynamic, dynamic> _ciudad) {
    ///recibe un obheto Map con las cordenadas de los intervalos y crea una lista
    ///de Polylines donse se almacenan y devuelven los polylines creados
    List<Polyline> _malla = [];
    if (_ciudad == null || _ciudad.isEmpty) {
      return _malla;
    }
    _ciudad.forEach((key, value) {
      _malla.add(subZona_polyline(
          [value["maxLat"], value["minLat"], value["maxLon"], value["minLon"]],
          key));
    });
    return _malla;
  }

  List<List<double>> subIntervalos_cordenadas(double _latMax, double _latMin,
      double _lonMax, double _lonMin, int _lado) {
    ///Recibe los rangos de coordenadas de una ciudad, el nombre de la ciudad y el ancho de los
    ///rectangulos de los subintervalos.
    ///Genera listas de longitud y latitud para crear una matriz para trazar las sub-areas
    ///en que se divide una ciudad.
    ///el distanciamiento de los rangos sera de acuerdo al valor de la
    ///variable _lado, la cual es el tamaño del lado de la seccion en metros. Utilizando
    ///este valor y el tmaño total del rango se generan intervalos lo mas cercanos posibles
    ///a dicho valor.
    ///Si se recibe algun valir nulo o incorrecto se devuelve una lista vacia, si todo sale bien retorna
    ///una lista que contiene anidadas 2 listas, la primera con los intervalos de latitud y la segunda con los intervalos de longitud

    ///Revision de no nulidad en valores recibidos
    if (_latMax == null ||
        _latMin == null ||
        _lonMax == null ||
        _lonMin == null) {
      return [];
    }

    ///revision de que losvalores recibidos sean consistentes
    if (_latMax <= _latMin || _lonMax <= _lonMin) {
      return [];
    }

    List<List<double>> _intervalos = [];

    double _ancho = GeolocatorPlatform.instance
            .distanceBetween(_latMax, _lonMin, _latMax, _lonMax),
        _alto = GeolocatorPlatform.instance
            .distanceBetween(_latMax, _lonMin, _latMin, _lonMin);

    ///descartar errores de la dependencia y/o de consistencia
    if (_ancho == null ||
        _ancho == 0 ||
        _alto == null ||
        _alto == 0 ||
        _lado == null ||
        _lado == 0) {
      return [];
    }

    ///calculamos el numero de intervalos en que dividremos la ciudad de acuerdo al valor
    ///_lado que se proporciono
    double _intervalos_alto = (_alto - (_alto % _lado)) / _lado,
        //_intervalos_ancho = (_ancho - (_ancho % _lado)) / _lado,
        _dimAncho,
        _dimAlto;
    List<double> _listaAncho = [_lonMax], _listaAlto = [_latMax];

    ///estos son los casos especiales en ciudades muy pequeñas que tengan menos una sub-seccione de tamaño
    if (_intervalos_alto == 0) {
      _intervalos_alto = 1;
    }

    /*if (_intervalos_ancho == 0) {
      _intervalos_ancho = 1;
    }*/

    _dimAlto = ((_latMax - _latMin) / _intervalos_alto);
    //_dimAncho = ((_lonMax - _lonMin) / _intervalos_ancho);
    _dimAncho = ((_lonMax - _lonMin) /
        _intervalos_alto); //eliminar esta linea si se descomenta la de arriba

    /*for (var i = 1; i < _intervalos_ancho; i++) {
      _listaAncho.add((_lonMax - (i * _dimAncho)));
    }*/
    for (var i = 1; i < _intervalos_alto; i++) {
      _listaAncho.add((_lonMax -
          (i * _dimAncho))); //eliminar este ciclo si se descomenta el de arriba
    }
    _listaAncho.add(_lonMin);

    for (var i = 1; i < _intervalos_alto; i++) {
      _listaAlto.add((_latMax - (i * _dimAlto)));
    }
    _listaAlto.add(_latMin);

    _n = _intervalos_alto.round();
    print("numero de lados $_n");
    return [_listaAncho, _listaAlto];
  }

  Map<dynamic, dynamic> mapaSubIntervalos(List<List<double>> _intervalos) {
    ///Recibe una lista que contenga 2 listas, una con intervalos de latitudes y otra con intervalos de longitudes
    ///a cambio retorna un objeto mapa con los diferentes subintervalos de zonas armados en orden lineal
    ///con sus latitudes y longitudes correspondientes.
    ///Si las listas son nulas o estan vacias retorna un mapa vacio

    if (_intervalos == null ||
        _intervalos.isEmpty ||
        _intervalos.length != 2 ||
        _intervalos[0] == null ||
        _intervalos[0].isEmpty ||
        _intervalos[1] == null ||
        _intervalos[1].isEmpty) {
      return {};
    }

    Map<dynamic, dynamic> _ciudad = {};
    _ciudad["cd"] = _cd;

    Map<dynamic, dynamic> _coord = {};
    int _numZona = 0;
    for (var i = 0; i < (_intervalos[0].length - 1); i++) {
      for (var j = 0; j < (_intervalos[1].length - 1); j++) {
        _coord["$_numZona"] = {
          "maxLat": _intervalos[1][j],
          "minLat": _intervalos[1][j + 1],
          "maxLon": _intervalos[0][i],
          "minLon": _intervalos[0][i + 1]
        };
        _numZona++;
      }
    }
    _ciudad["cordenadas"] = _coord;
    return _ciudad;
  }

  int r2_a_r1(int x, int y) {
    //recibe coordenadas en R2 y retornar el equivalente en R1
    return ((_n * y) + x);
  }

  List<int> r1_a_r2(int num) {
    //Recibe un valor lineal y retorna su equivalente en R2
    int x = (num % _n);
    int y = ((num - x) / _n).ceil();
    return [x, y];
  }

  int get_n() {
    if (_n == null) return 0;
    return _n;
  }

  List<int> secuenciaDeEscaneo(int casilla) {
    if (_n == null || _n == 0) return [];
    List<int> _secuencia = [], _r2;
    _r2 = r1_a_r2(casilla);
    int x = _r2[0], y = _r2[1];
    if (_n == 1) return [];
    if (_n == 2) {
      if (casilla == 0) {
        return [1, 2, 3];
      } else if (casilla == 1) {
        return [0, 3, 2];
      } else if (casilla == 2) {
        return [0, 3, 1];
      } else if (casilla == 3) {
        return [2, 1, 0];
      }
    }

    //caso 1
    if (y > 0 && y < (_n - 1) && x > 0 && x < (_n - 1)) {
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x - 1, y - 1));
      _secuencia.add(r2_a_r1(x + 1, y - 1));
      _secuencia.add(r2_a_r1(x + 1, y + 1));
      _secuencia.add(r2_a_r1(x - 1, y + 1));
    } else if (x == 0 && y == 0) {
      //caso 2
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x + 1, y + 1));
      _secuencia.add(r2_a_r1(x, y + 2));
      _secuencia.add(r2_a_r1(x + 1, y + 2));
      _secuencia.add(r2_a_r1(x + 2, y + 1));
      _secuencia.add(r2_a_r1(x + 2, y));
      _secuencia.add(r2_a_r1(x + 2, y + 2));
    } else if (x == 1 && x < (_n - 1) && y == 0) {
      //caso 3
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x + 1, y + 1));
      _secuencia.add(r2_a_r1(x - 1, y + 1));
    } else if (x == (_n - 1) && y == 0) {
      //caso 4
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x - 1, y + 1));
      _secuencia.add(r2_a_r1(x - 2, y));
      _secuencia.add(r2_a_r1(x - 2, y + 1));
      _secuencia.add(r2_a_r1(x, y + 2));
      _secuencia.add(r2_a_r1(x - 1, y + 2));
      _secuencia.add(r2_a_r1(x - 2, y + 2));
    } else if (x == (_n - 1) && y > 0 && y < (_n - 1)) {
      //caso 5
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x - 1, y + 1));
      _secuencia.add(r2_a_r1(x - 1, y - 1));
    } else if (x == (_n - 1) && y == (_n - 1)) {
      //caso 6
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x - 1, y - 1));
      _secuencia.add(r2_a_r1(x - 2, y));
      _secuencia.add(r2_a_r1(x - 2, y - 1));
      _secuencia.add(r2_a_r1(x, y - 2));
      _secuencia.add(r2_a_r1(x - 1, y - 2));
      _secuencia.add(r2_a_r1(x - 2, y - 2));
    } else if (y == (_n - 1) && x > 0 && x < (_n - 1)) {
      //caso 7
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x - 1, y));
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x - 1, y - 1));
      _secuencia.add(r2_a_r1(x + 1, y - 1));
    } else if (y == (_n - 1) && x == 0) {
      //caso 8
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x + 1, y - 1));
      _secuencia.add(r2_a_r1(x + 2, y));
      _secuencia.add(r2_a_r1(x + 2, y - 1));
      _secuencia.add(r2_a_r1(x, y - 2));
      _secuencia.add(r2_a_r1(x + 1, y - 2));
      _secuencia.add(r2_a_r1(x + 2, y - 2));
    } else if (y < (_n - 1) && y > 0 && x == 0) {
      //caso 9
      _secuencia.add(r2_a_r1(x + 1, y));
      _secuencia.add(r2_a_r1(x, y - 1));
      _secuencia.add(r2_a_r1(x, y + 1));
      _secuencia.add(r2_a_r1(x + 1, y + 1));
      _secuencia.add(r2_a_r1(x + 1, y - 1));
    }

    return _secuencia;
  }

  Set<Polyline> polylineaLimitesManuales() {
    ///retorna un set de polylines que trazan los limites actuales de las ciudades
    ///almacenadas en la instancia del objeto
    Set<Polyline> _polys = Set();
    List<Color> _colores = [
      Colors.black,
      Colors.black54,
      Colors.blue[900],
      Colors.blue[600],
      Colors.blue[300],
      Colors.blue[50],
      Colors.pink[900],
      Colors.pink[600],
      Colors.pink[300],
      Colors.pink[50],
      Colors.amber[900],
      Colors.amber[600],
      Colors.amber[300],
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red
    ];

    if (_limites == null) return _polys;
    try {
      _limites.forEach((key2, value2) {
        Map<dynamic, dynamic> _ciudad = value2;

        _ciudad.forEach((key, value) {
          List<LatLng> _lineas = [];
          _lineas.add(LatLng(value["maxLat"], value["minLon"]));
          _lineas.add(LatLng(value["maxLat"], value["maxLon"]));
          _lineas.add(LatLng(value["minLat"], value["maxLon"]));
          _lineas.add(LatLng(value["minLat"], value["minLon"]));
          _lineas.add(LatLng(value["maxLat"], value["minLon"]));

          var _poly = Polyline(
            polylineId: PolylineId(key2 + key.toString()),
            points: _lineas,
            color: _colores[key],
            width: 4,
          );
          print("orden ${_polys.length}");
          _polys.add(_poly);
        });
      });
    } catch (e) {
      print("Error en trazar polis $e");
      Set<Polyline> _p = Set();
      return _p;
    }

    return _polys;
  }

  List<String> nombreyZonaManuales(LatLng _pos) {
    ///retorna un set de polylines que trazan los limites actuales de las ciudades
    ///almacenadas en la instancia del objeto
    String _ciudad, _zonaM;

    if (_limites == null) return [];
    List<String> _resp = [];
    try {
      _limites.forEach((key2, value2) {
        Map<dynamic, dynamic> _ciudad = value2;

        _ciudad.forEach((key, value) {
          if (_pos.latitude <= value["maxLat"] &&
              _pos.latitude >= value["minLat"] &&
              _pos.longitude <= value["maxLon"] &&
              _pos.longitude >= value["minLon"]) {
            print("zona: $key2 $key");
            _resp.add(key2);
            _resp.add(key.toString());
            return;
          }
        });
        if (_resp.isNotEmpty) return;
      });
    } catch (e) {
      print("Error enencontrar zona $e");
      Set<Polyline> _p = Set();
      return [];
    }

    return _resp;
  }

  List<int> secuancia(String _ciudad, int _casilla) {
    if (_ciudad == "Manzanillo") {
      if (_casilla == 1) {
        return [1, 2, 6, 4];
      } else if (_casilla == 2) {
        return [2, 1, 6, 3];
      } else if (_casilla == 3) {
        return [3, 2, 1, 6];
      } else if (_casilla == 4) {
        return [4, 1, 2];
      } else if (_casilla == 5) {
        return [5, 7, 6, 9, 8, 10];
      } else if (_casilla == 6) {
        return [6, 2, 7, 1, 8, 3];
      } else if (_casilla == 7) {
        return [7, 6, 8, 10, 5, 9];
      } else if (_casilla == 8) {
        return [8, 10, 7, 9, 6, 5];
      } else if (_casilla == 9) {
        return [9, 10, 8, 7, 5];
      } else if (_casilla == 10) {
        return [10, 8, 7, 9, 11, 5];
      } else if (_casilla == 11) {
        return [11, 10, 8, 7, 9, 5];
      } else if (_casilla == 12) {
        return [12, 6, 7, 5, 2];
      } else if (_casilla == 13) {
        return [13, 10, 8];
      }
    } else if (_ciudad == "Ensenada") {
      if (_casilla == 1) {
        return [1, 3, 2];
      } else if (_casilla == 2) {
        return [2, 3, 4, 1];
      } else if (_casilla == 3) {
        return [3, 4, 5, 1, 2];
      } else if (_casilla == 4) {
        return [4, 3, 5, 2];
      } else if (_casilla == 5) {
        return [5, 3, 4];
      }
    } else if (_ciudad == "Pachuca") {
      if (_casilla == 1) {
        return [1, 6, 2, 5, 8];
      } else if (_casilla == 2) {
        return [2, 5, 6, 1, 3];
      } else if (_casilla == 3) {
        return [
          3,
          2,
          5,
          4,
        ];
      } else if (_casilla == 4) {
        return [4, 5, 3, 2];
      } else if (_casilla == 5) {
        return [5, 6, 2, 4, 3];
      } else if (_casilla == 6) {
        return [6, 5, 2, 1, 7];
      } else if (_casilla == 7) {
        return [7, 6, 5, 8];
      } else if (_casilla == 8) {
        return [8, 1, 6, 7];
      }
    }
    return [];
  }

  int _tiempoBusqueda(String _ciudad, _zona) {
    ///obtiene la ciudad y la zona y retorna el tiempo que debera dejar la solicitud en la zona
    ///enviada
    if (_ciudad == null || _ciudad == "") return 0;
    if (_ciudad == "Manzanillo") {
      if (_zona == 1) return 30;
      if (_zona == 2) return 25;
      if (_zona == 3) return 30;
      if (_zona == 4) return 30;
      if (_zona == 5) return 20;
      if (_zona == 6) return 25;
      if (_zona == 7) return 35;
      if (_zona == 8) return 25;
      if (_zona == 9) return 20;
      if (_zona == 10) return 35;
      if (_zona == 11) return 25;
      if (_zona == 12) return 20;
      if (_zona == 13) return 25;
    } else if (_ciudad == "Ensenada") {
      return 20;
    } else if (_ciudad == "Pachuca") {
      return 20;
    }
  }

  int siguienteZona(List<int> _secuancia, String _ciudad, int _zonaActual) {
    int _index = _secuancia.indexOf(_zonaActual);

    if (_index == -1) return -1;
    if ((_index == (_secuancia.length - 1))) {
      return _secuancia[0];
    } else {
      return _secuancia[_index + 1];
    }
  }

  Future<void> pausa(
      List<int> _secuancia, String _ciudad, int _zonaActual) async {
    int _index = _secuancia.indexOf(_zonaActual);

    if (_index == -1) return;
    if ((_index == (_secuancia.length - 1))) {
      await Future.delayed(
          Duration(seconds: _tiempoBusqueda(_ciudad, _secuancia[0])));
      return;
    } else {
      await Future.delayed(
          Duration(seconds: _tiempoBusqueda(_ciudad, _secuancia[_index + 1])));
      return;
    }
  }

  Widget telefonosPickup(Position _gps) {
    var cd = nombreyZonaManuales(LatLng(_gps.latitude, _gps.longitude));

    if (cd.isEmpty) {
      return const Text.rich(
        TextSpan(children: [
          TextSpan(
            text: "LO SENTIMOS",
            style: TextStyle(
                color: Color.fromARGB(255, 8, 1, 114),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          TextSpan(
            text:
                "\n\nEn este momento no disponemos de servicio de pickups en su zona.",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w300,
                fontSize: 16),
          )
        ]),
        textAlign: TextAlign.center,
      );
    }
    if (cd[0] == "Manzanillo") {
      return const Text.rich(
        TextSpan(children: [
          TextSpan(
            text: "CONTÁCTENOS VÍA TELEFÓNICA",
            style: TextStyle(
                color: Color.fromARGB(255, 8, 1, 114),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          TextSpan(
            text:
                "\n\nReserve su cita en alguno de los siguientes números telefónicos:",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          TextSpan(
            text: "\n\n1) 314 36 21563\n2) 314 96 87452\n3) 314 87 69582",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w300,
                fontSize: 16),
          )
        ]),
        textAlign: TextAlign.center,
      );
    }

    if (cd[0] == "Ensenada") {
      return const Text.rich(
        TextSpan(children: [
          TextSpan(
            text: "CONTÁCTENOS VÍA TELEFÓNICA",
            style: TextStyle(
                color: Color.fromARGB(255, 8, 1, 114),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          TextSpan(
            text:
                "\n\nReserve su cita en alguno de los siguientes números telefónicos:",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          TextSpan(
            text: "\n\n1) 646 36 21563\n2) 646 96 87452\n3) 646 87 69582",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w300,
                fontSize: 16),
          )
        ]),
        textAlign: TextAlign.center,
      );
    }

    if (cd[0] == "Pachuca") {
      return const Text.rich(
        TextSpan(children: [
          TextSpan(
            text: "CONTÁCTENOS VÍA TELEFÓNICA",
            style: TextStyle(
                color: Color.fromARGB(255, 8, 1, 114),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          TextSpan(
            text:
                "\n\nReserve su cita en alguno de los siguientes números telefónicos:",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          TextSpan(
            text: "\n\n1) 7711 36 21563\n2) 771 96 87452\n3) 771 87 69582",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w300,
                fontSize: 16),
          )
        ]),
        textAlign: TextAlign.center,
      );
    }

    return Funciones().invisible();
  }

  String carpeta(Position _pos) {
    ///retorna un set de polylines que trazan los limites actuales de las ciudades
    ///almacenadas en la instancia del objeto

    if (_limites == null) return "";
    String _resp = "";
    try {
      _limites.forEach((key2, value2) {
        Map<dynamic, dynamic> _ciudad = value2;

        _ciudad.forEach((key, value) {
          if (_pos.latitude <= value["maxLat"] &&
              _pos.latitude >= value["minLat"] &&
              _pos.longitude <= value["maxLon"] &&
              _pos.longitude >= value["minLon"]) {
            print("zona: $key2 $key");
            _resp = key2 + key.toString();
            return;
          }
        });
        if (_resp != "") return;
      });
    } catch (e) {
      print("Error enencontrar zona $e");
      Set<Polyline> _p = Set();
      return "";
    }

    return _resp;
  }
}
