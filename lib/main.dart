import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socio_conductor/Front-end/Inicio_sesion.dart';
import 'package:socio_conductor/Front-end/PaginaAdministrador.dart';

void main() async {
  //await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
        title: 'SOCIO CONDUCTOR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Inicio_de_sesion()); // PaginaAdministrador());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Size s;

  @override
  Widget build(BuildContext context) {
    if (s == null) {
      s = MediaQuery.of(context).size;
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
          ),
          body:
              Container() // This trailing comma makes auto-formatting nicer for build methods.
          );
    }
  }
}
