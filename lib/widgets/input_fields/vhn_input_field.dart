import 'package:flutter/material.dart';

class VhnInputField extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isObscure;
  final void Function()? onTap;
  final void Function()? onTapVisibility;
  final void Function(String)? onChange;
  final TextEditingController? controller;
  final bool? centeredText;
  final double? fontSize;
  final bool? bold;
  final double? width;

  const VhnInputField(
      {Key? key,
      this.icon,
      required this.text,
      this.isObscure = false,
      this.onTap,
      this.onTapVisibility,
      this.onChange,
      this.controller,
      this.centeredText,
      this.fontSize,
      this.bold,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: width != null ? width : null,
        child: TextField(
          style: TextStyle(
              fontSize: fontSize != null ? fontSize : null,
              fontWeight: bold != null ? FontWeight.bold : null),
          textAlign: centeredText == true ? TextAlign.center : TextAlign.start,
          controller: controller,
          onTap: onTap,
          onChanged: onChange,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
            labelText: text,
            suffixIcon: onTapVisibility != null
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onTapVisibility,
                      child: Icon(
                        isObscure ? Icons.visibility_off : Icons.remove_red_eye,
                      ),
                    ),
                  )
                : null,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
        ),
      ),
    );
  }
}
