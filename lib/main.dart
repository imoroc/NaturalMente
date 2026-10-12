import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/ui/mapa.dart';

void main() {
  runApp(const NaturalmenteApp());
}

class _Carga {
  const _Carga(this.catalogo, this.progreso);

  final Catalogo catalogo;
  final Progreso progreso;
}

class NaturalmenteApp extends StatefulWidget {
  const NaturalmenteApp({super.key});

  @override
  State<NaturalmenteApp> createState() => _NaturalmenteAppState();
}

class _NaturalmenteAppState extends State<NaturalmenteApp> {
  late final Future<_Carga> _carga = _abrir();

  Future<_Carga> _abrir() async {
    final catalogo = await Catalogo.cargar();
    final progreso = await Progreso.abrir();
    return _Carga(catalogo, progreso);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Carga>(
      future: _carga,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('No he podido abrir NaturalMente.')),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final carga = snapshot.data!;
        return Alcance(
          catalogo: carga.catalogo,
          progreso: carga.progreso,
          child: MaterialApp(
            title: 'NaturalMente',
            debugShowCheckedModeBanner: false,
            locale: const Locale('es'),
            supportedLocales: const [Locale('es')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A2C)),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF6F1E6),
            ),
            home: const MapaPage(),
          ),
        );
      },
    );
  }
}
