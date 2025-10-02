class Movimiento {
  final String tipo;
  final double monto;
  final DateTime fecha;
  final String categoria; // 👈 este es obligatorio

  Movimiento({
    required this.tipo,
    required this.monto,
    required this.fecha,
    required this.categoria, // 👈 requerido
  });
}
