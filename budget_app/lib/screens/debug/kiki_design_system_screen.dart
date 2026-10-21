import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design_system/components/kiki_avatar_frame.dart';
import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/components/kiki_choice_card.dart';
import '../../design_system/components/kiki_empty_state.dart';
import '../../design_system/components/kiki_info_banner.dart';
import '../../design_system/components/kiki_section_header.dart';
import '../../design_system/components/kiki_stat_card.dart';
import '../../design_system/components/kiki_text_field.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_spacing.dart';

class KikiDesignSystemScreen extends StatefulWidget {
  const KikiDesignSystemScreen({super.key});

  @override
  State<KikiDesignSystemScreen> createState() => _KikiDesignSystemScreenState();
}

class _KikiDesignSystemScreenState extends State<KikiDesignSystemScreen> {
  final _controller = TextEditingController(text: 'Cafe 1500');
  bool _selected = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(body: Center(child: Text('No disponible')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kiki Design System')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(KikiSpacing.lg),
          children: [
            const KikiSectionHeader(
              title: 'Kiki Universe',
              description: 'Visual Foundation v1.0',
            ),
            const SizedBox(height: KikiSpacing.lg),
            Wrap(
              spacing: KikiSpacing.sm,
              runSpacing: KikiSpacing.sm,
              children: const [
                _ColorSwatch('Primary', KikiColors.primary),
                _ColorSwatch('Bright', KikiColors.primaryBright),
                _ColorSwatch('Lavender', KikiColors.secondaryLavender),
                _ColorSwatch('Success', KikiColors.success),
                _ColorSwatch('Warning', KikiColors.warning),
                _ColorSwatch('Error', KikiColors.error),
              ],
            ),
            const SizedBox(height: KikiSpacing.lg),
            KikiCard(
                child: Text('KikiCard standard',
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: KikiSpacing.md),
            const KikiInfoBanner(message: 'Kiki acompana, nunca juzga.'),
            const SizedBox(height: KikiSpacing.md),
            KikiChoiceCard(
              title: 'Ahorrar mas',
              description: 'Seleccion multiple con estado visible.',
              icon: Icons.savings_outlined,
              selected: _selected,
              onTap: () => setState(() => _selected = !_selected),
              fullWidth: true,
            ),
            const SizedBox(height: KikiSpacing.md),
            const KikiStatCard(
              label: 'Resumen',
              value: '82/100',
              description: 'Lectura financiera rapida.',
              icon: Icons.insights_rounded,
            ),
            const SizedBox(height: KikiSpacing.md),
            KikiTextField(
                controller: _controller,
                label: 'Descripcion',
                hint: 'Ejemplo: Cafe 1500'),
            const SizedBox(height: KikiSpacing.md),
            const Row(
              children: [
                KikiAvatarFrame(
                    assetPath: 'assets/images/avatars/kiki/kiki_neutral.png',
                    semanticLabel: 'Kiki'),
                SizedBox(width: KikiSpacing.md),
                KikiAvatarFrame(
                    fallbackIcon: Icons.visibility_outlined,
                    semanticLabel: 'Ra'),
                SizedBox(width: KikiSpacing.md),
                KikiAvatarFrame(
                    fallbackIcon: Icons.shield_outlined, semanticLabel: 'Osi'),
              ],
            ),
            const SizedBox(height: KikiSpacing.md),
            Row(
              children: [
                Expanded(child: KikiButton(label: 'Primary', onPressed: () {})),
                const SizedBox(width: KikiSpacing.sm),
                Expanded(
                    child: KikiButton(
                        label: 'Outline',
                        variant: KikiButtonVariant.outline,
                        onPressed: () {})),
              ],
            ),
            const SizedBox(height: KikiSpacing.md),
            const KikiEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin gastos todavia',
              message: 'Un estado vacio amable y accionable.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorSwatch(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Color $label',
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(KikiSpacing.sm),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
