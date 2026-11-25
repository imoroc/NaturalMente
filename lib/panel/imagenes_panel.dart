import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';

/// Lado mayor de las fotos subidas. Se ven nítidas en una tablet y pesan poco.
const ladoMaximoImagen = 1600;

/// Límite del bucket `imagenes` en Supabase (2 MB), con margen.
const pesoMaximoImagen = 1800 * 1024;

/// Reduce una foto a JPEG de [ladoMaximoImagen] px como mucho.
///
/// Una foto de móvil de 4 MB se queda en unos 200-300 KB: así el plan gratuito
/// de Supabase (1 GB) da para miles de imágenes y los niños descargan poco.
Uint8List comprimirImagen(Uint8List original) {
  final leida = img.decodeImage(original);
  if (leida == null) {
    throw const ErrorPanel(
      'No se ha podido leer la imagen. Prueba con una foto JPG o PNG.',
    );
  }
  // Las fotos de móvil guardan el giro aparte: se aplica antes de reducir.
  var foto = img.bakeOrientation(leida);
  final lado = foto.width > foto.height ? foto.width : foto.height;
  if (lado > ladoMaximoImagen) {
    foto = foto.width >= foto.height
        ? img.copyResize(
            foto,
            width: ladoMaximoImagen,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            foto,
            height: ladoMaximoImagen,
            interpolation: img.Interpolation.average,
          );
  }
  // Las transparencias de un PNG se apoyan sobre blanco.
  if (foto.hasAlpha) {
    final fondo = img.Image(width: foto.width, height: foto.height)
      ..clear(img.ColorRgb8(255, 255, 255));
    foto = img.compositeImage(fondo, foto);
  }
  for (final calidad in [82, 70, 55]) {
    final jpg = img.encodeJpg(foto, quality: calidad);
    if (jpg.length <= pesoMaximoImagen) return jpg;
  }
  throw const ErrorPanel('La imagen es demasiado grande. Prueba con otra.');
}

/// Abre el selector de archivos, comprime la foto elegida y la sube.
/// Devuelve `null` si el profesor cancela.
Future<ImagenSubida?> elegirYSubirImagen(RepositorioPanel repositorio) async {
  final elegidas = await FilePicker.pickFiles(type: FileType.image);
  if (elegidas.isEmpty) return null;
  final original = await elegidas.first.readAsBytes();
  final jpg = comprimirImagen(original);
  return repositorio.subirImagen(jpg);
}
