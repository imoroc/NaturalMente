import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/apariencia.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/mapa.dart';
import 'package:naturalmente/ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apariencia = await Apariencia.abrir();
  runApp(NaturalmenteApp(apariencia: apariencia));
}

class _Carga {
  const _Carga(this.catalogo, this.progreso, this.idioma);
  final Catalogo catalogo;
  final Progreso progreso;
  final Idioma idioma;
}

class NaturalmenteApp extends StatefulWidget {
  const NaturalmenteApp({this.apariencia, super.key});
  final Apariencia? apariencia;

  @override
  State<NaturalmenteApp> createState() => _NaturalmenteAppState();
}

class _NaturalmenteAppState extends State<NaturalmenteApp> {
  late final Future<Apariencia> _apariencia = widget.apariencia == null
      ? Apariencia.abrir()
      : Future.value(widget.apariencia);
  late final Future<_Carga> _carga = _abrir();
  Idioma? _idioma;
  bool _cerrada = false;

  Future<_Carga> _abrir() async {
    await _apariencia;
    final idioma = await Idioma.abrir();
    _idioma = idioma;
    if (_cerrada) idioma.dispose();
    final catalogo = await Catalogo.cargar();
    final progreso = await Progreso.abrir();
    return _Carga(catalogo, progreso, idioma);
  }

  @override
  void dispose() {
    _cerrada = true;
    // También limpia una carga que termine después de desmontar la app.
    _apariencia.then((a) => a.dispose());
    _idioma?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Apariencia>(
    future: _apariencia,
    initialData: widget.apariencia,
    builder: (context, aparienciaSnapshot) {
      final apariencia = aparienciaSnapshot.data;
      if (apariencia == null) return const SizedBox.shrink();
      return AparienciaScope(
        apariencia: apariencia,
        child: FutureBuilder<_Carga>(
          future: _carga,
          builder: (context, snapshot) {
            final carga = snapshot.data;
            return ListenableBuilder(
              listenable: Listenable.merge([apariencia, ?_idioma]),
              builder: (context, _) => MaterialApp(
                title: 'NaturalMente',
                debugShowCheckedModeBanner: false,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  scrollbars: false,
                ),
                locale: _idioma?.locale ?? const Locale('es'),
                supportedLocales: const [Locale('es'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: TemaNatural.crear(Brightness.light),
                darkTheme: TemaNatural.crear(Brightness.dark),
                themeMode: apariencia.tema,
                themeAnimationDuration:
                    MediaQuery.maybeDisableAnimationsOf(context) == true
                    ? Duration.zero
                    : kThemeAnimationDuration,
                builder: (context, child) {
                  Widget contenido = child!;
                  if (_idioma != null) {
                    contenido = IdiomaScope(idioma: _idioma!, child: contenido);
                  }
                  if (carga != null) {
                    contenido = Alcance(
                      catalogo: carga.catalogo,
                      progreso: carga.progreso,
                      child: contenido,
                    );
                  }
                  final oscuro =
                      Theme.of(context).brightness == Brightness.dark;
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value:
                        (oscuro
                                ? SystemUiOverlayStyle.light
                                : SystemUiOverlayStyle.dark)
                            .copyWith(
                              systemNavigationBarColor: Theme.of(context)
                                  .scaffoldBackgroundColor,
                              systemNavigationBarIconBrightness: oscuro
                                  ? Brightness.light
                                  : Brightness.dark,
                            ),
                    child: contenido,
                  );
                },
                home: carga != null
                    ? const MapaPage()
                    : Scaffold(
                        body: Center(
                          child: snapshot.hasError
                              ? Text(
                                  _idioma?.traducir(
                                        'No he podido abrir NaturalMente.',
                                      ) ??
                                      'No he podido abrir NaturalMente.',
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
              ),
            );
          },
        ),
      );
    },
  );
}
