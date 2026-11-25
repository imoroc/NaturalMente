import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/apariencia.dart';
import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/bienvenida.dart';
import 'package:naturalmente/ui/mapa.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apariencia = await Apariencia.abrir();
  runApp(NaturalmenteApp(apariencia: apariencia));
}

class _Carga {
  const _Carga(this.catalogo, this.perfiles, this.aula, this.idioma);
  final Catalogo catalogo;
  final Perfiles perfiles;
  final Aula aula;
  final Idioma idioma;
}

class NaturalmenteApp extends StatefulWidget {
  const NaturalmenteApp({
    this.apariencia,
    this.conBienvenida = true,
    this.repositorioAula,
    this.usarNube = true,
    super.key,
  });
  final Apariencia? apariencia;

  /// Para las pruebas: Aula con datos en memoria en vez de la nube.
  final RepositorioAula? repositorioAula;

  /// Conecta Aula con Supabase si la app se compiló con sus claves.
  final bool usarNube;

  /// Muestra la bienvenida con Natu si todavía no se ha visto. Las pruebas que
  /// empiezan directamente en el mapa la desactivan.
  final bool conBienvenida;

  @override
  State<NaturalmenteApp> createState() => _NaturalmenteAppState();
}

class _NaturalmenteAppState extends State<NaturalmenteApp> {
  late final Future<Apariencia> _apariencia = widget.apariencia == null
      ? Apariencia.abrir()
      : Future.value(widget.apariencia);
  late final Future<_Carga> _carga = _abrir();
  Idioma? _idioma;
  Perfiles? _perfiles;
  Aula? _aula;
  bool _cerrada = false;

  Future<_Carga> _abrir() async {
    await _apariencia;
    final idioma = await Idioma.abrir();
    _idioma = idioma;
    if (_cerrada) idioma.dispose();
    final catalogo = await Catalogo.cargar();
    final prefs = await SharedPreferences.getInstance();
    final perfiles = Perfiles.leer(prefs);
    _perfiles = perfiles;
    final repositorio =
        widget.repositorioAula ?? (widget.usarNube ? await Nube.abrir() : null);
    final aula = Aula(
      repositorio: repositorio,
      perfiles: perfiles,
      prefs: prefs,
      // Misma caché que usan las imágenes de Aula al mostrarse.
      precargarImagen: repositorio is RepositorioAulaSupabase
          ? (url) => DefaultCacheManager().downloadFile(url)
          : null,
    );
    _aula = aula;
    return _Carga(catalogo, perfiles, aula, idioma);
  }

  @override
  void dispose() {
    _cerrada = true;
    // También limpia una carga que termine después de desmontar la app.
    _apariencia.then((a) => a.dispose());
    _idioma?.dispose();
    _perfiles?.dispose();
    _aula?.dispose();
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
              listenable: Listenable.merge([apariencia, ?_idioma, ?_perfiles]),
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
                    // Al cambiar de perfil, todo el árbol pasa a leer el
                    // progreso del niño que juega ahora.
                    contenido = PerfilesScope(
                      perfiles: carga.perfiles,
                      child: AulaScope(
                        aula: carga.aula,
                        child: Alcance(
                          catalogo: carga.catalogo,
                          progreso: carga.perfiles.progreso,
                          child: contenido,
                        ),
                      ),
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
                    ? (widget.conBienvenida && !carga.perfiles.progreso.bienvenidaVista
                          ? const BienvenidaPage()
                          : const MapaPage())
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
