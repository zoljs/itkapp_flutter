import 'package:hintful/hintful.dart';
import 'package:itk_app/ui/core/widgets/hint_tooltip.dart';

abstract class AppTours {
  static HintTour calendar() => HintTour(
        id: 'calendar',
        steps: const [
          HintStep(
            targetId: 'calendar-links',
            tooltipBuilder: buildHintTooltip,
            content: HintStepContent(
              title: 'Naptár hozzáadása',
              description: 'Itt adhatod hozzá a saját naptáraidat.',
            ),
          ),
          HintStep(
            targetId: 'calendar-datepicker',
            tooltipBuilder: buildHintTooltip,
            content: HintStepContent(
              title: 'Dátum választása',
              description: 'Itt ugorhatsz más dátumra könnyedén.',
            ),
          ),
        ],
      );

  static HintTour home() => HintTour(
        id: 'home',
        steps: const [
          HintStep(
            targetId: 'home-avatar',
            tooltipBuilder: buildHintTooltip,
            content: HintStepContent(
              title: 'Beállítások elérése',
              description: 'Itt éred el a profilod és a beállításokat.',
            ),
          ),
        ],
      );
}
