import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/ui/mapa.dart';

void main() {
  runApp(const NaturalmenteApp());
}

class NaturalmenteApp extends StatefulWidget {
  const NaturalmenteApp({super.key});

  @override
  State<NaturalmenteApp> createState() => _NaturalmenteAppState();
}

class _NaturalmenteAppState extends State<NaturalmenteApp> {
  late final Future<Catalogo> _catalogo = Catalogo.cargar();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: FutureBuilder<Catalogo>(
        future: _catalogo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('No he podido leer el catálogo.')),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return MapaPage(zonas: snapshot.data!.zonas);
        },
      ),
    );
  }
}
