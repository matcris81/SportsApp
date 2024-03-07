import 'package:flutter/material.dart';

Widget buildCustomButton({
  required String label,
  required VoidCallback onPressed,
  IconData? icon,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: const BoxDecoration(
      border: Border(
          bottom:
              BorderSide(color: Colors.black, width: 1)), // Add bottom border
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        alignment: Alignment.centerLeft,
        backgroundColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(double.infinity, 30),
      ).copyWith(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          if (icon != null) Icon(icon, color: Colors.black, size: 20),
        ],
      ),
    ),
  );
}
