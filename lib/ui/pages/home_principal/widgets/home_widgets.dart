import 'package:flutter/material.dart';

export 'package:sport_rent/ui/pages/home_principal/widgets/cancha_card.dart';

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
