import '../widgets/kiki_message_card.dart';
import 'kiki_avatar_assets.dart';

class KikiMoodVisual {
  final KikiMood mood;
  final String assetPath;
  final String title;
  final String message;
  final String semanticState;

  const KikiMoodVisual({
    required this.mood,
    required this.assetPath,
    required this.title,
    required this.message,
    required this.semanticState,
  });

  factory KikiMoodVisual.fromBudgetState({
    required bool hasExpenses,
    required double budget,
    required double spent,
    required int achievementsCount,
    required int streak,
  }) {
    if (!hasExpenses) {
      return const KikiMoodVisual(
        mood: KikiMood.noExpenses,
        assetPath: KikiAvatarAssets.wave,
        title: 'Empieza suave',
        message:
            'Registra tu primer gasto y Kiki te ayudará a ver el mes con claridad.',
        semanticState: 'Sin gastos registrados',
      );
    }

    if (achievementsCount > 0 || streak >= 5) {
      return const KikiMoodVisual(
        mood: KikiMood.achievement,
        assetPath: KikiAvatarAssets.celebrating,
        title: 'Buen ritmo',
        message: 'Tus hábitos ya están tomando forma. Sigue así, paso a paso.',
        semanticState: 'Logro o racha activa',
      );
    }

    if (budget > 0 && spent >= budget) {
      return const KikiMoodVisual(
        mood: KikiMood.overBudget,
        assetPath: KikiAvatarAssets.sad,
        title: 'Cuidemos el cierre',
        message:
            'Ya pasaste el presupuesto del mes. Revisa tus próximos gastos con calma.',
        semanticState: 'Presupuesto excedido',
      );
    }

    if (budget > 0 && spent >= budget * 0.85) {
      return const KikiMoodVisual(
        mood: KikiMood.warning,
        assetPath: KikiAvatarAssets.worried,
        title: 'Cerca del límite',
        message:
            'Estás cerca de tu presupuesto. Todavía puedes ajustar el ritmo.',
        semanticState: 'Cerca del presupuesto',
      );
    }

    if (budget > 0 && spent <= budget * 0.5) {
      return const KikiMoodVisual(
        mood: KikiMood.goalProgress,
        assetPath: KikiAvatarAssets.saving,
        title: 'Vas con margen',
        message:
            'Tu mes va ordenado. Kiki mantiene tus números importantes a mano.',
        semanticState: 'Buen margen de presupuesto',
      );
    }

    return const KikiMoodVisual(
      mood: KikiMood.healthy,
      assetPath: KikiAvatarAssets.happy,
      title: 'Mes en movimiento',
      message:
          'Ya tienes datos suficientes para entender mejor tus gastos del mes.',
      semanticState: 'Gastos saludables',
    );
  }
}
