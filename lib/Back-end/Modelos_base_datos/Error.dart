import 'dart:convert';

Error_M errorFromJson(String str) => Error_M.fromJson(json.decode(str));

String errorToJson(Error_M data) => json.encode(data.toJson());

//Esta clase se utiliza para guardar distintos tipos de erorres que puedan surgir.
//sus metodos son coversiones a formato json con el fin de guardar estos errores en la base de datos, de donde se recuperaran
//para poder conocer exactamente donde se ubican los errores cuando exita un error durante la ejecucion.
// atributos:
//id: reservado para que la base de datos le asigne un valor.
//clase: aqui guardamos el nombre de la clase donde se ubica el error
//funcionID: ejemplo: si es la tercera funcion que puede captar un error, el ide es 3.
//fecha: es un dateTime convertido a String
//mensaje: este atributo debe contener el mensje de error que el sistema devuelve.
//notas: opcional, observaciones especiales sobre lo que podria causar el error
class Error_M {
  Error_M(
      {this.id,
      this.clase,
      this.mensaje,
      this.fecha,
      this.funcionID,
      this.nota,
      this.usuario,
      this.id_firestore});

  int id;
  int funcionID;
  String id_firestore;
  String usuario;
  String clase;
  String mensaje;
  String fecha;
  String nota;

  factory Error_M.fromJson(Map<String, dynamic> json) => Error_M(
      id: json["id"],
      id_firestore: json["id_firestore"],
      usuario: json["usuario"],
      funcionID: json["funcionID"],
      clase: json["clase"],
      mensaje: json["mensaje"],
      fecha: json["fecha"],
      nota: json["nota"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "funcionID": funcionID,
        "clase": clase,
        "mensaje": mensaje,
        "fecha": fecha,
        "nota": nota,
        "id_firestore":id_firestore,
        "usuario":usuario
      };
}
