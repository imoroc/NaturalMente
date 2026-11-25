// Panel web del profesor. Se compila aparte de la app:
//
//   flutter run -d chrome --web-port 5800 -t lib/main_panel.dart \
//     --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
//
//   flutter build web -t lib/main_panel.dart --dart-define=...
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/panel/panel_app.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RepositorioPanel? repositorio;
  if (Nube.configurada) {
    final supabase = await Supabase.initialize(
      url: Nube.url,
      publishableKey: Nube.claveAnonima,
    );
    repositorio = RepositorioPanelSupabase(supabase.client);
  }
  runApp(PanelApp(repositorio: repositorio));
}
