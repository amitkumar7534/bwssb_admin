import 'dart:convert';

import 'package:bwssb/components/coreComponents/ImageView.dart';
import 'package:bwssb/components/styles/appImages.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/EditText.dart';
import '../../../../../components/coreComponents/TextView.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../utils/appUtils.dart';
import '../../../../data/models/dataModels/get_all_details_model.dart';
import '../documents/DocumentViewerScreen.dart';

class SiteDetails extends StatefulWidget {
  final GetAllDetailsModel details;
  const SiteDetails({super.key, required this.details});

  @override
  State<SiteDetails> createState() => _SiteDetailsState();
}
final _formKey = GlobalKey<FormState>();


int ocAvailable = 0;
int rwhAvailable = 0;
int nocAvailable = 0;

final ocNumberController = TextEditingController();
final ocDateController = TextEditingController();
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



class _SiteDetailsState extends State<SiteDetails> {


  late final TextEditingController PidNumberController = TextEditingController(
    text: widget.details.siteDetails?.pIDDetails?.pidNumber ?? 'N/A',
  );

  late final TextEditingController emailController = TextEditingController(
    text:  widget.details.siteDetails?.pIDDetails?.kathaNumber ?? 'N/A',
  );

  late final TextEditingController yearOfConstructionController = TextEditingController(
    text: widget.details.siteDetails?.yearOfConstruction ?? 'N/A',
  );

  late final TextEditingController PurposeController = TextEditingController(
    text: widget.details.buildingDetails?.purposeName ?? 'N/A',
  );

  late final TextEditingController numberOfFlatsController = TextEditingController(
    text: widget.details.siteDetails?.numberOfFlats != null
        ? widget.details.siteDetails!.numberOfFlats.toString()
        : 'N/A',
  );


  late final TextEditingController  siteAreaNumberController = TextEditingController(
    text: widget.details.siteDetails?.sitalArea.toString() ?? 'N/A',
  );

  late final TextEditingController numberOfToiletsController = TextEditingController(
    text: widget.details.siteDetails?.numberOfToilets != null
        ? widget.details.siteDetails!.numberOfToilets.toString()
        : 'N/A',
  );


  late final TextEditingController  siteAreaCtrl = TextEditingController(text: "N/A");

  late final TextEditingController siteAreaSqftController = TextEditingController(
    text: widget.details.siteDetails?.sitalArea != null
        ? "${widget.details.siteDetails!.sitalArea!.sqFeet?.toStringAsFixed(2)} sq.mt"
        : 'N/A',
  );


  late final TextEditingController siteAreaSqmtController = TextEditingController(
    text: widget.details.siteDetails?.sitalArea != null
        ? "${widget.details.siteDetails!.sitalArea!.sqMeter?.toStringAsFixed(2)} sq.ft"
        : 'N/A',
  );




  late final TextEditingController buildUpAreaSqmtController = TextEditingController(
    text: widget.details.siteDetails?.sitalArea != null
        ? "${widget.details.siteDetails!.builtUpArea?.sqMeter?.toStringAsFixed(2)} sq.ft"
        : 'N/A',
  );


  late final TextEditingController buildUpAreaSqftController = TextEditingController(
    text: widget.details.siteDetails?.sitalArea != null
        ? "${widget.details.siteDetails!.builtUpArea?.sqFeet?.toStringAsFixed(2)} sq.mt"
        : 'N/A',
  );


