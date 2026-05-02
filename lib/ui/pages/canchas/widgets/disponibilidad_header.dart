import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sport_rent/models/cancha_model.dart';

/// Header de la pantalla de disponibilidad: carrusel de fotos + info de la cancha.
///
/// Gestiona internamente la página actual del [PageView] para no ensuciar el
/// padre con ese estado de presentación.
class DisponibilidadHeader extends StatefulWidget {
  final Cancha cancha;
  final Color color;
  final String Function(double) formatPrecio;

  const DisponibilidadHeader({
    super.key,
    required this.cancha,
    required this.color,
    required this.formatPrecio,
  });

  @override
  State<DisponibilidadHeader> createState() => _DisponibilidadHeaderState();
}

class _DisponibilidadHeaderState extends State<DisponibilidadHeader> {
  int _paginaActual = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Column(
        children: [
          _buildImagenCarousel(widget.cancha, widget.color),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cancha.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.cancha.tipoDeporte,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.star, size: 14, color: Colors.amber[600]),
                              const SizedBox(width: 3),
                              Text(
                                widget.cancha.calificacionPromedio.toStringAsFixed(1),
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.green[600]),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.cancha.direccion,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.formatPrecio(widget.cancha.precioPorHora)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'por hora',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenCarousel(Cancha cancha, Color color) {
    final fotos = cancha.fotosUrl;
    if (fotos.isEmpty) return _placeholderImagen(color);

    return Stack(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (_, i) => _fotoCancha(fotos[i], color),
          ),
        ),
        if (fotos.length > 1) ...[
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _paginaActual == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _paginaActual == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_paginaActual + 1} / ${fotos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _fotoCancha(String url, Color color) {
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(
          bytes,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderImagen(color),
        );
      } catch (_) {
        return _placeholderImagen(color);
      }
    }
    return Image.network(
      url,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholderImagen(color),
    );
  }

  Widget _placeholderImagen(Color color) {
    return Container(
      height: 220,
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          Icons.sports_soccer_outlined,
          size: 80,
          color: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
