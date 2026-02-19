import 'package:flutter/cupertino.dart';

class BuildingControllers {
  final TextEditingController buildingTypeController;
  final TextEditingController floorController;
  final TextEditingController amenityTypeController;
  final TextEditingController sqftController;
  final TextEditingController sqmtController;

  BuildingControllers({
    required this.buildingTypeController,
    required this.floorController,
    required this.amenityTypeController,
    required this.sqftController,
    required this.sqmtController,
  });
}
