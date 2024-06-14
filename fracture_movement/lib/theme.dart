import 'package:flutter/cupertino.dart';

const double basePadding = 8;

EdgeInsetsGeometry paddingForContext(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 380) {
    return const EdgeInsets.symmetric(
      vertical: basePadding,
      horizontal: basePadding,
    );
  }

  return const EdgeInsets.symmetric(
    vertical: basePadding,
    horizontal: basePadding * 2,
  );
}
