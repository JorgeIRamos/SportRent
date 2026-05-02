import 'package:flutter/material.dart';
import 'package:sport_rent/ui/pages/empresa/widgets/home_empresa_widgets.dart';

class EstadisticasFiltros extends StatelessWidget {
  final String periodo;
  final String etiquetaPeriodo;
  final String? filtroCancha;
  final List<String> canchas;
  final VoidCallback onAntes;
  final VoidCallback onAdelante;
  final ValueChanged<String> onPeriodoChanged;
  final ValueChanged<String?> onFiltroCanchaChanged;
  final VoidCallback onExportarPdf;

  const EstadisticasFiltros({
    super.key,
    required this.periodo,
    required this.etiquetaPeriodo,
    required this.filtroCancha,
    required this.canchas,
    required this.onAntes,
    required this.onAdelante,
    required this.onPeriodoChanged,
    required this.onFiltroCanchaChanged,
    required this.onExportarPdf,
  });

  void _elegir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          if (filtroCancha != null)
            ListTile(
              leading: Icon(Icons.close, color: Colors.red[400]),
              title: const Text('Mostrar todos'),
              onTap: () {
                onFiltroCanchaChanged(null);
                Navigator.pop(context);
              },
            ),
          ...canchas.map(
            (o) => ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: filtroCancha == o ? Colors.green[700] : Colors.grey[400],
              ),
              title: Text(o),
              trailing: filtroCancha == o
                  ? Icon(Icons.check, color: Colors.green[700])
                  : null,
              onTap: () {
                onFiltroCanchaChanged(o);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Día', 'Semana', 'Mes', 'Año'].map((p) {
              final sel = periodo == p;
              return GestureDetector(
                onTap: () => onPeriodoChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? Colors.green[700] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? Colors.green[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onAntes,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: Colors.green[800],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                etiquetaPeriodo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onAdelante,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropChipEmpresa(
                  label: filtroCancha ?? 'Tipo de cancha',
                  icon: Icons.sports_soccer_outlined,
                  activo: filtroCancha != null,
                  onTap: () => _elegir(context),
                ),
                const SizedBox(width: 8),
                if (filtroCancha != null)
                  GestureDetector(
                    onTap: () => onFiltroCanchaChanged(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Limpiar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onExportarPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Exportar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
