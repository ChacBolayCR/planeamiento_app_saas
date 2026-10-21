# Kiki Android GitHub Actions Pipeline

## Objetivo

El workflow `Kiki Android Release` valida y compila Kiki Finance en GitHub Actions para evitar depender del equipo local. Ejecuta formato, análisis, tests, verificación de BillingClient, APK release, AAB release firmado, verificación de firma y subida de artefactos.

No publica en Google Play. La publicación queda para un paso manual posterior.

## Arquitectura

Archivo:

`.github/workflows/kiki-android-release.yml`

Proyecto Flutter:

`budget_app`

Toolchain:

- Flutter `3.44.8` stable
- Dart incluido con Flutter
- Java `17` Temurin
- Android SDK Platform `36`
- Android Build Tools `36.0.0`
- Gradle configurado por `gradle/actions/setup-gradle@v4`

## Triggers

El workflow se puede ejecutar manualmente con `workflow_dispatch`.

También corre en `push` a `store-assets-v1` solo cuando cambian:

- `budget_app/**`
- `.github/workflows/kiki-android-release.yml`

La concurrencia cancela ejecuciones antiguas de la misma rama:

`kiki-android-${{ github.ref }}`

## Secrets Requeridos

Configurar estos Repository Secrets en GitHub:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

El workflow falla si falta cualquiera de ellos. Nunca usa firma debug como fallback.

## Convertir Keystore a Base64 en PowerShell

Ejecutar localmente:

```powershell
[Convert]::ToBase64String(
    [IO.File]::ReadAllBytes("RUTA_AL_KEYSTORE.jks")
) | Set-Content ".\keystore-base64.txt"
```

Luego:

1. Abrir `keystore-base64.txt`.
2. Copiar todo el contenido.
3. Crear el secret `ANDROID_KEYSTORE_BASE64` en GitHub.
4. Borrar `keystore-base64.txt`.

`keystore-base64.txt` no debe agregarse al repositorio. Las contraseñas nunca deben incluirse en commits, documentación ni logs.

## Agregar Secrets en GitHub

1. Abrir el repositorio en GitHub.
2. Ir a `Settings`.
3. Abrir `Secrets and variables`.
4. Seleccionar `Actions`.
5. Crear los cuatro Repository Secrets requeridos.

No usar Environment Secrets todavía, salvo que el equipo decida proteger releases con reviewers.

## Ejecución Manual

1. Hacer commit del workflow y documentación.
2. Hacer push a `store-assets-v1`.
3. Abrir GitHub.
4. Ir a `Actions`.
5. Elegir `Kiki Android Release`.
6. Presionar `Run workflow`.
7. Seleccionar branch `store-assets-v1`.
8. Esperar la finalización.
9. Descargar artefactos.

## Artefactos

El workflow genera dos artefactos por 14 días:

`kiki-release-files-${{ github.run_number }}`

Incluye:

- `budget_app/build/app/outputs/flutter-apk/app-release.apk`
- `budget_app/build/app/outputs/bundle/release/app-release.aab`
- `budget_app/pubspec.yaml`
- `budget_app/pubspec.lock`

`kiki-build-reports-${{ github.run_number }}`

Incluye:

- `budget_app/build/reports/billing-dependency.txt`
- `budget_app/build/reports/billing-version.txt`
- `budget_app/build/reports/apk-sha256.txt`
- `budget_app/build/reports/aab-sha256.txt`
- `budget_app/build/reports/jarsigner-report.txt`
- `budget_app/build/reports/build-summary.md`

No se suben keystores, `key.properties`, archivos `.env`, heap dumps ni secretos.

## Verificar el AAB

El workflow ejecuta:

```bash
jarsigner -verify -verbose -certs budget_app/build/app/outputs/bundle/release/app-release.aab
```

Debe aparecer:

```text
jar verified.
```

También genera SHA-256 para APK y AAB.

## BillingClient 8

El workflow ejecuta `dependencyInsight` sobre `releaseRuntimeClasspath` y guarda la salida en:

`budget_app/build/reports/billing-dependency.txt`

Luego extrae la versión efectiva de:

`com.android.billingclient:billing`

El build falla si la versión mayor es inferior a `8`.

## Cambiar VersionCode

Para una nueva subida a Play Console, cambiar solo:

`budget_app/pubspec.yaml`

Ejemplo:

```yaml
version: 1.0.0+9
```

Después confirmar en el summary:

- `versionName = 1.0.0`
- `versionCode = 9`

## Si Falla el Build

Revisar en este orden:

1. `kiki-build-reports`.
2. Logs de `flutter analyze`.
3. Logs de `flutter test`.
4. `billing-dependency.txt`.
5. `jarsigner-report.txt`.
6. Salida de Gradle.

Si falla por falta de secrets, configurar los cuatro secrets y volver a ejecutar.

Si falla por firma, validar que el alias y contraseñas correspondan al mismo keystore.

## Strip Debug Symbols

Si Flutter devuelve un fallo posterior al build relacionado con strip debug symbols, el workflow no lo ignora automáticamente. Primero exige:

- AAB existente.
- Tamaño mayor que cero.
- Firma verificada con `jarsigner`.

Si esos puntos pasan, deja una nota en `aab-build-note.txt` para revisión manual.

## Archivos Que Nunca Deben Subirse

- `android/key.properties`
- `android/app/*.jks`
- `android/app/*.keystore`
- `keystore-base64.txt`
- `.env`
- heap dumps `*.hprof`
- contraseñas o claves privadas

## Retención

Los artefactos se conservan por 14 días.

## Futuro

Cuando el equipo apruebe publicación automatizada, se puede agregar un job separado para subir a Closed Testing usando credenciales de Play Console. Ese paso debe quedar protegido por environment reviewers y no debe mezclarse con este workflow de build.
