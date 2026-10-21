# Kiki Finance Release Checklist

## UX Polish v1.1

- [x] Splash nativo no usa el launcher icon anterior como imagen central.
- [x] Splash muestra Kiki Master.
- [x] Splash usa fondo coherente con Kiki Finance.
- [x] Onboarding muestra Kiki Wave sin círculo decorativo.
- [x] Onboarding no corta orejas, pata, collar ni placa.
- [x] Instalación limpia muestra Login antes del onboarding de personalización.
- [x] Acceso invitado pasa por `OnboardingGate`.
- [x] Usuario existente no repite onboarding.
- [x] Botón `Cambiar` en Perfil abre selector de compañero.
- [x] Selector muestra Kiki como única opción disponible.
- [x] Ra y Osi no aparecen como opciones seleccionables.
- [x] Gastos vacío muestra `kiki_rest.png`.
- [x] Dashboard validado en emulador API 34 durante UX polish.
- [x] Perfil validado en emulador API 34 durante UX polish.
- [x] Android 12+ splash revisado.
- [x] Capturas generadas en `docs/review/build9-ux-polish/`.

## Google Play Compliance 2026

- [x] targetSdk efectivo es 36.
- [x] compileSdk efectivo es 36.
- [x] BillingClient efectivo es 8.0.0 o superior.
- [x] No existen dependencias Billing duplicadas detectadas.
- [ ] Build debug pasa sin timeout del wrapper.
- [x] Build release pasa.
- [ ] Prueba Android API 36 pasa.
- [ ] Regresión Android API 34 post-Billing-8 pasa.
- [x] Edge-to-edge revisado visualmente en API 34 durante UX polish.
- [x] Barras del sistema revisadas en API 34 durante UX polish.
- [x] Flujo Pro no fue modificado.
- [x] Compras reales no se ejecutaron durante QA.

## Bloqueos

- System image Android API 36 quedó en instalación parcial por timeout de SDK Manager.
- ADB no registró el emulador API34 en el intento final de regresión post-migración.
- `flutter build apk --debug` generó artefacto, pero el wrapper terminó por timeout.
- No se encontró Feature Graphic oficial dentro del repositorio.

## RC-1 Android 16 Validation

- [x] Workspace real confirmado: `C:\dev\planeamiento_app_saas\budget_app`.
- [x] Branch confirmada: `store-assets-v1`.
- [x] Version confirmada: `1.0.0+8`.
- [x] Flutter confirmado: 3.44.8 stable.
- [x] Dart confirmado: 3.12.2.
- [x] Android SDK confirmado: `C:\Users\josvi\AppData\Local\Android\sdk`.
- [x] Espacio liberado antes de reinstalar API 36: aproximadamente 14.47 GB libres.
- [x] Instalacion parcial API 36 limpiada sin eliminar AVDs ni SDKs funcionales.
- [x] `platforms;android-36` instalado.
- [x] `build-tools;36.0.0` instalado.
- [ ] `system-images;android-36;google_apis;x86_64` instalada completamente.
- [ ] Sin `.installer` parcial durante instalacion final exitosa.
- [ ] AVD `Kiki_API_36` creado.
- [ ] Emulador Android 16 iniciado.
- [ ] `adb` muestra API 36 como `device`.
- [ ] `sys.boot_completed = 1` en API 36.
- [ ] `ro.build.version.sdk = 36`.
- [ ] `ro.build.version.release = 16`.
- [x] `flutter pub get` pasa.
- [x] `dart format .` pasa, 0 cambios.
- [x] `flutter analyze` pasa.
- [x] `flutter test` pasa, 41 tests.
- [ ] `flutter build apk --debug` termina limpiamente.
- [ ] `flutter build apk --release` revalidado en RC-1 despues de debug.
- [ ] App instalada en API 36.
- [ ] Flujo principal validado en API 36.
- [ ] Seccion Pro abierta sin crash en API 36.
- [ ] Regresion API 34 completada despues de RC-1.
- [ ] Capturas reales generadas en `docs/review/build9-compliance/`.

### Bloqueos RC-1

