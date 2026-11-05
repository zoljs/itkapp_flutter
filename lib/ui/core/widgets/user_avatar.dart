import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.login,
    this.radius = 45,
    this.fontSize = 28,
    required this.color,
  });

  final String? login;
  final double radius;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final login = this.login;
    final initial =
        login == null || login.isEmpty ? 'U' : login[0].toUpperCase();

    return CircleAvatar(
      backgroundColor: color,
      radius: radius,
      child: Text(
        initial,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.black87),
      ),
    );
  }
}
