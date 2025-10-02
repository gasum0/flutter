import 'package:flutter/material.dart';
import '../models/movimiento.dart';

class MovimientoCard extends StatelessWidget {
  final Movimiento movimiento;

  const MovimientoCard({Key? key, required this.movimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: Icon(
          movimiento.tipo == 'Ingreso'
              ? Icons.arrow_circle_up
              : Icons.arrow_circle_down,
          color: movimiento.tipo == 'Ingreso' ? Colors.green : Colors.red,
        ),
        title: Text('${movimiento.categoria} - \$${movimiento.monto}'),
        subtitle: Text(movimiento.fecha.toString()),
      ),
    );
  }
}
