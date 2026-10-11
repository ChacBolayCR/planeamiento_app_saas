# Google Play Compliance 2026

## Avisos Revisados

- Target API Level.
- Google Play Billing Library.
- Fecha límite indicada por el PM: 31 de agosto de 2026.

## Configuración Inicial Detectada

- Flutter: 3.32.7 stable.
- Dart: 3.8.1.
- JDK usado por Flutter/Gradle: JDK 17 desde Android Studio.
- Android Gradle Plugin: 8.11.1.
- Gradle Wrapper: 8.14.
- Kotlin: 2.2.20.
- minSdk: 24.
- in_app_purchase resuelto inicialmente: 3.2.3.
- in_app_purchase_android resuelto: 0.4.0+5.
- BillingClient resuelto por Gradle: `com.android.billingclient:billing:7.1.1`.

## Configuración Final

- compileSdk efectivo: 36.
- targetSdk efectivo: 36.
- minSdk efectivo: 24.
- Package: `com.josvicdevs.kikifinance`.
- VersionCode: 8.
- VersionName: 1.0.0.
- APK release generado correctamente.
- APK debug generado correctamente, pero el emulador reportó almacenamiento insuficiente al reinstalar debug por su tamaño.

Verificación efectiva con `aapt`:

- `compileSdkVersion='36'`
- `targetSdkVersion:'36'`
- `sdkVersion:'24'`
- `application-label:'Kiki Finance'`
- `package: name='com.josvicdevs.kikifinance' versionCode='8' versionName='1.0.0'`

## Billing Library

Estado final:

- `in_app_purchase`: 3.2.3.
- `in_app_purchase_android`: 0.4.0+5.
- `com.android.billingclient:billing`: 7.1.1.
- Origen de BillingClient: plugin `in_app_purchase_android`.

Se intentó actualizar `in_app_purchase` a una versión más nueva, pero el solver falló porque las versiones que pueden resolver BillingClient 8+ requieren un SDK Dart/Flutter más nuevo que el instalado localmente.

No se agregó `implementation "com.android.billingclient:billing:8.x.x"` manualmente para evitar conflicto con el plugin oficial de Flutter.

## Resultado de Compliance

- Target SDK 36: PASA.
- Compile SDK 36: PASA.
- Android SDK Platform 36 disponible: PASA.
- APK debug compila: PASA.
- APK release compila: PASA.
- BillingClient 8.0.0 o superior: NO PASA.
- Sin BillingClient duplicado: PASA.
- Flujo Pro sin compras reales: sin cambios funcionales en este sprint.

## Riesgo Principal

Google Play Billing Library sigue en 7.1.1. Para cerrar este aviso se requiere actualizar Flutter/Dart a una versión que permita resolver una versión moderna de `in_app_purchase` / `in_app_purchase_android` compatible con Billing Library 8+.

## Pendientes Recomendados

1. Actualizar Flutter a una versión estable compatible con Dart >= 3.10 cuando sea viable.
2. Actualizar `in_app_purchase` a la versión estable que resuelva BillingClient 8+.
3. Ejecutar nuevamente `flutter pub deps` y `gradlew dependencyInsight`.
4. Verificar que BillingClient final sea 8.0.0 o superior sin dependencia directa duplicada.
5. Probar la pantalla Pro sin ejecutar compras reales.

## Hotfix 2026

Fecha de ejecución: 2026-07-30.

### Toolchain

- Flutter antes: 3.32.7 stable.
- Dart antes: 3.8.1.
- Flutter final: 3.44.8 stable.
- Dart final: 3.12.2.
- Android Gradle Plugin: 8.11.1.
- Gradle Wrapper: 8.14.
- Kotlin: 2.2.20.
- JDK: 17, Android Studio JBR.

### Billing

- `in_app_purchase` antes: 3.2.3.
- `in_app_purchase_android` antes: 0.4.0+5.
- BillingClient antes: 7.1.1.
- `in_app_purchase` final: 3.3.0.
- `in_app_purchase_android` final: 0.5.2.
- BillingClient final demostrado por Gradle: 8.0.0.
- Origen: `project :in_app_purchase_android`.

`dependencyInsight` final:

```text
com.android.billingclient:billing:8.0.0
\--- project :in_app_purchase_android
     \--- releaseRuntimeClasspath
BUILD SUCCESSFUL
```

No se agregó BillingClient manualmente en Gradle. No se activaron compras reales. El flujo Pro actual sigue siendo local/mock en `BudgetProvider`.

### Android SDK

- compileSdk efectivo: 36.
- targetSdk efectivo: 36.
- minSdk efectivo: 24.
- Android SDK Platform 36: instalado.
- Android Build Tools 36.0.0: instalado durante el hotfix.
- System image API 36: NO instalada completamente.

El intento de instalar `system-images;android-36;google_apis;x86_64` quedó bloqueado por SDK Manager:

- Primero falló por falta de espacio en disco.
- Después de `flutter clean`, hubo espacio suficiente, pero `sdkmanager` quedó en instalación parcial y timeout.
- Carpeta detectada: `system-images/android-36/google_apis/x86_64/.installer`, sin imagen completa utilizable.

### Builds

