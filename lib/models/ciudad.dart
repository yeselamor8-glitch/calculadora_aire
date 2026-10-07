class Ciudad {
  final String nombre;
  final double latitud;
  final double longitud;

  const Ciudad({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

/// Ciudades principales de Colombia con coordenadas
final List<Ciudad> ciudadesColombia = const [
  Ciudad(nombre: 'Bogotá', latitud: 4.61, longitud: -74.08),
  Ciudad(nombre: 'Medellín', latitud: 6.25, longitud: -75.56),
  Ciudad(nombre: 'Cali', latitud: 3.45, longitud: -76.53),
  Ciudad(nombre: 'Barranquilla', latitud: 10.96, longitud: -74.79),
  Ciudad(nombre: 'Cartagena', latitud: 10.39, longitud: -75.51),
  Ciudad(nombre: 'Bucaramanga', latitud: 7.12, longitud: -73.12),
  Ciudad(nombre: 'Cúcuta', latitud: 7.89, longitud: -72.50),
  Ciudad(nombre: 'Pereira', latitud: 4.81, longitud: -75.69),
  Ciudad(nombre: 'Manizales', latitud: 5.07, longitud: -75.51),
  Ciudad(nombre: 'Santa Marta', latitud: 11.24, longitud: -74.19),
  Ciudad(nombre: 'Ibagué', latitud: 4.44, longitud: -75.24),
  Ciudad(nombre: 'Villavicencio', latitud: 4.14, longitud: -73.63),
  Ciudad(nombre: 'Pasto', latitud: 1.21, longitud: -77.28),
  Ciudad(nombre: 'Montería', latitud: 8.75, longitud: -75.88),
  Ciudad(nombre: 'Neiva', latitud: 2.93, longitud: -75.28),
  Ciudad(nombre: 'Armenia', latitud: 4.53, longitud: -75.68),
  Ciudad(nombre: 'Sincelejo', latitud: 9.30, longitud: -75.39),
  Ciudad(nombre: 'Valledupar', latitud: 10.46, longitud: -73.25),
];