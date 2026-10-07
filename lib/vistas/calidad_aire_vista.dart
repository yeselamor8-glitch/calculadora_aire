import 'package:flutter/material.dart';
import '../models/ciudad.dart';
import '../services/calidad_aire_service.dart';

class CalidadAireVista extends StatefulWidget {
  const CalidadAireVista({super.key});

  @override
  State<CalidadAireVista> createState() => _CalidadAireVistaState();
}

class _CalidadAireVistaState extends State<CalidadAireVista> {
  final _service = CalidadAireService();
  final _horasController = TextEditingController();

  Ciudad? _ciudadSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();

  bool _cargando = false;
  String? _error;
  double? _indiceExposicion;
  double? _promedioPM25;
  String? _nivelRiesgo;
  Color _colorRiesgo = Colors.grey;

  @override
  void dispose() {
    _horasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(ahora.year - 1),
      lastDate: ahora,
      helpText: 'Seleccione la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _calcular() async {
    // Validaciones
    if (_ciudadSeleccionada == null) {
      _mostrarError('Por favor seleccione una ciudad');
      return;
    }

    final horasTexto = _horasController.text.trim();
    if (horasTexto.isEmpty) {
      _mostrarError('Por favor ingrese las horas de exposición');
      return;
    }

    final horas = double.tryParse(horasTexto.replaceAll(',', '.'));
    if (horas == null) {
      _mostrarError('Ingrese un número válido de horas');
      return;
    }

    if (horas <= 0 || horas > 24) {
      _mostrarError('Las horas deben estar entre 0 y 24');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _indiceExposicion = null;
      _nivelRiesgo = null;
    });

    try {
      // Llamada asíncrona a la API
      final promedio = await _service.obtenerPromedioPM25(
        ciudad: _ciudadSeleccionada!,
        fecha: _fechaSeleccionada,
      );

      // Calcular índice de exposición
      final indice = promedio * horas;

      // Determinar nivel de riesgo
      String nivel;
      Color color;
      if (indice < 50) {
        nivel = 'Bajo';
        color = Colors.green;
      } else if (indice < 100) {
        nivel = 'Moderado';
        color = Colors.orange;
      } else if (indice < 150) {
        nivel = 'Alto';
        color = Colors.deepOrange;
      } else {
        nivel = 'Muy alto';
        color = Colors.red;
      }

      setState(() {
        _promedioPM25 = promedio;
        _indiceExposicion = indice;
        _nivelRiesgo = nivel;
        _colorRiesgo = color;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatearFechaMostrar(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Calidad del Aire'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- Dropdown de ciudades -----
              DropdownButtonFormField<Ciudad>(
                value: _ciudadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: ciudadesColombia.map((ciudad) {
                  return DropdownMenuItem<Ciudad>(
                    value: ciudad,
                    child: Text(ciudad.nombre),
                  );
                }).toList(),
                onChanged: (ciudad) {
                  setState(() => _ciudadSeleccionada = ciudad);
                },
              ),

              const SizedBox(height: 16),

              // ----- Fecha de consulta -----
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _formatearFechaMostrar(_fechaSeleccionada),
                ),
                decoration: const InputDecoration(
                  labelText: 'Fecha de consulta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: _seleccionarFecha,
              ),

              const SizedBox(height: 16),

              // ----- Horas de exposición -----
              TextField(
                controller: _horasController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Horas de exposición diaria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  suffixText: 'horas',
                  hintText: 'Ejemplo: 5',
                ),
              ),

              const SizedBox(height: 24),

              // ----- Botón calcular -----
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _cargando ? null : _calcular,
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(
                    _cargando ? 'Consultando API...' : 'Calcular Índice',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ----- Mensaje de error -----
              if (_error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ----- Resultado -----
              if (_indiceExposicion != null) ...[
                Card(
                  elevation: 4,
                  color: _colorRiesgo.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Índice de exposición: ${_indiceExposicion!.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _colorRiesgo,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nivel de riesgo: $_nivelRiesgo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _colorRiesgo,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 30),
                        Text(
                          'PM2.5 promedio del día: '
                          '${_promedioPM25!.toStringAsFixed(2)} µg/m³',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ciudad: ${_ciudadSeleccionada!.nombre}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Fecha: ${_formatearFechaMostrar(_fechaSeleccionada)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ----- Tabla de referencia -----
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Niveles de riesgo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _filaRiesgo('Bajo', '< 50', Colors.green),
                      _filaRiesgo('Moderado', '50 - 99', Colors.orange),
                      _filaRiesgo('Alto', '100 - 149', Colors.deepOrange),
                      _filaRiesgo('Muy alto', '≥ 150', Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaRiesgo(String nivel, String rango, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(nivel)),
          Text(
            rango,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}