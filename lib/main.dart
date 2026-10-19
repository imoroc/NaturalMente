import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/ui/mapa.dart';

void main() {
  runApp(const NaturalmenteApp());
}

class _Carga {
  const _Carga(this.catalogo, this.progreso, this.idioma);

  final Catalogo catalogo;
  final Progreso progreso;
  final Idioma idioma;
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
    return _Carga(catalogo, progreso, await Idioma.abrir());
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
        return IdiomaScope(
          idioma: carga.idioma,
          child: ListenableBuilder(
            listenable: carga.idioma,
            builder: (context, _) => Alcance(
              catalogo: carga.catalogo,
              progreso: carga.progreso,
              child: MaterialApp(
                title: 'NaturalMente',
                debugShowCheckedModeBanner: false,
                locale: carga.idioma.locale,
                supportedLocales: const [Locale('es'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2ECC71),
                    primary: const Color(0xFF1F8A4C),
                    secondary: const Color(0xFFFF9F1C),
                    surface: const Color(0xFFFFFDF7),
                  ),
                  useMaterial3: true,
                  scaffoldBackgroundColor: const Color(0xFFF7F4EB),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFFF7F4EB),
                    foregroundColor: Color(0xFF1D3528),
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    titleTextStyle: TextStyle(
                      color: Color(0xFF1D3528),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  textTheme: const TextTheme(
                    headlineMedium: TextStyle(
                      color: Color(0xFF1D3528),
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                    titleLarge: TextStyle(
                      color: Color(0xFF1D3528),
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                    bodyMedium: TextStyle(
                      color: Color(0xFF344E41),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
                home: const MapaPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
