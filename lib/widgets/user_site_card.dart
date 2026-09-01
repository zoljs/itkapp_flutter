import 'package:itk_app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

class UserSiteCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final double? height;
  final void Function() onTap;

  const UserSiteCard(
      {super.key,
      required this.color,
      required this.child,
      this.height,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.5)!,
            color.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.12)!,
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
