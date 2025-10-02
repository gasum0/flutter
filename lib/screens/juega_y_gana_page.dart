import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

// 🔹 Importamos la nueva máquina tragamonedas
import 'slot_machine_page.dart';

class JuegaYGanaPage extends StatefulWidget {
  final ValueChanged<int> onResultado;

  const JuegaYGanaPage({Key? key, required this.onResultado}) : super(key: key);

  @override
  _JuegaYGanaPageState createState() => _JuegaYGanaPageState();
}

class _JuegaYGanaPageState extends State<JuegaYGanaPage> with SingleTickerProviderStateMixin {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  final Random _random = Random();
  final List<int> _valores = [-100, -50, -20, 0, 20, 50, 100];
  String _mensaje = "Presiona GIRAR para jugar";
  bool _isSpinning = false; // 🔒 Control de bloqueo
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _pulseController.dispose();
    super.dispose();
  }

  void _girarRuleta() {
    if (_isSpinning) return; // 🔒 Bloquea si ya está girando

    setState(() {
      _isSpinning = true;
      _mensaje = "🎰 Girando...";
    });

    final index = _random.nextInt(_valores.length);
    _controller.add(index);

    // ⏱️ Espera a que termine la animación
    Future.delayed(Duration(milliseconds: 4000), () {
      final valor = _valores[index];
      widget.onResultado(valor);

      setState(() {
        _isSpinning = false;
        if (valor > 0) {
          _mensaje = "🎉 ¡Ganaste \$${valor}!";
        } else if (valor < 0) {
          _mensaje = "😢 Perdiste \$${valor.abs()}";
        } else {
          _mensaje = "😐 Empate - Sin cambios";
        }
      });
    });
  }

  Color _getColorForValue(int value) {
    if (value > 50) return Color(0xFFFFD700); // Dorado brillante
    if (value > 0) return Color(0xFFFFA500); // Naranja dorado
    if (value == 0) return Color(0xFF1a1a2e); // Oscuro
    if (value > -50) return Color(0xFFDC143C); // Rojo carmesí
    return Color(0xFF8B0000); // Rojo oscuro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a0000), // Rojo muy oscuro
              Color(0xFF2d0000),
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header elegante
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Color(0xFF1a0000)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🎲 CASINO REAL",
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFFFD700).withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Ruleta de la Fortuna",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Decoración superior
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFFFD700),
                        Color(0xFFDC143C),
                        Color(0xFFFFD700),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Ruleta
                Container(
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo decorativo exterior
                      Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFFFD700).withOpacity(0.3),
                              Color(0xFFDC143C).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Círculo intermedio
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFFFD700),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // Ruleta
                      Container(
                        width: 300,
                        height: 300,
                        child: FortuneWheel(
                          animateFirst: false, // 🎯 ¡NO GIRA AL ENTRAR!
                          selected: _controller.stream,
                          indicators: [
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 0,
                                height: 0,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.transparent,
                                      width: 20,
                                    ),
                                    right: BorderSide(
                                      color: Colors.transparent,
                                      width: 20,
                                    ),
                                    bottom: BorderSide(
                                      color: Color(0xFFFFD700),
                                      width: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          items: [
                            for (var v in _valores)
                              FortuneItem(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        _getColorForValue(v),
                                        _getColorForValue(v).withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        v > 0 
                                            ? Icons.trending_up 
                                            : v < 0 
                                                ? Icons.trending_down 
                                                : Icons.remove,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        v == 0
                                            ? "0"
                                            : (v > 0 ? "+\$$v" : "-\$${v.abs()}"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                style: FortuneItemStyle(
                                  color: _getColorForValue(v),
                                  borderColor: Color(0xFF1a1a2e),
                                  borderWidth: 3,
                                ),
                              ),
                          ],
                          rotationCount: 8,
                          duration: Duration(milliseconds: 4000),
                        ),
                      ),
                      // Centro dorado
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withOpacity(0.8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.star,
                          color: Color(0xFF1a0000),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Mensaje de resultado
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFDC143C).withOpacity(0.3),
                        Color(0xFFFFD700).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFFFFD700).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _mensaje,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 25),

                // Botón de girar
                ScaleTransition(
                  scale: _isSpinning ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isSpinning
                          ? RadialGradient(
                              colors: [
                                Color(0xFF666666),
                                Color(0xFF444444),
                              ],
                            )
                          : RadialGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFDC143C),
                              ],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSpinning ? Colors.grey : Color(0xFFFFD700))
                              .withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSpinning ? null : _girarRuleta,
                        customBorder: CircleBorder(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSpinning ? Icons.hourglass_bottom : Icons.casino,
                                color: Colors.white,
                                size: 42,
                              ),
                              SizedBox(height: 10),
                              Text(
                                _isSpinning ? "GIRANDO" : "GIRAR",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // 🔹 Botón para ir a la tragamonedas - ARREGLADO
                Container(
                  width: 280,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF9C27B0), // Morado más claro
                        Color(0xFF673AB7), // Morado profundo
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF9C27B0).withOpacity(0.5),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SlotMachinePage(
                            onResultado: widget.onResultado,
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
                    icon: Icon(
                      Icons.star,
                      color: Colors.yellowAccent,
                      size: 28,
                    ),
                    label: Text(
                      "🎰 Ir a Tragamonedas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 👈 ¡ARREGLADO! Ahora se ve bien
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Decoración inferior
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFDC143C),
                        Color(0xFFFFD700),
                        Color(0xFFDC143C),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}