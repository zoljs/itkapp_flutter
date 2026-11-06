import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';

class SettingsAvatarButton extends StatelessWidget {
  const SettingsAvatarButton({
    super.key,
    required this.onAvatarTap,
    required this.login,
  });

  final VoidCallback onAvatarTap;
  final String? login;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      semanticLabel: "Beállítások",
      shape: const CircleBorder(),
      onTap: onAvatarTap,
      child: Hero(
        transitionOnUserGestures: false,
        tag: SettingsScreen.heroTag,
        child: UserAvatar(
          fontSize: 24,
          radius: 24,
          login: login,
          color: itkPrimary,
        ),
      ),
    );
  }
}
