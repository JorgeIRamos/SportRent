import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_rent/models/cancha_model.dart';

class FiltroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool activo;
  final bool esRestablecer;
  final VoidCallback onTap;

  const FiltroChip({
    super.key,
    required this.label,
    required this.icon,
    required this.activo,
    required this.onTap,
    this.esRestablecer = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        esRestablecer ? Colors.red[50]! : activo ? Colors.green[700]! : Colors.white;
    final Color textColor =
        esRestablecer ? Colors.red[700]! : activo ? Colors.white : Colors.grey[800]!;
    final Color borderColor =
        esRestablecer ? Colors.red[200]! : activo ? Colors.green[700]! : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class CanchaCard extends StatefulWidget {
  final Cancha cancha;
  final bool mostrarFavorito;
  final bool esFavorito;
  final VoidCallback? onToggleFavorito;
  final double? distanciaKm;

  const CanchaCard({
    super.key,
    required this.cancha,
    this.mostrarFavorito = false,
    this.esFavorito = false,
    this.onToggleFavorito,
    this.distanciaKm,
  });

  static Color colorDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
      case 'futbol':
        return Colors.green;
      case 'baloncesto':
        return Colors.orange;
      case 'tenis':
        return Colors.teal;
      case 'pádel':
      case 'padel':
        return Colors.indigo;
      case 'voleibol':
        return Colors.blue;
      case 'béisbol':
      case 'beisbol':
        return Colors.brown;
      default:
        return Colors.green;
    }
  }

  static IconData iconoDeporte(String deporte) {
    switch (deporte.toLowerCase()) {
      case 'fútbol':
      case 'futbol':
        return Icons.sports_soccer_outlined;
      case 'baloncesto':
        return Icons.sports_basketball_outlined;
      case 'tenis':
      case 'pádel':
      case 'padel':
        return Icons.sports_tennis_outlined;
      case 'voleibol':
        return Icons.sports_volleyball_outlined;
      default:
        return Icons.sports_outlined;
    }
  }

  @override
  State<CanchaCard> createState() => _CanchaCardState();
}

class _CanchaCardState extends State<CanchaCard> {
  int _paginaActual = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _formatPrecio(double precio) {
    final s = precio.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color = CanchaCard.colorDeporte(widget.cancha.tipoDeporte);
    final icono = CanchaCard.iconoDeporte(widget.cancha.tipoDeporte);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildImagenCarousel(color, icono),
              ),
              if (widget.mostrarFavorito && widget.onToggleFavorito != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: widget.onToggleFavorito,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        widget.esFavorito ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: widget.esFavorito ? Colors.red[400] : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.cancha.nombre,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatPrecio(widget.cancha.precioPorHora)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        ),
                        Text('por hora',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.cancha.direccion,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis),
                if (widget.distanciaKm != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.near_me_rounded, size: 13, color: Colors.green[600]),
                      const SizedBox(width: 3),
                      Text(
                        widget.distanciaKm! < 1
                            ? '${(widget.distanciaKm! * 1000).toInt()} m de distancia'
                            : '${widget.distanciaKm!.toStringAsFixed(1)} km de distancia',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    CalificacionEstrellas(
                        rating: widget.cancha.calificacionPromedio, size: 14),
                    const SizedBox(width: 12),
                    Icon(Icons.sports_outlined, size: 14, color: color),
                    const SizedBox(width: 3),
                    Text(widget.cancha.tipoDeporte,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.toNamed('/disponibilidad', arguments: widget.cancha),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ver Disponibilidad',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenCarousel(Color color, IconData icono) {
    final fotos = widget.cancha.fotosUrl;
    if (fotos.isEmpty) return _placeholder(color, icono);

    return Stack(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (_, i) => _buildFotoCancha(fotos[i], color, icono),
          ),
        ),
        if (fotos.length > 1) ...[
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _paginaActual == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _paginaActual == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_paginaActual + 1}/${fotos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFotoCancha(String url, Color color, IconData icono) {
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(bytes,
            height: 160, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(color, icono));
      } catch (_) {
        return _placeholder(color, icono);
      }
    }
    return Image.network(url,
        height: 160, width: double.infinity, fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                height: 160,
                color: color.withValues(alpha: 0.1),
                child: Center(
                    child: CircularProgressIndicator(color: color, strokeWidth: 2))),
        errorBuilder: (_, _, _) => _placeholder(color, icono));
  }

  Widget _placeholder(Color color, IconData icono) {
    return Container(
      height: 160,
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      child: Center(
          child: Icon(icono, size: 72, color: color.withValues(alpha: 0.4))),
    );
  }
}

class CalificacionEstrellas extends StatelessWidget {
  final double rating;
  final double size;

  const CalificacionEstrellas({super.key, required this.rating, this.size = 13});

  @override
  Widget build(BuildContext context) {
    if (rating == 0.0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (_) =>
              Icon(Icons.star_border_rounded, size: size, color: Colors.grey[350])),
          const SizedBox(width: 4),
          Text('Nuevo',
              style: TextStyle(fontSize: size - 1, color: Colors.grey[500])),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (rating >= i + 1) {
            return Icon(Icons.star_rounded, size: size, color: Colors.amber[600]);
          }
          if (rating >= i + 0.5) {
            return Icon(Icons.star_half_rounded, size: size, color: Colors.amber[600]);
          }
          return Icon(Icons.star_border_rounded, size: size, color: Colors.grey[350]);
        }),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(
                fontSize: size - 1,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
      ],
    );
  }
}
