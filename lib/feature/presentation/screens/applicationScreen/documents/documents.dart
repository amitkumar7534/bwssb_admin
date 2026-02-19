import 'dart:convert';
import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:bwssb/components/coreComponents/AppButton.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/styles/appColors.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/feature/data/models/dataModels/get_all_details_model.dart';
import 'DocumentViewerScreen.dart';

class Documents extends StatelessWidget {
  final GetAllDetailsModel details;

  const Documents({super.key, required this.details});

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
        color: AppColors.cardBaground,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildDocumentRow({
    required BuildContext context,
    required String label,
    required Document? document,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          child: TextView(
            text: label.toUpperCase(),
            style: 17.txtMediumgender,
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              height: screenHeight * 0.08,
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.5,
              ),
              child: AppButton(
                label: "Documents View",
                labelStyle: 16.txtBoldWhite,
                buttonColor: AppColors.btnColor,
                radius: 10.sdp,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                onTap: document != null
                    ? () {
                  try {
                    final base64Str = document.base64 ?? '';
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
                        mimeType: document.mimeType ?? '',
                        originalFileName:
                        document.originalFileName ?? 'Document',
                      ),
                    );
                  } catch (e) {
                    AppUtils.toastError("Failed to decode image: $e");
                  }
                }
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final documentsMap = details.documentDetails?.documents;

    final buildingPlan = documentsMap?["Building Plan"]?.documents?.firstOrNull;
    final buildingPhoto = documentsMap?["Building Photo with Owner"]?.documents?.firstOrNull;
    final leaseDeed = documentsMap?["Sale Deed"]?.documents?.firstOrNull;
    final katha = documentsMap?["Katha"]?.documents?.firstOrNull;

    return Padding(
      padding: 16.all,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(text: "Documents", style: 16.txtBoldBtncolor, margin: 10.top + 10.bottom),

            _buildUploadSection(label: "RWH", children: [
              _buildDocumentRow(context: context, label: "Building Plan", document: buildingPlan),
            ]),

            _buildUploadSection(label: "RWH", children: [
              _buildDocumentRow(context: context, label: "Building photo with owner", document: buildingPhoto),
            ]),

            _buildUploadSection(label: "RWH", children: [
              _buildDocumentRow(context: context, label: "Lease cum sale deed", document: leaseDeed),
            ]),

            _buildUploadSection(label: "RWH", children: [
              _buildDocumentRow(context: context, label: "Katha", document: katha),
            ]),
          ],
        ),
      ),
    );
  }
}

