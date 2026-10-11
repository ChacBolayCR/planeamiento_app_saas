# Kiki Finance Brand Guide

## Mission

Kiki Finance convierte el control del dinero en un hábito sencillo, cercano y agradable.

## Personality

Kiki acompaña, nunca juzga. Su tono es claro, amable y práctico. Ayuda al usuario a registrar gastos, entender su mes y mantener hábitos sin sentirse observado o regañado.

## Voice

- Habla en frases cortas.
- Explica antes de pedir una acción.
- Celebra el progreso real.
- Usa advertencias suaves cuando el usuario está cerca del presupuesto.
- Evita lenguaje contable pesado.

## What Kiki Does Not Say

- No promete asesoría financiera profesional.
- No usa miedo, culpa o presión.
- No promete intereses, proyecciones bancarias o resultados garantizados.
- No presenta compras o suscripciones si el flujo no está activo.

## Colors

- Primary deep: `#37206B`
- Primary: `#6542C7`
- Primary bright: `#7653E8`
- Lavender background: `#F8F5FF`
- Surface: `#FFFFFF`
- Surface soft: `#F1ECFA`
- Border: `#DED5EF`
- Success: `#4FAE63`
- Warning: `#E7A23B`
- Error: `#D95757`

## Typography

Los montos y títulos usan peso alto para escaneo rápido. El cuerpo debe mantenerse legible con textScaleFactor 1.3. No se reduce texto para ocultar overflow.

## Spacing

La escala base usa `4`, `8`, `12`, `16`, `24`, `32` y `40`. Las cards deben respirar y evitar contenido demasiado denso.

## Cards

Las cards usan superficies blancas o lavanda suave, borde ligero y sombra sutil. Se prefieren cards reutilizables del Design System sobre `Card` nativa en pantallas principales.

## Buttons

Cada pantalla debe tener una acción principal clara. Botones destructivos deben usar color de error y texto directo.

## Inputs

Inputs con borde redondeado, labels claros y hints útiles. Formularios deben respetar teclado, SafeArea y scroll.

## Iconography

Usar Material Icons Rounded para acciones y navegación. Evitar emojis en navegación, botones y cards financieras. Los emojis solo pueden aparecer en mensajes conversacionales intencionales.

## Mascot Usage

Kiki debe tener presencia, pero no invadir. Usar assets transparentes oficiales, `BoxFit.contain`, sin círculos que recorten orejas, patas o placa.

## Mood Engine

Mood Engine V1 selecciona visuales locales según estado ya calculado:

- `noExpenses`: `kiki_wave`
- `healthy`: `kiki_happy`
- `warning`: `kiki_worried`
- `overBudget`: `kiki_sad`
- `goalProgress`: `kiki_saving`
- `achievement`: `kiki_celebrating`
- `inactive`: `kiki_rest`

## Empty States

Estados vacíos deben explicar qué falta, por qué importa y cuál es la acción siguiente. Usar Kiki Rest cuando la pantalla no tiene datos.

## Success Messages

Celebrar progreso sin exagerar. Ejemplo: "Una cuota menos. Tu saldo pendiente es de ₡X."

## Warning Messages

Advertir con calma. Ejemplo: "Estás cerca de tu presupuesto. Todavía puedes ajustar el ritmo."

## Future Skins

Las futuras skins deben preservar legibilidad entre 48 y 128 px, transparencia real y proporciones consistentes.

## Ra

Ra queda reservado para un sprint futuro con assets oficiales. No usar imágenes temporales como opción seleccionable.

## Osi

Osi queda reservado para un sprint futuro con assets oficiales. No usar imágenes temporales como opción seleccionable.

## Future Plans

- Individual: experiencia personal simple.
- Duo: espacio compartido para dos personas.
- Familiar: organización de gastos y compromisos del hogar.
