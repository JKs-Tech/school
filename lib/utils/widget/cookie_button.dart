// Flutter imports:
import 'package:flutter/material.dart';

class CookieButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CookieButton({
    required Key key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    width: MediaQuery.of(context).size.width * .4,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
      onPressed: onPressed,
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),
  );
}
