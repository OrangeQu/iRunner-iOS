import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/run_session.dart';

class RunDetailPage extends StatelessWidget {
  final RunSession run;

  const RunDetailPage({Key? key, required this.run}) : super(key: key);

  String _formatDuration(Duration d) {
    final parts = <String>[];
    if (d.inHours > 0) parts.add('${d.inHours}h');
    if (d.inMinutes.remainder(60) > 0) parts.add('${d.inMinutes.remainder(60)}m');
    parts.add('${d.inSeconds.remainder(60)}s');
    return parts.join(' ');
  }

  String _formatPace(double secondsPerKm) {
    if (secondsPerKm.isInfinite || secondsPerKm.isNaN) return "N/A";
    final minutes = (secondsPerKm / 60).floor();
    final seconds = (secondsPerKm % 60).round();
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km";
  }

  @override
  Widget build(BuildContext context) {
    final polylinePoints = run.route.map((c) => LatLng(c.latitude, c.longitude)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy-MM-dd').format(run.date.toLocal())),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: polylinePoints.isNotEmpty ? polylinePoints.first : LatLng(0, 0),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildStatCard('距离', '${(run.distanceInMeters / 1000).toStringAsFixed(2)} km'),
                  _buildStatCard('时长', _formatDuration(run.duration)),
                  _buildStatCard('配速', _formatPace(run.paceInSecondsPerKm)),
                  _buildStatCard('日期', DateFormat('yyyy/MM/dd HH:mm').format(run.date.toLocal())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