- `sdkmanager "system-images;android-36;google_apis;x86_64"` fallo repetidamente por `Connection reset` y luego timeout del runner.
- La system image API 36 no quedo instalada; por eso no se pudo crear `Kiki_API_36`.
- `flutter build apk --debug` no finalizo limpiamente y se detuvieron sus procesos asociados.
- No se generaron capturas nuevas porque no hubo emulador API 36 ni APK debug validado por comando completo.

## RC-2 Aurora Release Build Recovery

- [x] Workspace real confirmado: `C:\dev\planeamiento_app_saas\budget_app`.
- [x] Branch confirmada: `store-assets-v1`.
- [x] Version confirmada: `1.0.0+8`.
- [x] `flutter pub get` pasa.
- [x] `dart format lib test` pasa.
- [x] `flutter analyze` pasa: No issues found.
- [x] `flutter test` pasa: 43 tests.
- [ ] `flutter build apk --release` pasa.
- [ ] APK release verificado.
- [ ] Instalacion limpia en emulador API 34 completada.
- [ ] Capturas reales generadas en `docs/review/aurora-rc2/`.

### Bloqueo RC-2 Aurora Release Build Recovery

- `flutter build apk --release` falla en `:app:mergeDexRelease` por `java.lang.OutOfMemoryError: Java heap space` durante D8 dex merge.
- Se corrigio el crash nativo previo de Gradle reduciendo `org.gradle.jvmargs` desde `-Xmx8G -XX:MaxMetaspaceSize=4G` a `-Xmx3072m -XX:MaxMetaspaceSize=512m -Dfile.encoding=UTF-8`, con `org.gradle.parallel=false`.
- Con `-Xmx1536m`, `-Xmx2048m` y `-Xmx3072m`, el build siguio fallando por heap insuficiente en D8/R8.
- Memoria fisica libre observada antes de detener intentos: aproximadamente 2.1 GB; no se ejecuto un intento a 4 GB para evitar repetir el bloqueo de memoria del entorno.
- Se eliminaron heap dumps temporales `android/java_pid*.hprof` generados por los OOM.

## GitHub Actions Android Pipeline v1.0

- [x] Workflow GitHub Actions existe: `.github/workflows/kiki-android-release.yml`.
- [ ] Secrets configurados en GitHub.
- [x] Workflow usa Flutter `3.44.8` stable.
- [x] Workflow usa Java `17` Temurin.
- [x] Workflow instala/verifica Android SDK `platforms;android-36`.
- [x] Workflow instala/verifica Android Build Tools `36.0.0`.
- [x] Workflow valida package `com.josvicdevs.kikifinance`.
- [x] Workflow valida `compileSdk = 36`.
- [x] Workflow valida `targetSdk = 36`.
- [x] Format check configurado con `dart format --output=none --set-exit-if-changed lib test`.
- [x] Analyze configurado.
- [x] Tests configurados.
- [x] BillingClient 8+ verificado con `dependencyInsight`.
- [x] APK release configurado.
- [x] AAB release firmado configurado.
- [x] Firma AAB verificada con `jarsigner`.
- [x] Hashes SHA-256 configurados para APK y AAB.
- [x] Artefactos de release configurados.
- [x] Reportes de build configurados.
- [x] Limpieza de archivos sensibles configurada con `if: always()`.
- [x] Documentacion creada: `docs/github_actions_android_pipeline.md`.
- [ ] Primer run manual ejecutado en GitHub Actions.
- [ ] APK release generado en GitHub Actions.
- [ ] AAB release generado en GitHub Actions.
- [ ] Firma verificada en GitHub Actions.
- [ ] Artefactos descargados.
- [ ] AAB probado en Play Console.

### Secrets requeridos para el pipeline

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

### Notas de seguridad del pipeline

- El workflow falla si falta cualquier secret.
- El workflow no usa debug signing como fallback.
- El keystore se restaura temporalmente como `budget_app/android/app/upload-keystore.jks`.
- `budget_app/android/key.properties` se genera temporalmente en CI.
- Ambos archivos temporales se eliminan al final con `if: always()`.
