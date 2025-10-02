import 'dart:math';
import 'package:flutter/material.dart';

class SlotMachinePage extends StatefulWidget {
  final ValueChanged<int> onResultado;
  const SlotMachinePage({Key? key, required this.onResultado}) : super(key: key);

  @override
  _SlotMachinePageState createState() => _SlotMachinePageState();
}

class _SlotMachinePageState extends State<SlotMachinePage> with TickerProviderStateMixin {
  final List<String> simbolos = ["🍒", "🍋", "🔔", "⭐", "7️⃣"];
  final Random _random = Random();

  List<String> resultado = ["❓", "❓", "❓"];
  String mensaje = "Presiona para girar 🎰";
  bool _isSpinning = false;

  late AnimationController _spin1Controller;
  late AnimationController _spin2Controller;
  late AnimationController _spin3Controller;
  late AnimationController _pulseController;

  late Animation<double> _spin1Animation;
  late Animation<double> _spin2Animation;
  late Animation<double> _spin3Animation;
  late Animation<double> _pulseAnimation;

  // Símbolos finales para cada rodillo
  String _finalSymbol1 = "❓";
  String _finalSymbol2 = "❓";
  String _finalSymbol3 = "❓";

  @override
  void initState() {
    super.initState();

    _spin1Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _spin2Controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _spin3Controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _spin1Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spin1Controller, curve: Curves.easeOut),
    );
    _spin2Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spin2Controller, curve: Curves.easeOut),
    );
    _spin3Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spin3Controller, curve: Curves.easeOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spin1Controller.dispose();
    _spin2Controller.dispose();
    _spin3Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _jugar() async {
    if (_isSpinning) return;

    // Generar símbolos finales ANTES de empezar
    _finalSymbol1 = simbolos[_random.nextInt(simbolos.length)];
    _finalSymbol2 = simbolos[_random.nextInt(simbolos.length)];
    _finalSymbol3 = simbolos[_random.nextInt(simbolos.length)];

    setState(() {
      _isSpinning = true;
      mensaje = "🎰 Girando...";
    });

    // Resetear y iniciar animaciones
    _spin1Controller.reset();
    _spin2Controller.reset();
    _spin3Controller.reset();
    
    _spin1Controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _spin2Controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _spin3Controller.forward();

    // Esperar a que termine la última animación
    await _spin3Controller.forward();

    // Actualizar resultado visible
    setState(() {
      resultado = [_finalSymbol1, _finalSymbol2, _finalSymbol3];
      _isSpinning = false;
    });

    // Calcular premio
    int premio = 0;
    if (resultado.toSet().length == 1) {
      premio = 100;
    } else if (resultado.toSet().length == 2) {
      premio = 50;
    } else {
      premio = -20;
    }

    widget.onResultado(premio);

    setState(() {
      if (premio > 0) {
        mensaje = "🎉 ¡Ganaste \$${premio}!";
      } else {
        mensaje = "😢 Perdiste \$${premio.abs()}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a0000),
              Color(0xFF2d0000),
              Color(0xFF1a1a2e),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1a0000)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "🎰 CASINO REAL",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFFD700),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Máquina Tragamonedas",
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
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 2,
                decoration: const BoxDecoration(
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

              const Spacer(flex: 2),

              // Máquina tragamonedas
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2d0000),
                        Color(0xFF1a1a2e),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título de la máquina
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "LUCKY 777",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a0000),
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contenedor para los rodillos
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFDC143C),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRodillo(animation: _spin1Animation, index: 0, finalSymbol: _finalSymbol1),
                            const SizedBox(width: 12),
                            _buildRodillo(animation: _spin2Animation, index: 1, finalSymbol: _finalSymbol2),
                            const SizedBox(width: 12),
                            _buildRodillo(animation: _spin3Animation, index: 2, finalSymbol: _finalSymbol3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Mensaje de resultado
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFDC143C).withOpacity(0.3),
                      const Color(0xFFFFD700).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),

              // Botón de jugar
              Center(
                child: ScaleTransition(
                  scale: _isSpinning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isSpinning
                          ? const RadialGradient(
                              colors: [
                                Color(0xFF666666),
                                Color(0xFF444444),
                              ],
                            )
                          : const RadialGradient(
                              colors: [
                                Color(0xFFDC143C),
                                Color(0xFF8B0000),
                              ],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSpinning ? Colors.grey : const Color(0xFFDC143C))
                              .withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSpinning ? null : _jugar,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSpinning ? Icons.hourglass_bottom : Icons.play_arrow,
                                color: Colors.white,
                                size: 42,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSpinning ? "GIRANDO" : "JUGAR",
                                style: const TextStyle(
                                  fontSize: 20,
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
              ),
              const Spacer(flex: 2),

              // Decoración inferior
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 2,
                decoration: const BoxDecoration(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRodillo({required Animation<double> animation, required int index, required String finalSymbol}) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000),
            Color(0xFF1a1a2e),
            Color(0xFF000000),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            if (!_isSpinning) {
              // Mostrar resultado final
              return Center(
                child: Text(
                  resultado[index],
                  style: const TextStyle(fontSize: 48),
                ),
              );
            }

            // Durante la animación
            // Crear una lista que termine en el símbolo final
            const symbolCount = 20;
            final symbols = List.generate(symbolCount - 1, 
              (i) => simbolos[_random.nextInt(simbolos.length)]
            )..add(finalSymbol);

            final progress = animation.value;
            const itemHeight = 100.0;
            const totalHeight = itemHeight * symbolCount;
            final offset = -(progress * totalHeight - itemHeight);

            return Transform.translate(
              offset: Offset(0, offset),
              child: Column(
                children: symbols.map((symbol) {
                  return Container(
                    width: 80,
                    height: itemHeight,
                    alignment: Alignment.center,
                    child: Text(
                      symbol,
                      style: const TextStyle(fontSize: 48),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}