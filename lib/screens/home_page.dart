import 'package:flutter/material.dart';
import 'juega_y_gana_page.dart';
import '../services/db_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> movimientos = [];
  double saldo = 0;

  @override
  void initState() {
    super.initState();
    _cargarSaldo();
  }

  Future<void> _cargarSaldo() async {
    try {
      final data = await DBService.obtenerMovimientos();
      double nuevoSaldo = 0;

      for (var mov in data) {
        final monto = (mov['monto'] as num).toDouble();
        if (mov['tipo'] == 'Ingreso') {
          nuevoSaldo += monto;
        } else {
          nuevoSaldo -= monto;
        }
      }

      setState(() {
        saldo = nuevoSaldo;
      });
    } catch (e) {
      print('Error cargando saldo: $e');
    }
  }

  Future<void> _agregarMovimiento(
      String tipo, double monto, String categoria) async {
    await DBService.insertarMovimiento(tipo, categoria, monto);

    setState(() {
      movimientos.add({
        'tipo': tipo,
        'categoria': categoria,
        'monto': monto,
        'fecha': DateTime.now().toIso8601String(),
      });

      if (tipo == 'Ingreso') {
        saldo += monto;
      } else {
        saldo -= monto;
      }
    });
  }

  void _mostrarFormulario() {
    String tipo = 'Gasto';
    String categoria = '';
    double monto = 0;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Color(0xFF00d4ff).withOpacity(0.3), width: 1),
              ),
              title: Text(
                'Nuevo movimiento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: DropdownButton<String>(
                      value: tipo,
                      isExpanded: true,
                      dropdownColor: Color(0xFF16213e),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFF00d4ff)),
                      items: ['Ingreso', 'Gasto']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() => tipo = value!);
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF00d4ff)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      onChanged: (value) => categoria = value,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        labelStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.attach_money, color: Color(0xFF00d4ff)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        monto = parsed ?? 0;
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar', style: TextStyle(color: Colors.white60)),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00d4ff), Color(0xFF0077b6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Guardar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (categoria.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⚠️ La categoría no puede estar vacía"),
                            backgroundColor: Colors.orange[800],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      if (monto <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⚠️ El monto debe ser mayor que 0"),
                            backgroundColor: Colors.orange[800],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }

                      _agregarMovimiento(tipo, monto, categoria);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cerrarDia() async {
    await DBService.insertarCierre(saldo);

    setState(() {
      movimientos.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Día cerrado. Saldo final: \$${saldo.toStringAsFixed(2)}"),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _abrirHistorialCierres() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistorialCierresPage()),
    );
  }

  void _logout() {
    DBService.setCurrentUserId(null);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gestor de Gastos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.calendar_today, color: Color(0xFF00d4ff)),
                            onPressed: _abrirHistorialCierres,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.logout, color: Color(0xFF00d4ff)),
                            onPressed: _logout,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tarjeta de saldo
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00d4ff), Color(0xFF0077b6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00d4ff).withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Saldo actual',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '\$${saldo.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Lista de movimientos
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: movimientos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 60,
                                color: Colors.white30,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No hay movimientos',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: movimientos.length,
                          itemBuilder: (context, index) {
                            final mov = movimientos[index];
                            final isIngreso = mov['tipo'] == 'Ingreso';
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: (isIngreso ? Colors.green : Colors.red)
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isIngreso ? Colors.green : Colors.red)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isIngreso
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: isIngreso ? Colors.green : Colors.red,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  mov['categoria'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  mov['fecha'].toString().split('T')[0],
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                trailing: Text(
                                  '\$${mov['monto']}',
                                  style: TextStyle(
                                    color: isIngreso ? Colors.green : Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SizedBox(height: 20),

              // Botones de acción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Botón Juega y Gana
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[600]!, Colors.pink[600]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JuegaYGanaPage(
                                onResultado: (int valor) {
                                  _agregarMovimiento(
                                    valor >= 0 ? 'Ingreso' : 'Gasto',
                                    valor.abs().toDouble(),
                                    'casino',
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: Icon(Icons.casino, color: Colors.white, size: 24),
                        label: Text(
                          "🎮 Juega y Gana",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Botón Terminar día
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[600]!, Colors.deepOrange[600]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _cerrarDia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: Icon(Icons.check_circle, color: Colors.white, size: 24),
                        label: Text(
                          "Terminar día",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00d4ff), Color(0xFF0077b6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00d4ff).withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _mostrarFormulario,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

// ================== Pantalla de historial ===================
class HistorialCierresPage extends StatefulWidget {
  @override
  _HistorialCierresPageState createState() => _HistorialCierresPageState();
}

class _HistorialCierresPageState extends State<HistorialCierresPage> {
  List<Map<String, dynamic>> cierres = [];

  @override
  void initState() {
    super.initState();
    _cargarCierres();
  }

  Future<void> _cargarCierres() async {
    final data = await DBService.obtenerCierres();
    setState(() {
      cierres = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF00d4ff)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Historial de Cierres",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de cierres
              Expanded(
                child: cierres.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.white30),
                            SizedBox(height: 15),
                            Text(
                              'No hay cierres registrados',
                              style: TextStyle(color: Colors.white60, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cierres.length,
                        itemBuilder: (context, index) {
                          final cierre = cierres[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 15),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00d4ff).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF00d4ff),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cierre del día",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        cierre['fecha'],
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\$${cierre['saldo']}",
                                  style: TextStyle(
                                    color: Color(0xFF00d4ff),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}