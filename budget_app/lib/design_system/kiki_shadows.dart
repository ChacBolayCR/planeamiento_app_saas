import 'package:flutter/material.dart';

class KikiShadows {
  const KikiShadows._();

  static const none = <BoxShadow>[];

  static const subtle = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const floatingAction = [
    BoxShadow(
      color: Color(0x2637206B),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
