# Kiki Design System v1.0

Internal name: Kiki Universe - Visual Foundation.

Guide phrase: Kiki Finance convierte el control del dinero en un habito sencillo, cercano y agradable.

## Philosophy

1. Kiki acompana, nunca juzga.
2. The app should feel simple before it feels powerful.
3. Every screen needs one clear primary action.
4. Do not show too many decisions at the same time.
5. Explain before asking.
6. Financial data should be readable in seconds.
7. Avoid a banking, accounting, or corporate look.
8. Keep the tone modern, close, and trustworthy.
9. Characters accompany, they do not saturate.
10. Accessibility is never traded for style.

## Palette

- primaryDeep: #37206B, identity, high emphasis headings.
- primary: #6542C7, main actions and selected states.
- primaryBright: #7653E8, FAB and energetic accents.
- secondaryLavender: #A78BFA, secondary brand accent.
- background: #F8F5FF, app background with soft lavender tint.
- surface: #FFFFFF, cards, sheets, dialogs.
- surfaceSoft: #F1ECFA, selected cards and gentle panels.
- border: #DED5EF, low contrast outlines.
- textPrimary: #281D3F, main copy and numbers.
- textSecondary: #6F657C, explanations and labels.
- textDisabled: #A59DAC, disabled controls.
- success: #4FAE63, positive states.
- successSoft: #E7F6EA, positive backgrounds.
- warning: #E7A23B, attention states.
- warningSoft: #FFF3DD, warning backgrounds.
- error: #D95757, destructive and error states.
- errorSoft: #FDEAEA, error backgrounds.
- info: #4F7ECF, informational states.
- infoSoft: #EAF1FD, informational backgrounds.

## Typography

Use the platform font. Do not add font dependencies until there is a product reason. Amounts use strong weight and clear spacing. Avoid weight 900 as a default; reserve it for hero-level emphasis.

Semantic styles live in `KikiTypography`: display, headline, titleLarge, titleMedium, bodyLarge, bodyMedium, labels, amountLarge, amountMedium.

## Spacing

Scale: xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, section 40.

Use lg for screen padding, md/lg inside cards and forms, xl between major blocks.

## Radius

- small 10: compact controls.
- medium 16: inputs and buttons.
- large 22: cards and modal surfaces.
- pill 999: progress, chips, badges.

## Shadows

Prefer borders and soft surface contrast. Use subtle shadow for cards, card shadow sparingly, floatingAction only for elevated actions.

## Components

- KikiCard: standard visual surface with semantic variants.
- KikiButton: primary, secondary, outline, text, destructive, loading, disabled.
- KikiIconButton: icon action with tooltip.
- KikiSectionHeader: title, optional description, optional action.
- KikiInfoBanner: neutral, success, warning, error.
- KikiChoiceCard: onboarding and preference selection.
- KikiStatCard: label, amount/value, description, icon.
- KikiTextField: themed form field wrapper.
- KikiAvatarFrame: local asset or Material Icon fallback, circular, BoxFit.contain.
- KikiEmptyState: friendly empty states.

## Iconography

Use Material Icons Rounded-style choices where possible. Navigation and actions should use icons, not emojis. Emojis can remain only in conversational Kiki messages when intentional.

## Rules For Kiki, Ra And Osi

Future official avatars must share the same art direction: consistent proportions, soft lighting, transparent background, safe area around ears and head, close expression, no extra limbs, no inconsistent accessories, collar and identifying tag, readable between 48 and 128 px. Planned variants: neutral, happy, thinking, celebrating, worried.

## Accessibility

Support text scale 1.3, 320 px width, visible selected states beyond color, touch targets near 48 px, SafeArea in sheets/screens, no important ellipsis, complete financial amounts.

## Good Practices

- Use semantic tokens, not raw hex values in active widgets.
- Use KikiCard for repeated card surfaces.
- Use KikiChoiceCard for selections.
- Explain concepts before requesting input.

## Bad Practices

- Heavy black shadows.
- Corporate/banking palettes.
- Decorative characters that compete with financial data.
- Multiple primary CTAs on one screen.
- Hardcoded colors in migrated screens.

## Migrated Screens

- Onboarding: buttons, choice cards, avatar frame, info card/header style.
- Profile: primary cards, avatar frame, buttons, spacing.
- AddExpenseModal: themed fields, spacing, CTA, highlighted info card.
- Dashboard: background via theme, Kiki message, financial summary cards, commitments card.

## Pending Screens

Expenses list, commitments details, charts, Kiki Pro, auth, legacy screens, debug-only screens outside the gallery.