  @override
  void initState() {
    super.initState();

    final ocDetails = widget.details.siteDetails?.ocDetails;
    final nocDetails = widget.details.siteDetails?.nocDetails;
    final rwhDetails = widget.details.siteDetails?.rwhDetails;

    ocAvailable = ocDetails?.isOcAvailable ?? 0;
    ocNumberController.text = ocDetails?.ocNumber ?? '';
    ocDateController.text = ocDetails?.ocDate ?? '';

    nocAvailable = nocDetails?.isNocAvailable ?? 0;
    nocNumberController.text = nocDetails?.nocNumber ?? '';

    rwhAvailable = rwhDetails?.isRwhAvailable ?? 0;
  }





  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 16.all,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(text: "Site details", style: 16.txtBoldBtncolor),
            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: PidNumberController,
                    inputType: TextInputType.number,
                    hint: "Enter Pid Number",
                    label: "Pid number".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: emailController,
                    inputType: TextInputType.emailAddress,
                    hint: "Katha Number",
                    label: "Katha Number".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            EditText(
              controller: yearOfConstructionController,
              readOnly: true,
              padding: 20.top + 20.bottom + 12.left,
              label: "year of construction".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              borderColor: Colors.transparent,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year of construction'.toUpperCase();
                }
                return null;
              },
              suffixIcon: Padding(
                padding: 10.all,
                child: ImageView(url: AppImages.Calendar,height: 30.sdp,width: 30.sdp,),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: PurposeController,
                    hint: "Select Purpose",
                    label: "purpose".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: numberOfFlatsController,
                    label: "number of flats".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),
            5.height,
            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: numberOfToiletsController,
                    label: "No of toilets".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter No of toilets'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "Enter Site Area".toUpperCase(),
                        style: 14.txtRegularBlack,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        controller: siteAreaCtrl,
                        readOnly: true,
                        hint: "Enter Site Area",
                        labelStyle: 14.txtRegularBlack,
                        margin: 3.top,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            15.height,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "sital area in sqft".toUpperCase(),
                        style: 14.txtRegularBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        readOnly: true,
                        controller: siteAreaSqmtController,
                        // hint: "Enter Site Area",
                        labelStyle: 14.txtRegularBlack,
                        margin: 3.top,
                      ),
                    ],
                  ),
                ),

                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "sital area in sqmt".toUpperCase(),
                        style: 14.txtRegularBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        readOnly: true,
                        controller: siteAreaSqftController,
                        hint: "Enter Site Area",
                        labelStyle: 14.txtRegularBlack,
                        margin: 3.top,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            15.height,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "builtup area in sqft".toUpperCase(),
                        style: 14.txtRegularBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        controller: buildUpAreaSqmtController,
                        readOnly: true,
                        // hint: "Enter Site Area",
                        labelStyle: 14.txtRegularBlack,
                        margin: 3.top,
                      ),
                    ],
                  ),
                ),


                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "builtup area in sqmt".toUpperCase(),
                        style: 14.txtRegularBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        readOnly: true,
                        controller: buildUpAreaSqftController,
                        hint: "Enter Site Area",
                        labelStyle: 14.txtRegularBlack,
                        margin: 3.top,

                      ),
                    ],
                  ),
                ),
              ],
            ),

            TextView(
              text: "OC Available?",
              style: 16.txtBoldBtncolor,
              margin: 10.top + 10.bottom,
            ),
            TextView(
              text: ocAvailable == 1 ? "Yes" : "No",
              style: 16.txtRegularBlack,
            ),
            if (ocAvailable == 1)
              _buildUploadSection(
                label: "OC",
                children: [
                  EditText(
                    readOnly: true,
                    controller: ocNumberController,
                    filledColor: AppColors.white,
                    label: "OC Number".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OC number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                  EditText(
                    readOnly: true,
                    controller: ocDateController,
                    filledColor: AppColors.white,
                    label: "OC Date".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OC date'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                  12.height,
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: "UPLOAD OC DOCUMENT",
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
                          margin: 20.top + 10.left + 10.bottom,
                          onTap: () {
                            try {
                              final base64Str = widget.details.siteDetails?.ocDetails?.ocDocuments?.first.base64 ?? '';
                              if (base64Str.isEmpty || !base64Str.contains(',')) {
                                AppUtils.toastError("Document has not valid");
                                return;
                              }

                              final base64Data = base64Str.split(',').last.trim();
                              if (base64Data.isEmpty) {
                                AppUtils.toastError("content is empty.");
                                return;
                              }

                              final bytes = base64Decode(base64Data);
                              if (bytes.isEmpty) {
                                AppUtils.toastError("image is empty.");
                                return;
                              }

                              context.pushNavigator(
                                DocumentViewerScreen(
                                  imageBytes: bytes,
                                  mimeType: widget.details.siteDetails?.ocDetails?.ocDocuments?.first.mimeType ?? '',
                                  originalFileName:
                                  widget.details.siteDetails?.ocDetails?.ocDocuments?.first.originalFileName ?? '',
                                ),
                              );
                            } catch (e) {
                              AppUtils.toastError("Failed to decode image: $e");
                            }
                          }
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            TextView(
              text: "Is RWH Available?",
              style: 16.txtBoldBtncolor,
              margin: 10.top + 10.bottom,
            ),
            TextView(
              text: rwhAvailable == 1 ? "Yes" : "No",
              style: 16.txtRegularBlack,
            ),
            if (rwhAvailable == 1)
              _buildUploadSection(
                label: "RWH",
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: "Upload RWH".toUpperCase(),
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
                          margin: 10.left,
                            onTap: () {
                              try {
                                final base64Str = widget.details.siteDetails?.rwhDetails?.rwhDocuments?.first.base64;
                                if (base64Str!.isEmpty || !base64Str.contains(',')) {
                                  AppUtils.toastError("Document has not valid");
                                  return;
                                }

                                final base64Data = base64Str.split(',').last.trim();
                                if (base64Data.isEmpty) {
                                  AppUtils.toastError("content is empty.");
                                  return;
                                }

                                final bytes = base64Decode(base64Data);
                                if (bytes.isEmpty) {
                                  AppUtils.toastError("image is empty.");
                                  return;
                                }

                                context.pushNavigator(
                                  DocumentViewerScreen(
                                    imageBytes: bytes,
                                    mimeType: widget.details.siteDetails?.ocDetails?.ocDocuments?.first.mimeType ?? '',
                                    originalFileName:
                                    widget.details.siteDetails?.ocDetails?.ocDocuments?.first.originalFileName ?? '',
                                  ),
                                );
                              } catch (e) {
                                AppUtils.toastError("Failed to decode image: $e");
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            TextView(
              text: "Is NOC Available?",
              style: 16.txtBoldBtncolor,
              margin: 10.top + 10.bottom,
            ),
            TextView(
              text: nocAvailable == 1 ? "Yes" : "No",
              style: 16.txtRegularBlack,
            ),
            if (nocAvailable == 1)
              _buildUploadSection(
                label: "NOC",
                children: [
                  EditText(
                    controller: nocNumberController,
                    readOnly: true,
                    filledColor: AppColors.white,
                    label: "NOC Number".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter NOC Number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                  12.height,
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: "Upload NOC document".toUpperCase(),
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
                          margin: 10.left,
                            onTap: () {
                              try {
                                final base64Str = widget.details.siteDetails?.nocDetails?.nocDocuments?.first.base64;
                                final mimeType = widget.details.siteDetails?.nocDetails?.nocDocuments?.first.mimeType ?? '';
                                final fileName = widget.details.siteDetails?.nocDetails?.nocDocuments?.first.originalFileName ?? '';

                                if (base64Str == null || !base64Str.contains(',')) {
                                  AppUtils.toastError("Invalid document");
                                  return;
                                }

                                final base64Data = base64Str.split(',').last.trim();
                                final bytes = base64Decode(base64Data);

                                context.pushNavigator(
                                  DocumentViewerScreen(
                                    imageBytes: bytes,
                                    mimeType: mimeType,
                                    originalFileName: fileName,
                                  ),
                                );
                              } catch (e) {
                                AppUtils.toastError("Failed to decode document: $e");
                              }
                            }

                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Padding(
            //   padding: 10.top + 16.bottom,
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
