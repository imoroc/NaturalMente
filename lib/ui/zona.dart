import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/juego.dart';

class ZonaPage extends StatelessWidget {
  const ZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final actividades = catalogo.actividadesDe(zona.id);
    final fichas = catalogo.fichasDe(zona.id);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(zona.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListenableBuilder(
        listenable: alcance.progreso,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2DEC9), width: 2),
                ),
                child: Row(
                  children: [
                    const DibujoMascota(gesto: 'hola', tamano: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        zona.resumen,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final actividad in actividades) ...[
                _BotonMision(
                  id: actividad.id,
                  titulo: actividad.titulo,
                  curso: actividad.curso,
                  hecha: alcance.progreso.actividadHecha(actividad),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JuegoPage(actividad: actividad),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              Text(
                'FICHAS PARA DESCUBRIR',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF475569),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              for (final ficha in fichas) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2DEC9), width: 2),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3D1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    title: Text(
                      ficha.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Pensado para ${ficha.curso}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF2ECC71),
                        ),
                        title: Text(ficha.frase),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFF9F1C),
                        ),
                        title: Text(ficha.curiosidad),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BotonMision extends StatelessWidget {
  const _BotonMision({
    required this.id,
    required this.titulo,
    required this.curso,
    required this.hecha,
    required this.onTap,
  });

  final String id;
  final String titulo;
  final String curso;
  final bool hecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorBorde = hecha ? const Color(0xFF2ECC71) : const Color(0xFF38BDF8);
    final colorSombra = hecha ? const Color(0xFF239E56) : const Color(0xFF0284C7);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: colorSombra,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('juego-$id'),
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorBorde.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hecha ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                    color: colorSombra,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1B3022),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pensado para $curso',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
