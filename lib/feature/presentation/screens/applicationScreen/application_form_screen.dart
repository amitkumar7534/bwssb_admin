import 'dart:convert';
import 'dart:io';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/services/storage/preferences.dart';
import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../services/location/LocationService.dart';
import '../../../data/models/dataModels/ButtonDataModel.dart';
import '../../../data/models/dataModels/application_model.dart';
import '../../../data/models/dataModels/get_all_details_model.dart' hide ChecklistDetails;
import '../../../data/models/repository/iAuthRepository.dart';
import '../../../domain/repository/authRepository.dart';
import '../../cards/RemarksField.dart';
import '../../controller/button_ctrl.dart';
import 'applicationDetails/application_detail_screen.dart';
import 'documents/documents.dart';
import 'package:bwssb/feature/presentation/screens/applicationScreen/siteDetails/site_details.dart'
as siteDetailsWidget;
import 'package:bwssb/feature/presentation/screens/applicationScreen/buildingDetails/building_details.dart'
as buildingDetailsWidget;
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel application;
  final GetAllDetailsModel? details;

  const ApplicationFormScreen({
    Key? key,
    required this.application,
    this.details,
  }) : super(key: key);

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final List<String> checklistItems = [
    "Site Inspection and Measurement",
    "Khata",
    "Lease cum Sale Deed",
    "Building Plan",
    "RWH",
    "NOC",
    "CFO",
    "OC",
  ];

  final ImagePicker _picker = ImagePicker();

  Map<String, bool> _expandedSections = {
    "Application Details": false,
    "Site Details": false,
    "Building Details": false,
    "Documents": false,
    "Payment Details": false,
  };

  // Remove local button data variables - use only GetX reactive state
  final buttonCtrl = Get.put(ButtonCtrl());

  // Add loading state for better UX
  bool _isInitializing = true;

  // Add separate tracking for penalty radio button selections
  Map<String, bool?> penaltySelections = {
    "RWH Penalty Applicable": null,
    "STP Penalty Applicable": null,
    "OC Penalty Applicable": null,
  };

  // Helper method to get penalty item for main item
  String? getPenaltyItemFor(String mainItem) {
    switch (mainItem) {
      case "RWH":
        return "RWH Penalty Applicable";
      case "CFO":
        return "STP Penalty Applicable";
      case "OC":
        return "OC Penalty Applicable";
      default:
        return null;
    }
  }

  // Helper method to get main item for penalty item
  String? getMainItemFor(String penaltyItem) {
    switch (penaltyItem) {
      case "RWH Penalty Applicable":
        return "RWH";
      case "STP Penalty Applicable":
        return "CFO";
      case "OC Penalty Applicable":
        return "OC";
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _expandedSections[stepTitles[0]] = true;
    currentStep = 0;

    // Initialize data asynchronously
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isInitializing = true;
      });

      await buttonCtrl.fetchButton(
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
      );

      // Debug logging
      print("Button data fetched: ${buttonCtrl.buttonData.value?.button}");
      print("UI type: ${buttonCtrl.buttonData.value?.ui}");

      final btnText = buttonCtrl.buttonData.value?.button ?? "";
      if (btnText.toUpperCase() == "UPDATE") {
        final buttonDetails = buttonCtrl.buttonData.value?.details;

        if (buttonDetails?.checklistDetails != null) {
          _prefillChecklistFrom(buttonDetails!.checklistDetails!);
        }

        if (buttonDetails?.siteInspectionDetails != null) {
          _loadExistingDocumentsFrom(buttonDetails!.siteInspectionDetails!.documents ?? []);

          setState(() {
            _latitude = double.tryParse(buttonDetails.siteInspectionDetails!.latitude ?? "");
            _longitude = double.tryParse(buttonDetails.siteInspectionDetails!.longitude ?? "");
            currentLocation =
            "${buttonDetails.siteInspectionDetails!.latitude}, ${buttonDetails.siteInspectionDetails!.longitude}";
            isLocationCaptured = true;
          });
        }
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      print("Error initializing data: $e");
      setState(() {
        _isInitializing = false;
      });
      AppUtils.toast("Error loading data: $e");
    }
  }

  void _prefillChecklistFrom(ChecklistDetails data) {
    selectedChecklistItems.clear(); // Clear existing items first
    if (data.siteInspectionAndMeasurement == 1) selectedChecklistItems.add("Site Inspection and Measurement");
    if (data.khata == 1) selectedChecklistItems.add("Khata");
    if (data.leaseCumSaleDeedOrSaleDeed == 1) selectedChecklistItems.add("Lease cum Sale Deed");
    if (data.buildingPlan == 1) selectedChecklistItems.add("Building Plan");
    if (data.rwh == 1) selectedChecklistItems.add("RWH");
    if (data.bwssbNoc == 1) selectedChecklistItems.add("NOC");
    if (data.cfo == 1) selectedChecklistItems.add("CFO");
    if (data.oc == 1) selectedChecklistItems.add("OC");

    // Set penalty radio button states based on existing data
    penaltySelections["RWH Penalty Applicable"] = data.rwhPenaltyApplicable == 1 ? true : (data.rwhPenaltyApplicable == 0 ? false : null);
    penaltySelections["STP Penalty Applicable"] = data.stpPenaltyApplicable == 1 ? true : (data.stpPenaltyApplicable == 0 ? false : null);
    penaltySelections["OC Penalty Applicable"] = data.ocPenaltyApplicable == 1 ? true : (data.ocPenaltyApplicable == 0 ? false : null);

    setState(() {});
  }

  void _loadExistingDocumentsFrom(List<SiteDocument> docs) {
    // Clear existing images first
    _siteImages.clear();
    _rwhImages.clear();
    _stpImages.clear();
    _workComp.clear();

    for (var value in docs) {
      final uploaded = UploadedImage.fromApi(value.toJson());
      if (uploaded.documentType == "SITE_INSPECTION") {
        _siteImages.add(uploaded);
      } else if (uploaded.documentType == "RWH") {
        _rwhImages.add(uploaded);
      } else if (uploaded.documentType == "STP") {
        _stpImages.add(uploaded);
      } else if (uploaded.documentType == "WORK_COMPLETION_DOCUMENT") {
        _workComp.add(uploaded);
      }
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final site = widget.details?.siteInspectionDetails;
    if (site != null) {
      setState(() {
        _latitude = double.tryParse(site.latitude ?? "");
        _longitude = double.tryParse(site.longitude ?? "");
        currentLocation = "${site.latitude}, ${site.longitude}";
        isLocationCaptured = true;
      });
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        currentLocation = "${position.latitude}, ${position.longitude}";
        _isFetchingLocation = false;
        isLocationCaptured = true;
      });
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
      });
      AppUtils.toast("Failed to get location: $e");
    }
  }

  final List<String> stepTitles = [
    "Application Details",
    "Site Details",
    "Building Details",
    "Documents",
    "Payment Details",
  ];

  int currentStep = 0;

  List<UploadedImage> _siteImages = [];
  List<UploadedImage> _workComp = [];
  List<UploadedImage> _rwhImages = [];
  List<UploadedImage> _stpImages = [];

  double? _latitude;
  double? _longitude;
  String? currentLocation;
  bool isLocationCaptured = false;
  bool _isFetchingLocation = false;

  final Set<String> selectedChecklistItems = {};
  final AuthRepository _repo = IAuthRepository();
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Widget _buildCheckboxTile(String label) {
    final bool isSelected = selectedChecklistItems.contains(label);

    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedChecklistItems.add(label);
              } else {
                selectedChecklistItems.remove(label);

                // Reset penalty selection when unchecking main item
                final penaltyItem = getPenaltyItemFor(label);
                if (penaltyItem != null) {
                  penaltySelections[penaltyItem] = null;
                }
              }
            });
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: AppColors.white,
          checkColor: AppColors.btnColor,
          side: MaterialStateBorderSide.resolveWith((states) {
            return BorderSide(color: AppColors.btnColor, width: 1);
          }),
        ),
        Expanded(
          child: TextView(
            text: label,
            style: 16.txtRegularBlack,
          ),
        ),
      ],
    );
  }

  // Create a widget for penalty radio buttons
  Widget _buildPenaltyRadioButtons(String penaltyType) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: penaltyType,
            style: 14.txtBoldBlack,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: penaltySelections[penaltyType],
                      onChanged: (bool? value) {
                        setState(() {
                          penaltySelections[penaltyType] = value;
                        });
                      },
                      activeColor: AppColors.btnColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    TextView(text: "Yes", style: 14.txtRegularBlack),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: penaltySelections[penaltyType],
                      onChanged: (bool? value) {
                        setState(() {
                          penaltySelections[penaltyType] = value;
                        });
                      },
                      activeColor: AppColors.btnColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    TextView(text: "No", style: 14.txtRegularBlack),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Update the dynamic checklist section to include penalty radio buttons
  Widget _buildDynamicChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(text: "Checklist", style: 20.txtBoldBlack),
        10.height,
        ...checklistItems.map((item) {
          List<Widget> widgets = [_buildCheckboxTile(item)];

          // Add penalty radio buttons if main item is selected
          final penaltyItem = getPenaltyItemFor(item);
          if (penaltyItem != null && selectedChecklistItems.contains(item)) {
            widgets.add(_buildPenaltyRadioButtons(penaltyItem));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ImageView(
                    url: AppImages.backButton,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ImageView(
                url: AppImages.homeScreenAppBar,
                height: 40,
                width: 180,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isInitializing
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          padding: 16.horizontal + 20.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: AppStrings.Application,
                style: 20.txtBoldBlack,
                margin: 20.top + 25.bottom,
              ),
              10.height,
              ExpandableSection(
                title: "Application Details",
                icon: AppImages.totalImage,
                color: AppColors.btnColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ApplicationDetailScreen(details: widget.details!),
                ),
              ),
              ExpandableSection(
                title: "Site Details",
                icon: AppImages.site,
                color: AppColors.darkOrange,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: siteDetailsWidget.SiteDetails(
                    details: widget.details!,
                  ),
                ),
              ),
              ExpandableSection(
                title: "Building Details",
                icon: AppImages.site,
                color: AppColors.splashColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: buildingDetailsWidget.BuildingDetails(
                    details: widget.details!,
                  ),
                ),
              ),
              ExpandableSection(
                title: "Documents",
                icon: AppImages.docIMg,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Documents(details: widget.details!),
                ),
              ),

              // Use Obx for reactive UI updates with dynamic checklist
              Obx(() {
                final buttonData = buttonCtrl.buttonData.value;
                final uiType = buttonData?.ui ?? "";

                if (uiType == "SITE_INSPECTION") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDynamicChecklistSection(),
                      20.height,
                      _buildLocationButton(),
                      20.height,
                      TextView(text: "Site Photo", style: 20.txtBoldBlack),
                      TextView(
                        text: "UPLOAD PHOTO",
                        style: 14.txtRegularBlack,
                        margin: 15.top + 15.bottom,
                      ),
                      _selectedMediaWidget(
                        imageList: _siteImages,
                        onAdd: () => chooseImageFor(_siteImages, "SITE_INSPECTION"),
                        onRemove: (index) async {
                          await _removeImage(_siteImages, index);
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              20.height,

              // Conditional sections based on checklist selections
              if (selectedChecklistItems.contains("RWH"))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(text: "RWH Photo", style: 20.txtBoldBlack),
                    TextView(
                      text: "UPLOAD PHOTO",
                      style: 14.txtRegularBlack,
                      margin: 15.top + 15.bottom,
                    ),
                    _selectedMediaWidget(
                      imageList: _rwhImages,
                      onAdd: () => chooseImageFor(_rwhImages, "RWH"),
                      onRemove: (index) async {
                        await _removeImage(_rwhImages, index);
                      },
                    ),
                    20.height,
                  ],
                ),

              if (selectedChecklistItems.contains("CFO"))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(text: "STP Photo", style: 20.txtBoldBlack),
                    TextView(
                      text: "UPLOAD PHOTO",
                      style: 14.txtRegularBlack,
                      margin: 15.top + 15.bottom,
                    ),
                    _selectedMediaWidget(
                      imageList: _stpImages,
                      onAdd: () => chooseImageFor(_stpImages, "STP"),
                      onRemove: (index) async {
                        await _removeImage(_stpImages, index);
                      },
                    ),
                    20.height,
                  ],
                ),

              // Work Completion Photo section
              Obx(() {
                final buttonData = buttonCtrl.buttonData.value;
                final uiType = buttonData?.ui ?? "";

                if (uiType == "WORK_COMPLETION_DOCUMENT") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "Work Completion Photo",
                        style: 20.txtBoldBlack,
                      ),
                      TextView(
                        text: "Upload photo".toUpperCase(),
                        style: 14.txtRegularBlack,
                        margin: 15.top + 15.bottom,
                      ),
                      _selectedMediaWidget(
                        imageList: _workComp,
                        onAdd: () => chooseImageFor(_workComp, uiType),
                        onRemove: (index) async {
                          await _removeImage(_workComp, index);
                        },
                      ),
                      TextView(
                        margin: 20.top,
                        text: "Remarks",
                        style: 20.txtBoldBlack,
                      ),
                      RemarksField(
                        controller: _remarksController,
                      ),
                      20.height,
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // Bottom buttons with proper reactive state
              Obx(() {
                final buttonData = buttonCtrl.buttonData.value;
                final buttonText = buttonData?.button ?? '';

                if (buttonText.isNotEmpty) {
                  return Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: AppStrings.back.toUpperCase(),
                          labelStyle: 16.txtBoldBtncolor,
                          buttonColor: AppColors.white,
                          radius: 10.sdp,
                          padding: 13.top + 13.bottom,
                          margin: 20.top + 10.bottom + 10.right,
                          buttonBorderColor: AppColors.btnColor,
                          onTap: () {
                            context.pop();
                          },
                        ),
                      ),
                      Expanded(
                        child: AppButton(
                          label: buttonText.toUpperCase(),
                          labelStyle: 16.txtBoldWhite,
                          buttonColor: AppColors.btnColor,
                          radius: 10.sdp,
                          padding: 15.top + 15.bottom + 12.left,
                          margin: 20.top + 10.left + 10.bottom,
                          onTap: () async {
                            await _handleSubmit(buttonText);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeImage(List<UploadedImage> imageList, int index) async {
    final imageId = imageList[index].id;

    final response = await _repo.deleteImage(deleteImgId: imageId);

    if (response.isSuccess) {
      setState(() {
        imageList.removeAt(index);
      });
      AppUtils.toast("Image deleted successfully.");
    } else {
      AppUtils.toast("Failed to delete image.");
    }
  }

  Future<void> _handleSubmit(String buttonText) async {
    try {
      final uiType = buttonCtrl.buttonData.value?.ui ?? "";

      // Location validation only for SITE_INSPECTION
      if (uiType == "SITE_INSPECTION") {
        if (_latitude == null || _longitude == null) {
          AppUtils.toast("Location not available. Please try again.");
          return;
        }

        if (_siteImages.isEmpty) {
          AppUtils.toast("At least one Site Inspection document is required");
          return;
        }
      }

      // Validate penalty selections for selected items
      if (selectedChecklistItems.contains("RWH") && penaltySelections["RWH Penalty Applicable"] == null) {
        AppUtils.toast("Please select RWH Penalty option (Yes/No)");
        return;
      }
      if (selectedChecklistItems.contains("CFO") && penaltySelections["STP Penalty Applicable"] == null) {
        AppUtils.toast("Please select STP Penalty option (Yes/No)");
        return;
      }
      if (selectedChecklistItems.contains("OC") && penaltySelections["OC Penalty Applicable"] == null) {
        AppUtils.toast("Please select OC Penalty option (Yes/No)");
        return;
      }

      final documentsPayload = _buildDocumentsPayload();
      final btnText = buttonText.toUpperCase();

      // Updated checklist payload to use penalty radio button values
      final checklist = {
        "checklistID": buttonCtrl.buttonData.value?.details?.checklistDetails?.checklistId.toString() ?? "0",
        "stage": widget.application.stageNo,
        "siteInspectionAndMeasurement": selectedChecklistItems.contains("Site Inspection and Measurement") ? 1 : 0,
        "khata": selectedChecklistItems.contains("Khata") ? 1 : 0,
        "leaseCumSaledeedOrSaledeed": selectedChecklistItems.contains("Lease cum Sale Deed") ? 1 : 0,
        "buildingPlan": selectedChecklistItems.contains("Building Plan") ? 1 : 0,
        "rwh": selectedChecklistItems.contains("RWH") ? 1 : 0,
        "rwhPenaltyApplicable": selectedChecklistItems.contains("RWH")
            ? (penaltySelections["RWH Penalty Applicable"] == true ? 1 : 0)
            : 0,
        "bwssbNoc": selectedChecklistItems.contains("NOC") ? 1 : 0,
        "cfo": selectedChecklistItems.contains("CFO") ? 1 : 0,
        "stpPenaltyApplicable": selectedChecklistItems.contains("CFO")
            ? (penaltySelections["STP Penalty Applicable"] == true ? 1 : 0)
            : 0,
        "oc": selectedChecklistItems.contains("OC") ? 1 : 0,
        "ocPenaltyApplicable": selectedChecklistItems.contains("OC")
            ? (penaltySelections["OC Penalty Applicable"] == true ? 1 : 0)
            : 0,
      };

      final response = btnText == "UPDATE"
          ? await _repo.submitUpdate(
        inspectionID: buttonCtrl.buttonData.value?.details?.siteInspectionDetails?.inspectionId.toString() ?? "",
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        documents: documentsPayload,
        action: uiType,
        checklist: checklist,
      ).applyLoader
          : await _repo.submit(
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        documents: documentsPayload,
        action: uiType,
        checklist: checklist,
      ).applyLoader;

      if (response.isSuccess) {
        AppUtils.toast(response.message ?? "");
        context.pop();
      } else {
        AppUtils.toastError(response.error ?? "");
      }
    } catch (e) {
      AppUtils.toast("Error: $e");
    }
  }

  Widget _selectedMediaWidget({
    required List<UploadedImage> imageList,
    required VoidCallback onAdd,
    required Future<void> Function(int index) onRemove,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageList.length < 6 ? imageList.length + 1 : imageList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index == imageList.length && imageList.length < 6) {
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15.sdp),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageView(
                      url: AppImages.CameraImg,
                      height: 30.sdp,
                      width: 30.sdp,
                    ),
                    TextView(
                      text: "Add",
                      style: 14.txtRegularGrey,
                      margin: 5.top,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageList[index].imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12,
                    child: Icon(Icons.close, size: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildLocationButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "GET LOCATION".toUpperCase(),
          style: 14.txtRegularBlack,
          margin: 15.top + 10.bottom,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.grey,
                    width: 1,
                  ),
                ),
                child: _isFetchingLocation
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Fetching...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
                    : Text(
                  currentLocation ?? 'Location not captured',
                  style: TextStyle(
                    fontSize: 12,
                    color: currentLocation != null
                        ? Colors.black87
                        : Colors.grey[500],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFetchingLocation ? null : _captureLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final shortName = "img_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final targetPath = "${dir.absolute.path}/$shortName";

    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (compressedXFile == null) return null;
    return File(compressedXFile.path);
  }

  Future<File> _renameFileToShortName(File file) async {
    final dir = await getTemporaryDirectory();
    final newPath = "${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg";
    return file.copy(newPath);
  }

  Future<void> chooseImageFor(
      List<UploadedImage> targetList,
      String documentType,
      ) async {
    if (targetList.length >= 5) {
      AppUtils.toast("You can only upload up to 5 images.");
      return;
    }

    FocusScope.of(context).unfocus();

    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: null,
      );
    } catch (e) {
      AppUtils.log("Image pick error: $e");
      AppUtils.toast("Could not open camera.");
      return;
    }

    if (pickedFile == null) return;

    final File originalFile = File(pickedFile.path);
    File fileToUpload = originalFile;

    // Add overlay with location and timestamp
    fileToUpload = (await addOverlayWithWidget(fileToUpload)) ?? fileToUpload;

    try {
      AppUtils.log("Compressing image...");
      final File? compressed = await compressImage(originalFile);
      if (compressed != null) {
        fileToUpload = compressed;
        final originalSizeKb = (await originalFile.length()) / 1024;
        final compressedSizeKb = (await fileToUpload.length()) / 1024;
        AppUtils.log(
          "Compression done | original: ${originalSizeKb.toStringAsFixed(1)} KB, "
              "compressed: ${compressedSizeKb.toStringAsFixed(1)} KB",
        );
      } else {
        AppUtils.log("Compression returned null, using original file.");
      }
    } catch (e) {
      AppUtils.log("Compression failed: $e | Using original file.");
    }

    try {
      fileToUpload = await _renameFileToShortName(fileToUpload);
    } catch (e) {
      AppUtils.log("Rename to short name failed: $e (continuing).");
    }

    final placeholder = UploadedImage(
      id: "",
      filePath: fileToUpload.path,
    );

    setState(() {
      targetList.add(placeholder);
    });
    final int localIndex = targetList.length - 1;

    final response = await _repo
        .uploadPhoto(
      imageFile: fileToUpload,
      documentType: documentType,
      applicationID: widget.application.applicationId ?? 0,
      transactionID: widget.application.transactionId.toString(),
    )
        .applyLoader;

    if (response.isSuccess && response.data?.isNotEmpty == true) {
      final uploadedFileJson = response.data!.first;
      setState(() {
        targetList[localIndex] = UploadedImage.fromApi(uploadedFileJson);
      });
    } else {
      AppUtils.toast("Image upload failed. Please try again.");
      AppUtils.log("Upload failed: ${response.message ?? 'Unknown error'}");

      if (!mounted) return;
      setState(() {
        if (localIndex >= 0 && localIndex < targetList.length) {
          targetList.removeAt(localIndex);
        }
      });
    }
  }

  Future<File?> addOverlayWithWidget(File imageFile) async {
    try {
      final bytes = await screenshotController.captureFromWidget(
        Stack(
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Bhopal, Madhya Pradesh, India",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Kalkhedi, Ratibad, IES College Rd, Bhopal, MP 462044",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "Lat ${_latitude ?? '23.18464'}°   Long ${_longitude ?? '77.327822'}°",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      DateTime.now().toString().substring(0, 16),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pixelRatio: 2.0,
      );

      final newFile = File("${imageFile.parent.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.jpg");
      await newFile.writeAsBytes(bytes);
      return newFile;
    } catch (e) {
      AppUtils.log("Overlay error: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> _buildDocumentsPayload() {
    final List<UploadedImage> allDocs = [
      ..._siteImages,
      ..._rwhImages,
      ..._stpImages,
      ..._workComp,
    ];

    return allDocs
        .where((img) => img.id.isNotEmpty)
        .map((img) {
      return {
        "filename": img.filePath,
        "originalFileName": img.originalFileName ?? "",
        "mimeType": img.mimeType ?? "image/jpeg",
        "fileID": img.id,
        "applicationID":
        widget.application.applicationId.toString(),
        "userID":
        img.userID ?? Preferences.profile?.id.toString() ?? "",
        "uploadedBy":
        img.uploadedBy ?? Preferences.profile?.id.toString() ?? "",
        "bucketName": img.bucketName ?? "uploads",
        "documentType":
        img.documentType ?? "SITE_INSPECTION",
        "documentID":
        img.documentID ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        "transactionID":
        widget.application.transactionId.toString(),
        "createdAt":
        img.createdAt ?? DateTime.now().toIso8601String(),
      };
    })
        .toList();
  }
}

class ExpandableSection extends StatefulWidget {
  final String title;
  final String icon;
  final Widget child;
  final Color? color;

  const ExpandableSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.color,
  }) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: _buildSectionTile(
            widget.title,
            widget.icon,
            iconColor: widget.color,
            isExpanded: isExpanded,
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: widget.child,
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildSectionTile(
      String title,
      String iconPath, {
        Color? iconColor,
        required bool isExpanded,
      }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(iconPath, width: 20, color: iconColor),
      ),
      title: TextView(text: title, style: 16.txtRegularBlack),
      trailing: Icon(
        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
        color: AppColors.grey,
      ),
    );
  }
}

class UploadedImage {
  final String id;
  final String filePath;
  final String? base64;
  final String? documentType;
  final String? originalFileName;
  final String? mimeType;
  final String? bucketName;
  final String? uploadedBy;
  final String? userID;
  final String? createdAt;
  final String? documentID;

  UploadedImage({
    required this.id,
    required this.filePath,
    this.base64,
    this.documentType,
    this.originalFileName,
    this.mimeType,
    this.bucketName,
    this.uploadedBy,
    this.userID,
    this.createdAt,
    this.documentID,
  });

  factory UploadedImage.fromApi(Map<String, dynamic> json) {
    return UploadedImage(
      id: json["fileID"] ?? "",
      filePath: json["filename"] ?? "",
      base64: json["base64"],
      documentType: json["documentType"],
      originalFileName: json["originalFileName"],
      mimeType: json["mimeType"],
      bucketName: json["bucketName"],
      uploadedBy: json["uploadedBy"],
      userID: json["userID"],
      createdAt: json["createdAt"],
      documentID: json["documentID"],
    );
  }

  ImageProvider get imageProvider {
    if (base64 != null && base64!.startsWith("data:image")) {
      try {
        final base64Str = base64!.split(",").last;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return const AssetImage("assets/images/placeholder.png");
      }
    }
    if (filePath.startsWith("/") || filePath.contains("user/0/")) {
      return FileImage(File(filePath));
    }
    return NetworkImage(filePath);
  }
}