# H2O Admin Flutter

Aplicación de escritorio (Windows/Linux) para administrar el sistema h2o_chimal.

Requisitos:
- Flutter instalado con soporte desktop (Windows/Linux)

Run:

```bash
# desde el repo
flutter pub get
# Windows
flutter run -d windows
# Linux
flutter run -d linux
```

La app se conecta a la API REST descrita en la documentación del proyecto; configurar `ApiService.baseUrl` en `lib/services/api.dart` para apuntar a tu servidor.
