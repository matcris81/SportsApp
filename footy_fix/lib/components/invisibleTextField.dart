import 'package:flutter/material.dart';

Widget buildInvisibleTextField({
  required String label,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  void Function(String?)? onSaved,
}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    style: const TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validator,
    onSaved: onSaved,
  );
}
