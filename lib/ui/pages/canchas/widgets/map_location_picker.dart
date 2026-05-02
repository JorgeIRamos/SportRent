import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapLocationResult {
  final LatLng latLng;
  final String direccion;

  const MapLocationResult({required this.latLng, required this.direccion});
}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialPosition;

  const MapLocationPicker({super.key, this.initialPosition});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final _mapCtrl = MapController();

  // Centro predeterminado: Colombia
  late LatLng _center;
  String _direccion = '';
  bool _cargandoDireccion = false;
  bool _cargandoUbicacion = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialPosition ?? const LatLng(4.7110, -74.0721);
    if (widget.initialPosition == null) _irAMiUbicacion(silent: true);
  }

  Future<void> _irAMiUbicacion({bool silent = false}) async {
    setState(() => _cargandoUbicacion = true);
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final punto = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(punto, 16);
      setState(() => _center = punto);
      await _geocodificarCentro(punto);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  Future<void> _geocodificarCentro(LatLng punto) async {
    setState(() => _cargandoDireccion = true);
    try {
      final placemarks = await placemarkFromCoordinates(punto.latitude, punto.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final partes = <String>[
          if ((p.street ?? '').isNotEmpty) p.street!,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
          if ((p.locality ?? '').isNotEmpty) p.locality!,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        ];
        setState(() => _direccion = partes.isNotEmpty
            ? partes.join(', ')
            : 'Ubicación seleccionada');
      }
    } catch (_) {
      if (mounted) setState(() => _direccion = 'Ubicación seleccionada');
    } finally {
      if (mounted) setState(() => _cargandoDireccion = false);
    }
  }

  void _onMapMove(MapCamera camera, bool hasGesture) {
    _center = camera.center;
  }

  void _onMapMoveEnd(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    _geocodificarCentro(_center);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initialPosition != null ? 16 : 13,
              onPositionChanged: _onMapMove,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _onMapMoveEnd(event.camera, true);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sportrent.app',
              ),
            ],
          ),

          // Pin central fijo
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, size: 48, color: Colors.green),
                SizedBox(height: 24),
              ],
            ),
          ),

          // Panel inferior con dirección y botón confirmar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, -3))
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text('Ubicación seleccionada',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _cargandoDireccion
                      ? Row(
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.green[600])),
                            const SizedBox(width: 10),
                            Text('Obteniendo dirección...',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600])),
                          ],
                        )
                      : _direccion.isEmpty
                          ? Text('Mueve el mapa para seleccionar un lugar',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[500]))
                          : Text(
                              _direccion,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_cargandoDireccion || _direccion.isEmpty)
                          ? null
                          : () => Navigator.pop(
                                context,
                                MapLocationResult(
                                  latLng: _center,
                                  direccion: _direccion,
                                ),
                              ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Confirmar ubicación',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de mi ubicación
          Positioned(
            right: 16,
            bottom: 170,
            child: FloatingActionButton.small(
              heroTag: 'miUbicacion',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _cargandoUbicacion ? null : _irAMiUbicacion,
              child: _cargandoUbicacion
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.green[700]))
                  : Icon(Icons.my_location_rounded,
                      color: Colors.green[700], size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
