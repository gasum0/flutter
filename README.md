# 📌 Guía de Configuración, GitHub y Build APK en Flutter

## ⚙️ 1. Preparar el proyecto Flutter
Antes de cualquier cosa, asegúrate de tener **Flutter** instalado y configurado en tu entorno.

```bash
# Instalar dependencias del proyecto
flutter pub get
```

---

## 📱 2. Generar APK en modo Release
Una vez subido el proyecto y comprobado que funciona, puedes generar el APK:

```bash
# Generar el APK optimizado para producción
flutter build apk --release
```

Esto generará el archivo en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ 3. Buenas prácticas
- Siempre ejecuta `flutter pub get` al agregar nuevas dependencias.  
- Antes de hacer **push**, confirma que compila bien:  
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```
- Cuando termines una nueva funcionalidad:  
  ```bash
  git add .
  git commit -m "Descripción de cambios"
  git push
  ```
