import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ciudad.dart';

class CalidadAireService {
  static const String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  /// Consulta la API Open-Meteo Air Quality y devuelve
  /// el promedio diario de PM2.5 (µg/m³).
  Future<double> obtenerPromedioPM25({
    required Ciudad ciudad,
    required DateTime fecha,
  }) async {
    final fechaStr = _formatearFecha(fecha);

    final url = Uri.parse(
      '$_baseUrl'
      '?latitude=${ciudad.latitud}'
      '&longitude=${ciudad.longitud}'
      '&hourly=pm2_5'
      '&start_date=$fechaStr'
      '&end_date=$fechaStr',
    );

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al consultar la API (código ${response.statusCode})',
        );
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (!data.containsKey('hourly') || data['hourly'] == null) {
        throw Exception('La API no devolvió datos horarios');
      }

      final List<dynamic> valores = data['hourly']['pm2_5'] ?? [];

      // Filtrar valores nulos
      final valoresValidos = valores
          .where((v) => v != null)
          .map((v) => (v as num).toDouble())
          .toList();

      if (valoresValidos.isEmpty) {
        throw Exception('No hay datos disponibles para esa fecha');
      }

      final suma = valoresValidos.reduce((a, b) => a + b);
      return suma / valoresValidos.length;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}