import 'dart:io';

import 'package:bwssb/components/styles/appColors.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/EditText.dart';
import '../../../../../components/coreComponents/TextView.dart';
import '../../../../data/models/dataModels/get_all_details_model.dart';
import '../../../controller/BuildingControllers.dart';

class BuildingDetails extends StatefulWidget {
  final GetAllDetailsModel details;
  const BuildingDetails({super.key, required this.details});

  @override
  State<BuildingDetails> createState() => _BuildingDetailsState();
}

class _BuildingDetailsState extends State<BuildingDetails> {
  final List<int> cardIndexes = [];
  int nextIndex = 0;

  List<BuildingControllers> buildingControllers = [];

  @override
  void initState() {
    super.initState();

    final buildingList = widget.details.buildingDetails?.floorDetails ?? [];

    for (var building in buildingList) {
      buildingControllers.add(
        BuildingControllers(
          buildingTypeController: TextEditingController(text: building.purposeTypeName ?? 'N/A'),
          floorController: TextEditingController(text: building.floorName ?? 'N/A'),
          amenityTypeController: TextEditingController(text: building.amenityTypeName ?? 'N/A'),
          sqftController: TextEditingController(text: building.area?.sqFeet?.toString() ?? 'N/A'),
          sqmtController: TextEditingController(text: building.area?.sqMeter?.toString() ?? 'N/A'),
        ),
      );
      cardIndexes.add(nextIndex++);
    }
  }




  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  String? nocAvailable;
  final nocNumberController = TextEditingController();


  Widget _buildUploadSection({
    required String label,
    required List<Widget> children,
  }) {
    return Container(
      padding: 12.all,
      margin: 15.top,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.btnColor),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.cardBaground

      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildBuildingCard(int id, bool isTopCard) {
    final controller = buildingControllers.length > id ? buildingControllers[id] : null;

    return Card(
      color: AppColors.buildingCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: 10.vertical,
      child: Padding(
        padding: 16.all,
        child: Column(
          children: [
            _buildTextFieldRow('Building Type :', controller?.buildingTypeController),
            _buildTextFieldRow('Floor :', controller?.floorController),
            _buildTextFieldRow('Amenity Type :', controller?.amenityTypeController),
            _buildTextFieldRow('Size in sqft :', controller?.sqftController),
            _buildTextFieldRow('Size in sqmt :', controller?.sqmtController),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildTextFieldRow(String label, TextEditingController? controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextView(text: label, style: 14.txtBoldGrey),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            enableInteractiveSelection: false,
            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
            decoration: const InputDecoration(border: UnderlineInputBorder()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 16.all,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(text: "Building Details", style: 16.txtBoldBtncolor),
           15.height,
            ListView.builder(
              itemCount: cardIndexes.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                final id = cardIndexes[i];
                return _buildBuildingCard(id, i == 0);
              },
            ),
            TextView(text: "Plumber Details", style: 16.txtBoldBtncolor,margin: 10.top + 10.bottom,),
            TextView(text: "IS Plumber Available?", style: 16.txtBoldBlack,margin: 10.top + 10.bottom,),

            Row(
              children: [

                TextView(
                  text: nocAvailable == "1" ? "Yes" : "No",
                  style: 16.txtRegularBlack,
                ),
              ],
            ),

            if (nocAvailable == "1")
              _buildUploadSection(
                label: "NOC",
                children: [
                  EditText(
                    readOnly: true,
                    filledColor: AppColors.white,
                    label: "Select Plumber".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select Plumber'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                  12.height,
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: "Upload mutual Agreement (MA)".toUpperCase(),
                          style: 17.txtMediumgender,
                        ),
                      ),
                      Expanded(
                        child: AppButton(
                          label: "View",
                          labelStyle: 16.txtBoldWhite,
                          buttonColor: AppColors.btnColor,
                          radius: 10.sdp,
                          padding: 10.top + 10.bottom,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Padding(
            //   padding: 15.top + 10.bottom,
            //   child: TextView(
            //     text: "Please fill all mandatory fields before proceeding."
            //         .toUpperCase(),
            //     style: 16.txtRegularBlack,
            //   ),
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: AppButton(
            //         label: "Back",
            //         labelStyle: 16.txtBoldBtncolor,
            //         buttonColor: AppColors.white,
            //         buttonBorderColor: AppColors.btnColor,
            //         radius: 10.sdp,
            //         padding: 10.top + 10.bottom,
            //         margin: 20.top  + 10.bottom + 10.right,
            //         onTap: () {
            //         },
            //       ),
            //     ),
            //     Expanded(
            //       child: AppButton(
            //         label: "Next",
            //         labelStyle: 16.txtBoldWhite,
            //         buttonColor: AppColors.btnColor,
            //         radius: 10.sdp,
            //         padding: 10.top + 10.bottom,
            //         margin: 20.top + 10.left + 10.bottom ,
            //         onTap: () {
            //         },
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }


}
