# Kiki Assets v1.0

This document records the first official Kiki Finance avatar package.
The PNG files were provided by the product owner and are treated as canon. The pipeline only removed baked-in checkerboard/background pixels and normalized the files to 1024x1024 RGBA PNGs with real transparency.

## Rules

- Do not regenerate, redraw, reinterpret, or replace these Kiki assets.
- Keep transparent PNG output in `assets/images/avatars/kiki/`.
- Render with `BoxFit.contain` and centered alignment.
- Do not clip ears, tail, paws, collar, or plate.
- Do not use white/checkerboard backgrounds.
- Use `KikiAvatarAssets` for active code paths when possible.

## Asset Inventory

| Asset | Intended use | Screen or context | Status |
| --- | --- | --- | --- |
| `kiki_master.png` | Master/reference avatar | Splash and internal reference | Integrated |
| `kiki_neutral.png` | Main avatar | Default companion/profile | Integrated |
| `kiki_wave.png` | Welcome/onboarding | Onboarding and login welcome | Integrated |
| `kiki_happy.png` | Dashboard positive state | Kiki message happy mood | Integrated |
| `kiki_thinking.png` | Insights | Prepared for insight-specific UI | Prepared, not used yet |
| `kiki_tip.png` | Tips | Prepared for advice/tip UI | Prepared, not used yet |
| `kiki_celebrating.png` | Achievements | Prepared for achievements UI | Prepared, not used yet |
| `kiki_clapping.png` | Congratulations | Prepared for celebration feedback | Prepared, not used yet |
| `kiki_saving.png` | Saving goals | Prepared for savings UI | Prepared, not used yet |
| `kiki_worried.png` | Soft warnings | Kiki warning and overbudget mood | Integrated |
| `kiki_rest.png` | Empty states | Empty home state | Integrated |
| `kiki_sad.png` | Sad state | Prepared for future states | Prepared, not used yet |
| `kiki_surprised.png` | Surprised state | Prepared for future states | Prepared, not used yet |
| `kiki_grateful.png` | Gratitude | Prepared for future states | Prepared, not used yet |
| `kiki_determinated.png` | Determined state | Prepared for future states | Prepared, not used yet |
| `kiki_motivating.png` | Motivational state | Extra provided Kiki asset | Prepared, not used yet |

## Notes

The provided source file `kiki_susprised.png` was normalized to the expected package filename `kiki_surprised.png`.