- `flutter analyze`: PASA, sin issues.
- `flutter test`: PASA, 41 tests.
- APK release: PASA.
- APK debug: generado, pero `flutter build apk --debug` terminó por timeout del wrapper después de dejar el artefacto.

Artefactos finales:

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/app-debug.apk`

### Emuladores

- AVD API 36 `Kiki_API_36`: NO creado porque la system image API36 no quedó instalada.
- Regresión API34: NO completada en este hotfix. El emulador API34 arrancó en foreground una vez y reportó boot completed, pero al iniciarlo en background ADB no lo registró como device.

### Estado Final de Compliance

- BillingClient 8+: PASA.
- compileSdk 36: PASA.
- targetSdk 36: PASA.
- APK release: PASA.
- APK debug: PARCIAL, artefacto generado con timeout del wrapper.
- Validación API36: NO PASA.
- Validación API34 post-migración: NO PASA por ADB/emulador.

Veredicto técnico del hotfix: NO GO hasta instalar correctamente la system image API36, crear `Kiki_API_36` y completar validación real en emulador.

## RC-1 Android 16 Validation

Fecha de ejecucion: 2026-07-30 / 2026-07-31.

### Revision inicial

- Workspace confirmado: `C:\dev\planeamiento_app_saas\budget_app`.
- Branch: `store-assets-v1`.
- Version: `1.0.0+8`.
- Flutter: 3.44.8 stable.
- Dart: 3.12.2.
- Android SDK usado por Flutter: `C:\Users\josvi\AppData\Local\Android\sdk`.
- JDK: Android Studio JBR 17.
- Emulador activo al iniciar: `emulator-5554`, Android 14 / API 34.
- Espacio libre inicial en C: aproximadamente 5.20 GB.

### Limpieza de instalacion parcial

Se detecto una instalacion incompleta de `system-images;android-36;google_apis;x86_64`.

Residuos eliminados:

- `C:\Users\josvi\AppData\Local\Android\sdk\system-images\android-36\google_apis\x86_64\.installer`
- `C:\Users\josvi\AppData\Local\Android\sdk\.temp\PackageOperation01`

No se eliminaron plataformas, build tools, platform-tools, emuladores existentes ni otras system images.

Se ejecuto `flutter clean` para liberar artefactos generados del proyecto. Resultado: espacio libre aproximado en C: 14.47 GB. Flutter reporto que no pudo eliminar completamente dos carpetas generated ephemeral de Linux/macOS. Mas adelante se elimino manualmente solo `linux\flutter\ephemeral\.plugin_symlinks`, generado por Flutter, para permitir que `flutter pub get` finalizara correctamente.

### Instalacion API 36

Comando intentado:

```text
sdkmanager "system-images;android-36;google_apis;x86_64"
```

Resultado:

- Intento 1: fallo con `Connection reset`.
- Intento 2: fallo con `Connection reset` despues de avanzar hasta 17% de descarga.
- Intento 3: timeout del runner; al verificar el estado real, la imagen no aparecia en `sdkmanager --list_installed` y solo quedaba `.installer` de 172 bytes.

Estado final:

- `platforms;android-36`: instalado.
- `build-tools;36.0.0`: instalado.
- `system-images;android-36;google_apis;x86_64`: NO instalada.
- `.installer` residual: limpiado tras los intentos fallidos.
- `Kiki_API_36`: NO creado porque la system image no quedo disponible.

### Validaciones locales

- `flutter pub get`: PASA.
- `dart format .`: PASA, 88 archivos revisados, 0 cambios.
- `flutter analyze`: PASA, `No issues found`.
- `flutter test`: PASA, 41 tests.
- `flutter build apk --debug`: NO PASA. El comando no finalizo limpiamente y termino por timeout del runner. Se detuvieron los procesos `dart`, `dartvm` y `java/Gradle` asociados al build vencido.
- `flutter build apk --release`: NO ejecutado en RC-1 despues del timeout de debug para evitar encadenar builds largos con el entorno en estado no confiable.

### Emulador API 36

- AVD `Kiki_API_36`: NO creado.
- `adb` API 36: NO validado.
- `sys.boot_completed` API 36: NO validado.
- Android 16: NO validado.
- Instalacion limpia API 36: NO ejecutada.
- Capturas API 36: NO generadas.

### Regresion API 34

- Emulador disponible: `Pixel_3a_API_34_extension_level_7_x86_64`.
- Estado observado al inicio: `emulator-5554` registrado como `device`, Android 14 / API 34, `sys.boot_completed = 1`.
- Regresion funcional post-RC-1: NO completada porque no se obtuvo un APK debug validado por comando finalizado limpiamente despues de `flutter clean`.

### Logcat

No se realizo captura final de logcat API 36 porque no hubo emulador API 36 disponible. No se realizo logcat final API 34 en RC-1 porque la regresion no se ejecuto con un APK debug validado.

### Veredicto RC-1 Android 16

NO GO.

Causa principal: la system image Android 16 / API 36 no pudo instalarse por fallos repetidos de descarga (`Connection reset`) y un timeout posterior de `sdkmanager`. Sin esa imagen no fue posible crear `Kiki_API_36`, arrancar Android 16, instalar la app ni generar capturas reales.

Causa secundaria: `flutter build apk --debug` no finalizo limpiamente en este intento de RC-1, aunque `flutter analyze` y `flutter test` si pasaron.
