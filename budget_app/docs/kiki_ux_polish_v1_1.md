# Kiki UX Polish + Featured Image Alignment v1.1

## Workspace

- Proyecto: `C:\dev\planeamiento_app_saas\budget_app`
- Branch validada: `store-assets-v1`
- App: Kiki Finance
- Package: `com.josvicdevs.kikifinance`
- Version durante el sprint: `1.0.0+8`

## Featured Image

No se encontró un archivo separado de Feature Graphic oficial dentro del repositorio en `assets/`, `store-assets/`, `docs/`, `play-store/` o `marketing/`.

La fase de alineación visual se aplicó usando la dirección visual ya incorporada al Design System: fondo lavanda, tarjetas blancas, morado principal, bordes suaves, jerarquía clara y protagonismo de Kiki. Queda pendiente incorporar la ruta oficial del Feature Graphic cuando el asset esté dentro del repo.

## Hallazgos Corregidos

- Splash nativo: reemplazado el launcher icon como imagen central por Kiki Master en recursos nativos.
- Splash Android 12+: se agregó una copia nativa con padding transparente para que Kiki se vea completa dentro de la máscara del sistema.
- Onboarding: Kiki Wave ya no está dentro de círculo decorativo; se muestra directa sobre el fondo con `BoxFit.contain`.
- Login: Kiki Wave visible, sin círculo y con jerarquía visual más cercana al sistema de diseño.
- Flujo inicial: el acceso invitado regresa al `OnboardingGate`, permitiendo mostrar onboarding de personalización antes del Dashboard si no fue completado.
- Perfil: el botón `Cambiar` ya no navega al onboarding.
- Selector de compañero: nuevo bottom sheet reutilizable que muestra solo Kiki como disponible.
- Gastos vacío: ahora usa `kiki_rest.png`, texto amigable y CTA para agregar el primer gasto.

## Flujo de Primer Usuario

Instalación limpia:

1. Splash nativo.
2. Login.
3. `Entrar sin cuenta`.
4. `OnboardingGate`.
5. Onboarding de personalización si `FinancialProfile.onboardingCompleted` es `false`.
6. Dashboard al omitir o completar.

Usuario existente:

1. Abre la app.
2. `OnboardingGate` carga `FinancialProfileProvider`.
3. Si `onboardingCompleted` es `true`, entra directamente al Dashboard.

Flags principales:

- `financial_profile_v1`: perfil financiero local en SharedPreferences.
- `onboardingCompleted`: controla si el onboarding se muestra.
- Firebase Auth / invitado: controla si se muestra Login antes del gate de personalización.

## Selector de Compañero

El selector se implementó como bottom sheet y usa una fuente centralizada:

- `CompanionDefinition`
- `CompanionCatalog`

Estado actual:

- Kiki: disponible, usa `assets/images/avatars/kiki/kiki_neutral.png`.
- Ra/Osi: no se muestran como opciones seleccionables hasta que existan assets oficiales.

## Pantallas Alineadas

- Splash: fondo lavanda, Kiki Master, sin launcher icon anterior.
- Login: Kiki Wave, fondo lavanda, botones morados y campos suaves.
- Onboarding: Kiki Wave sin círculo, botones y cards consistentes.
- Dashboard: tarjetas suaves, jerarquía financiera clara, Kiki en mensaje del mes.
- Perfil: tarjeta del compañero como punto natural para el selector.
- Gastos vacío: Kiki Rest, mensaje claro y CTA.

## Capturas

Guardadas en:

`docs/review/build9-ux-polish/`

- `01_native_splash.png`
- `02_login.png`
- `03_onboarding.png`
- `04_dashboard.png`
- `05_profile.png`
- `06_companion_selector.png`
- `07_expenses_empty.png`

## Validación en Emulador

- Emulador usado: `Pixel_3a_API_34_extension_level_7_x86_64`
- Device: `emulator-5554`
- API 34 validado.
- API 36 no se validó en emulador porque no existe system image API 36 instalada localmente.

Resultados:

- Splash inicia sin launcher icon anterior.
- Login muestra Kiki Wave.
- Onboarding no tiene círculo cortando a Kiki.
- Dashboard abre después de onboarding omitido.
- Usuario existente no repite onboarding.
- Perfil abre selector de compañero.
- Gastos vacío muestra Kiki Rest.
- Logcat no mostró `RenderFlex overflow`, errores de assets ni crashes de Flutter durante la revisión.

## Pendientes

- Agregar Feature Graphic oficial al repositorio y documentar su ruta.
- Validar el mismo flujo en emulador Android API 36 cuando exista una system image instalada.
- Incorporar assets oficiales de Ra y Osi en un sprint posterior.
- Revisar si el splash Android 12+ debe usar una solución generada por `flutter_native_splash`; actualmente el proyecto no usa ese paquete.
