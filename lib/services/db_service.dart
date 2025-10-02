import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;
  // ID del usuario actualmente logueado (null = no hay sesión)
  static int? _currentUserId;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movimientos.db');

    return await openDatabase(
      path,
      version: 3, // subimos a 3 para incluir usuarios y columnas usuario_id
      onCreate: (db, version) async {
        // tabla usuarios
        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // tabla movimientos (incluye usuario_id)
        await db.execute('''
          CREATE TABLE movimientos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            categoria TEXT NOT NULL,
            monto REAL NOT NULL,
            fecha TEXT NOT NULL,
            usuario_id INTEGER
          )
        ''');

        // tabla cierres (incluye usuario_id)
        await db.execute('''
          CREATE TABLE cierres(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            saldo REAL NOT NULL,
            usuario_id INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Si la DB era versión 1 -> 2 (ya tenía movimientos), y ahora actualizamos a 3,
        // tenemos que crear la tabla cierres (si aún no existe) y usuarios, y añadir columnas.
        if (oldVersion < 2) {
          // crear tabla cierres (por si venías de versión 1)
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cierres(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fecha TEXT NOT NULL,
              saldo REAL NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          // Crear tabla usuarios si no existe
          await db.execute('''
            CREATE TABLE IF NOT EXISTS usuarios(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              email TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL
            )
          ''');

          // Agregar columna usuario_id a movimientos (si no existe)
          try {
            await db.execute("ALTER TABLE movimientos ADD COLUMN usuario_id INTEGER");
          } catch (e) {
            // ignore si ya existe
          }

          // Agregar columna usuario_id a cierres (si no existe)
          try {
            await db.execute("ALTER TABLE cierres ADD COLUMN usuario_id INTEGER");
          } catch (e) {
            // ignore si ya existe
          }
        }
      },
    );
  }

  // ------------------ SESSIÓN ------------------
  static void setCurrentUserId(int? id) {
    _currentUserId = id;
  }

  static int? getCurrentUserId() => _currentUserId;

  static Future<void> logout() async {
    _currentUserId = null;
  }

  // ------------------ USUARIOS ------------------
  /// Registra un usuario. Devuelve el id insertado.
  static Future<int> registrarUsuario(String nombre, String email, String password) async {
    final db = await getDB();

    // verificar si email ya existe
    final exist = await db.query('usuarios', where: 'email = ?', whereArgs: [email]);
    if (exist.isNotEmpty) {
      throw Exception('El email ya está registrado');
    }

    return await db.insert('usuarios', {
      'nombre': nombre,
      'email': email,
      'password': password, // recomendado: hashear en producción
    });
  }

  /// Intenta iniciar sesión con email/password.
  /// Si encuentra usuario, lo devuelve (Map) y además setea _currentUserId.
  static Future<Map<String, dynamic>?> loginUsuario(String email, String password) async {
    final db = await getDB();
    final res = await db.query(
      'usuarios',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) {
      final user = res.first;
      _currentUserId = user['id'] as int?;
      return user;
    }
    return null;
  }

  /// Obtener usuario por id
  static Future<Map<String, dynamic>?> obtenerUsuarioPorId(int id) async {
    final db = await getDB();
    final res = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // ------------------ Movimientos ------------------
  /// Inserta movimiento y lo asocia al usuario actual si existe.
  static Future<int> insertarMovimiento(
      String tipo, String categoria, double monto,
      {int? usuarioId}) async {
    final db = await getDB();
    final int? uid = usuarioId ?? _currentUserId;
    final Map<String, dynamic> row = {
      'tipo': tipo,
      'categoria': categoria,
      'monto': monto,
      'fecha': DateTime.now().toIso8601String(),
    };
    if (uid != null) row['usuario_id'] = uid;
    return await db.insert('movimientos', row);
  }

  /// Obtener movimientos del usuario actual (si hay sesión) o todos si no.
  static Future<List<Map<String, dynamic>>> obtenerMovimientos() async {
    final db = await getDB();
    if (_currentUserId != null) {
      return await db.query('movimientos',
          where: 'usuario_id = ?', whereArgs: [_currentUserId], orderBy: 'fecha DESC');
    } else {
      return await db.query('movimientos', orderBy: 'fecha DESC');
    }
  }

  /// Obtener movimientos por día (filtrados por usuario si hay sesión)
  static Future<List<Map<String, dynamic>>> obtenerMovimientosPorDia(DateTime fecha) async {
    final db = await getDB();
    final dia = _toDateString(fecha); // 'YYYY-MM-DD'
    if (_currentUserId != null) {
      return await db.query('movimientos',
          where: "date(fecha) = ? AND usuario_id = ?",
          whereArgs: [dia, _currentUserId],
          orderBy: 'fecha DESC');
    } else {
      return await db.query('movimientos',
          where: "date(fecha) = ?", whereArgs: [dia], orderBy: 'fecha DESC');
    }
  }

  /// Calcular saldo del día (filtrado por usuario si hay sesión)
  static Future<double> calcularSaldoDelDia(DateTime fecha) async {
    final db = await getDB();
    final dia = _toDateString(fecha);
    if (_currentUserId != null) {
      final result = await db.rawQuery('''
        SELECT SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE -monto END) as saldo
        FROM movimientos
        WHERE date(fecha) = ? AND usuario_id = ?
      ''', [dia, _currentUserId]);

      final value = result.first['saldo'];
      if (value == null) return 0.0;
      return (value as num).toDouble();
    } else {
      final result = await db.rawQuery('''
        SELECT SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE -monto END) as saldo
        FROM movimientos
        WHERE date(fecha) = ?
      ''', [dia]);

      final value = result.first['saldo'];
      if (value == null) return 0.0;
      return (value as num).toDouble();
    }
  }

  /// Eliminar movimientos de un día (filtrado por usuario si hay sesión)
  static Future<int> eliminarMovimientosPorDia(DateTime fecha) async {
    final db = await getDB();
    final dia = _toDateString(fecha);
    if (_currentUserId != null) {
      return await db.delete('movimientos', where: "date(fecha) = ? AND usuario_id = ?", whereArgs: [dia, _currentUserId]);
    } else {
      return await db.delete('movimientos', where: "date(fecha) = ?", whereArgs: [dia]);
    }
  }

  // ------------------ Cierres diarios ------------------
  /// Inserta cierre asociado al usuario actual si existe.
  static Future<int> insertarCierre(double saldo, {int? usuarioId}) async {
    final db = await getDB();
    final int? uid = usuarioId ?? _currentUserId;
    final Map<String, dynamic> row = {
      'fecha': DateTime.now().toIso8601String(),
      'saldo': saldo,
    };
    if (uid != null) row['usuario_id'] = uid;
    return await db.insert('cierres', row);
  }

  static Future<List<Map<String, dynamic>>> obtenerCierres() async {
    final db = await getDB();
    if (_currentUserId != null) {
      return await db.query('cierres', where: 'usuario_id = ?', whereArgs: [_currentUserId], orderBy: 'fecha DESC');
    } else {
      return await db.query('cierres', orderBy: 'fecha DESC');
    }
  }

  // ------------------ UTIL ------------------
  static String _toDateString(DateTime d) {
    return d.toIso8601String().split('T').first;
  }

  static Future<void> cerrarDB() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
