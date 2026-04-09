import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/services/storage/preferences.dart';
import 'package:bwssb/utils/appUtils.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:bwssb/utils/extensions/extensions.dart';
import 'package:bwssb/utils/extensions/size.dart';
import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
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
import '../../../data/models/dataModels/get_all_details_model.dart';
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

// ─── ApplicationFormScreen ────────────────────────────────────────────────────

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

// ─── LocationSaveData ─────────────────────────────────────────────────────────

class LocationSaveData {
  final String? inspectionId;
  LocationSaveData({this.inspectionId});

  factory LocationSaveData.fromJson(Map<String, dynamic> json) {
    return LocationSaveData(
      inspectionId: json['inspectionID']?.toString() ??
          json['inspectionId']?.toString(),
    );
  }
}

// ─── _ApplicationFormScreenState ─────────────────────────────────────────────

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  // ── Constants ──────────────────────────────────────────────────────────────
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

  // Global limit: max 5 photos across ALL sections combined.
  static const int _maxImagesTotal = 5;

  // ── Dependencies ───────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  final buttonCtrl = Get.put(ButtonCtrl());
  final AuthRepository _repo = IAuthRepository();
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _remarksController = TextEditingController();

  // ── UI state ───────────────────────────────────────────────────────────────
  bool _isInitializing = true;
  bool _isFetchingLocation = false;
  bool _isSavingLocation = false;
  bool _isLocationSaved = false;

  // ── Location ───────────────────────────────────────────────────────────────
  double? _latitude;
  double? _longitude;
  String? _currentLocationText;
  String? _savedInspectionId;

  // ── New local images (picked from gallery, sent on submit) ─────────────────
  List<LocalImage> _siteImages = [];
  List<LocalImage> _rwhImages = [];
  List<LocalImage> _stpImages = [];
  List<LocalImage> _workCompImages = [];

  // ── Existing server documents (from API response) ──────────────────────────
  List<SiteDocument> _existingDocuments = [];

  // ── Checklist ──────────────────────────────────────────────────────────────
  final Set<String> selectedChecklistItems = {};
  Map<String, bool?> penaltySelections = {
    "RWH Penalty Applicable": null,
    "STP Penalty Applicable": null,
    "OC Penalty Applicable": null,
  };

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> _initializeData() async {
    try {
      setState(() => _isInitializing = true);

      await buttonCtrl.fetchButton(
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
      );

      final btnData = buttonCtrl.buttonData.value;

      if (btnData != null && btnData.hasSections) {
        // ── LOCATION ────────────────────────────────────────────────────
        final loc = btnData.locationSection?.details?.location;
        if (loc != null) {
          final lat = double.tryParse(loc.latitude ?? "");
          final lng = double.tryParse(loc.longitude ?? "");
          if (lat != null && lng != null) {
            setState(() {
              _latitude = lat;
              _longitude = lng;
              _currentLocationText = "${loc.latitude}, ${loc.longitude}";
              _isLocationSaved = true;
              _savedInspectionId = loc.inspectionId?.toString();
            });
          }
        }

        // ── CHECKLIST ────────────────────────────────────────────────────
        final clDetails = btnData.checklistSection?.details?.checklistDetails;
        if (clDetails != null) _prefillChecklistFrom(clDetails);

        // ── EXISTING DOCUMENTS ────────────────────────────────────────────
        final rawDocs = btnData.checklistSection?.details?.documents;
        if (rawDocs != null && rawDocs.isNotEmpty) {
          setState(() {
            _existingDocuments = List<SiteDocument>.from(rawDocs);
          });
        }
      }

      setState(() => _isInitializing = false);
    } catch (e) {
      AppUtils.log("Error initializing: $e");
      setState(() => _isInitializing = false);
      AppUtils.toast("Error loading data: $e");
    }
  }

  void _prefillChecklistFrom(ChecklistSectionDetails data) {
    selectedChecklistItems.clear();
    if (data.siteInspectionAndMeasurement == 1)
      selectedChecklistItems.add("Site Inspection and Measurement");
    if (data.khata == 1) selectedChecklistItems.add("Khata");
    if (data.leaseCumSaleDeedOrSaleDeed == 1)
      selectedChecklistItems.add("Lease cum Sale Deed");
    if (data.buildingPlan == 1) selectedChecklistItems.add("Building Plan");
    if (data.rwh == 1) selectedChecklistItems.add("RWH");
    if (data.bwssbNoc == 1) selectedChecklistItems.add("NOC");
    if (data.cfo == 1) selectedChecklistItems.add("CFO");
    if (data.oc == 1) selectedChecklistItems.add("OC");

    penaltySelections["RWH Penalty Applicable"] =
    data.rwhPenaltyApplicable == 1
        ? true
        : data.rwhPenaltyApplicable == 0
        ? false
        : null;
    penaltySelections["STP Penalty Applicable"] =
    data.stpPenaltyApplicable == 1
        ? true
        : data.stpPenaltyApplicable == 0
        ? false
        : null;
    penaltySelections["OC Penalty Applicable"] =
    data.ocPenaltyApplicable == 1
        ? true
        : data.ocPenaltyApplicable == 0
        ? false
        : null;

    setState(() {});
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _captureLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentLocationText = "${position.latitude}, ${position.longitude}";
        _isFetchingLocation = false;
        _isLocationSaved = false;
      });
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      AppUtils.toast("Failed to get location: $e");
    }
  }

  Future<void> _saveLocation() async {
    if (_latitude == null || _longitude == null) {
      AppUtils.toast("Please capture your location first.");
      return;
    }
    setState(() => _isSavingLocation = true);
    try {
      final isUpdate = _savedInspectionId != null;
      final response = await _repo.saveLocation(
        ui: "SITE_INSPECTION",
        section: "LOCATION",
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
        inspectionID: isUpdate ? _savedInspectionId : null,
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        isUpdate: isUpdate,
      );
      if (response.isSuccess) {
        final newId = response.data?.inspectionId;
        setState(() {
          _isSavingLocation = false;
          _isLocationSaved = true;
          if (newId != null && newId.isNotEmpty) _savedInspectionId = newId;
        });
        AppUtils.toast(response.message ?? "Location saved successfully.");
      } else {
        setState(() => _isSavingLocation = false);
        AppUtils.toastError(response.error ?? "Failed to save location.");
      }
    } catch (e) {
      setState(() => _isSavingLocation = false);
      AppUtils.toast("Error saving location: $e");
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit(String buttonText) async {
    try {
      final btnData = buttonCtrl.buttonData.value;
      final uiType = btnData?.ui ?? "";
      final isUpdate = buttonText.toUpperCase() == "UPDATE";

      // ── SITE_INSPECTION validations ──────────────────────────────────
      if (uiType == "SITE_INSPECTION") {
        if (!_isLocationSaved || _latitude == null || _longitude == null) {
          AppUtils.toast(
              "Please capture and save your location before submitting.");
          return;
        }

        final existingSiteCount = _existingDocuments
            .where((d) => d.documentType == "SITE_INSPECTION")
            .length;
        if (_siteImages.isEmpty && existingSiteCount == 0) {
          AppUtils.toast("At least one site inspection photo is required.");
          return;
        }
      }

      // ── WORK_COMPLETION_DOCUMENT validations ─────────────────────────
      // FIX: validate remarks and photos before submitting
      if (uiType == "WORK_COMPLETION_DOCUMENT") {
        if (_workCompImages.isEmpty) {
          AppUtils.toast(
              "Please upload at least one work completion photo.");
          return;
        }
        if (_remarksController.text.trim().isEmpty) {
          AppUtils.toast("Please enter remarks before submitting.");
          return;
        }
      }

      // ── Checklist penalty validations ────────────────────────────────
      if (selectedChecklistItems.contains("RWH") &&
          penaltySelections["RWH Penalty Applicable"] == null) {
        AppUtils.toast("Please select RWH Penalty option (Yes/No)");
        return;
      }
      if (selectedChecklistItems.contains("CFO") &&
          penaltySelections["STP Penalty Applicable"] == null) {
        AppUtils.toast("Please select STP Penalty option (Yes/No)");
        return;
      }
      if (selectedChecklistItems.contains("OC") &&
          penaltySelections["OC Penalty Applicable"] == null) {
        AppUtils.toast("Please select OC Penalty option (Yes/No)");
        return;
      }

      final clDetails = btnData?.checklistSection?.details?.checklistDetails;
      final inspectionID = isUpdate ? (_savedInspectionId ?? "") : null;

      // ── Checklist JSON ───────────────────────────────────────────────
      final checklistMap = <String, dynamic>{
        "stage": widget.application.stageNo,
        if (isUpdate) "checklistID": clDetails?.checklistId?.toString() ?? "0",
        "siteInspectionAndMeasurement":
        selectedChecklistItems.contains("Site Inspection and Measurement")
            ? 1
            : 0,
        "khata": selectedChecklistItems.contains("Khata") ? 1 : 0,
        "leaseCumSaledeedOrSaledeed":
        selectedChecklistItems.contains("Lease cum Sale Deed") ? 1 : 0,
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
      final checklist = jsonEncode(checklistMap);

      // ── Build flat files list + documentMetadata ─────────────────────
      final List<File> allFiles = [];
      final List<Map<String, dynamic>> metadataList = [];

      void appendGroup(List<LocalImage> newImages, String docType) {
        if (newImages.isEmpty) return;
        final start = allFiles.length;
        for (final img in newImages) {
          allFiles.add(img.file);
        }
        final indexes =
        List<int>.generate(allFiles.length - start, (i) => start + i);
        metadataList.add({"documentType": docType, "fileIndexes": indexes});
      }

      appendGroup(_siteImages, "SITE_INSPECTION");
      appendGroup(_rwhImages, "RWH");
      appendGroup(_stpImages, "STP");
      appendGroup(_workCompImages, "WORK_COMPLETION_DOCUMENT");

      final String? documentMetadata =
      allFiles.isNotEmpty ? jsonEncode(metadataList) : null;

      // ── FIX: null-safe lat/lng + remarks ────────────────────────────
      final String latStr = _latitude?.toString() ?? "";
      final String lngStr = _longitude?.toString() ?? "";
      final String remarksStr = _remarksController.text.trim();

      AppUtils.log(
          "_handleSubmit | ui:$uiType | update:$isUpdate | newFiles:${allFiles.length} | remarks:$remarksStr");
      AppUtils.log("documentMetadata: $documentMetadata");

      final response = await _repo
          .submitWithFiles(
        inspectionID: inspectionID,
        applicationID: widget.application.applicationId.toString(),
        transactionID: widget.application.transactionId.toString(),
        ui: uiType,
        latitude: latStr,   // FIX: never sends "null" string
        longitude: lngStr,  // FIX: never sends "null" string
        checklist: checklist,
        documentMetadata: documentMetadata,
        files: allFiles,
        remarks: remarksStr.isNotEmpty ? remarksStr : null, // FIX: send remarks
      )
          .applyLoader;

      if (response.isSuccess) {
        AppUtils.toast(response.message ?? "Submitted successfully.");
        context.pop();
      } else {
        AppUtils.toastError(response.error ?? "Submission failed.");
      }
    } catch (e) {
      AppUtils.toast("Error: $e");
    }
  }

  // ── Delete existing document ───────────────────────────────────────────────

  Future<void> _deleteExistingDocument(SiteDocument doc) async {
    final fileID = doc.fileID ?? "";
    if (fileID.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text(
            "Are you sure you want to delete this uploaded image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await _repo.deleteExistingDocument(
      fileID: fileID,
      applicationID: widget.application.applicationId.toString(),
      documentType: doc.documentType ?? "",
    );

    if (response.isSuccess) {
      setState(() {
        _existingDocuments.removeWhere((d) => d.fileID == fileID);
      });
      AppUtils.toast("Image deleted successfully.");
    } else {
      AppUtils.toastError(response.error ?? "Failed to delete image.");
    }
  }

  // ── Image helpers ──────────────────────────────────────────────────────────

  String? _getPenaltyItemFor(String mainItem) {
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

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
      format: CompressFormat.jpeg,
    );
    return compressed == null ? null : File(compressed.path);
  }

  Future<File> _renameToShortName(File file) async {
    final dir = await getTemporaryDirectory();
    final newPath =
        "${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg";
    return file.copy(newPath);
  }

  Future<File?> _addOverlay(File imageFile) async {
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Lat ${_latitude ?? '-'}°   Long ${_longitude ?? '-'}°",
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
      final out = File(
          "${imageFile.parent.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.jpg");
      await out.writeAsBytes(bytes);
      return out;
    } catch (e) {
      AppUtils.log("Overlay error: $e");
      return null;
    }
  }

  int get _totalNewImages =>
      _siteImages.length +
          _rwhImages.length +
          _stpImages.length +
          _workCompImages.length;

  Future<void> _pickImageFor(
      List<LocalImage> targetList, String docType) async {
    if (_totalNewImages >= _maxImagesTotal) {
      AppUtils.toast(
          "Maximum $_maxImagesTotal photos allowed in total across all sections.");
      return;
    }

    FocusScope.of(context).unfocus();

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      AppUtils.toast("Could not open gallery.");
      return;
    }
    if (picked == null) return;

    File file = File(picked.path);
    file = (await _addOverlay(file)) ?? file;
    try {
      final compressed = await _compressImage(file);
      if (compressed != null) file = compressed;
    } catch (_) {}
    try {
      file = await _renameToShortName(file);
    } catch (_) {}

    setState(() => targetList.add(LocalImage(file: file)));
  }

  void _removeLocalImage(List<LocalImage> list, int index) {
    setState(() => list.removeAt(index));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ImageView(
                      url: AppImages.backButton, height: 40, width: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ImageView(
                  url: AppImages.homeScreenAppBar, height: 40, width: 180),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
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

              // ── Read-only info sections ─────────────────────────
              ExpandableSection(
                title: "Application Details",
                icon: AppImages.totalImage,
                color: AppColors.btnColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                  ApplicationDetailScreen(details: widget.details!),
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
                  child:
                  siteDetailsWidget.SiteDetails(details: widget.details!),
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
                      details: widget.details!),
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
                  child: widget.details != null
                      ? Documents(details: widget.details!)
                      : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No documents available.",
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),

              // ── Previously uploaded docs (with delete) ──────────
              if (_existingDocuments.isNotEmpty) ...[
                20.height,
                _buildExistingDocumentsSection(),
              ],

              20.height,

              // ── Reactive section ────────────────────────────────
              Obx(() {
                final btnData = buttonCtrl.buttonData.value;
                if (btnData == null) return const SizedBox.shrink();

                final uiType = btnData.ui ?? "";
                final buttonText = btnData.buttonLabel;

                // ── SITE_INSPECTION ─────────────────────────────
                if (uiType == "SITE_INSPECTION") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationWidget(),

                      if (_isLocationSaved) ...[
                        20.height,
                        _buildDynamicChecklistSection(),
                        20.height,

                        // Site photos
                        TextView(
                            text: "Site Photo", style: 20.txtBoldBlack),
                        TextView(
                          text: "UPLOAD PHOTO",
                          style: 14.txtRegularBlack,
                          margin: 15.top + 15.bottom,
                        ),
                        _buildLocalImageGrid(
                          list: _siteImages,
                          docType: "SITE_INSPECTION",
                          onAdd: () => _pickImageFor(
                              _siteImages, "SITE_INSPECTION"),
                          onRemove: (i) =>
                              _removeLocalImage(_siteImages, i),
                        ),

                        // RWH photos
                        if (selectedChecklistItems.contains("RWH")) ...[
                          20.height,
                          TextView(
                              text: "RWH Photo", style: 20.txtBoldBlack),
                          TextView(
                            text: "UPLOAD PHOTO",
                            style: 14.txtRegularBlack,
                            margin: 15.top + 15.bottom,
                          ),
                          _buildLocalImageGrid(
                            list: _rwhImages,
                            docType: "RWH",
                            onAdd: () =>
                                _pickImageFor(_rwhImages, "RWH"),
                            onRemove: (i) =>
                                _removeLocalImage(_rwhImages, i),
                          ),
                        ],

                        // STP photos
                        if (selectedChecklistItems.contains("CFO")) ...[
                          20.height,
                          TextView(
                              text: "STP Photo", style: 20.txtBoldBlack),
                          TextView(
                            text: "UPLOAD PHOTO",
                            style: 14.txtRegularBlack,
                            margin: 15.top + 15.bottom,
                          ),
                          _buildLocalImageGrid(
                            list: _stpImages,
                            docType: "STP",
                            onAdd: () =>
                                _pickImageFor(_stpImages, "STP"),
                            onRemove: (i) =>
                                _removeLocalImage(_stpImages, i),
                          ),
                        ],
                      ],

                      20.height,
                      _buildBottomButtons(buttonText),
                    ],
                  );
                }

                // ── WORK_COMPLETION_DOCUMENT ─────────────────────
                if (uiType == "WORK_COMPLETION_DOCUMENT") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "Work Completion Photo",
                        style: 20.txtBoldBlack,
                      ),
                      TextView(
                        text: "UPLOAD PHOTO",
                        style: 14.txtRegularBlack,
                        margin: 15.top + 15.bottom,
                      ),
                      _buildLocalImageGrid(
                        list: _workCompImages,
                        docType: "WORK_COMPLETION_DOCUMENT",
                        onAdd: () => _pickImageFor(
                            _workCompImages, "WORK_COMPLETION_DOCUMENT"),
                        onRemove: (i) =>
                            _removeLocalImage(_workCompImages, i),
                      ),
                      TextView(
                        margin: 20.top,
                        text: "Remarks",
                        style: 20.txtBoldBlack,
                      ),
                      // FIX: RemarksField is wired to _remarksController
                      RemarksField(controller: _remarksController),
                      20.height,
                      _buildBottomButtons(buttonText),
                    ],
                  );
                }

                return _buildBottomButtons(buttonText);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  Widget _buildExistingDocumentsSection() {
    final Map<String, List<SiteDocument>> grouped = {};
    for (final doc in _existingDocuments) {
      final type = doc.documentType ?? "OTHER";
      grouped.putIfAbsent(type, () => []).add(doc);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(text: "Uploaded Documents", style: 20.txtBoldBlack),
        8.height,
        Text(
          "Previously uploaded images. Tap × to remove.",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        12.height,
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.btnColor.withOpacity(0.3)),
                ),
                child: Text(
                  _formatDocumentType(entry.key),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.btnColor,
                  ),
                ),
              ),
              _buildExistingImageGrid(entry.value),
              12.height,
            ],
          );
        }).toList(),
      ],
    );
  }

  String _formatDocumentType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Widget _buildExistingImageGrid(List<SiteDocument> docs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) =>
          _buildExistingImageTile(docs[index]),
    );
  }

  Widget _buildExistingImageTile(SiteDocument doc) {
    Widget imageWidget;

    if (doc.hasImage) {
      try {
        final Uint8List bytes = base64Decode(doc.rawBase64!);
        imageWidget = GestureDetector(
          onTap: () => _showFullScreenImage(bytes, doc.originalFileName),
          child: Image.memory(bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _brokenImageWidget()),
        );
      } catch (_) {
        imageWidget = _brokenImageWidget();
      }
    } else {
      imageWidget = Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                doc.originalFileName ?? doc.filename ?? "Image",
                style: const TextStyle(fontSize: 8, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.expand(child: imageWidget),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: () => _deleteExistingDocument(doc),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 12,
              child: Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _brokenImageWidget() => Container(
    color: Colors.grey[200],
    child: const Center(
      child: Icon(Icons.broken_image_outlined,
          color: Colors.grey, size: 28),
    ),
  );

  void _showFullScreenImage(Uint8List imageBytes, String? fileName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
            if (fileName != null)
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fileName,
                    style:
                    const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Location widget ────────────────────────────────────────────────────────

  Widget _buildLocationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "GET LOCATION",
          style: 14.txtRegularBlack,
          margin: 15.top + 10.bottom,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey, width: 1),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("Fetching...",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentLocationText ?? 'Location not captured',
                        style: TextStyle(
                          fontSize: 12,
                          color: _currentLocationText != null
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isLocationSaved) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.green.shade300, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 10,
                                color: Colors.green.shade600),
                            const SizedBox(width: 3),
                            Text(
                              "Saved",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_isFetchingLocation || _isSavingLocation)
                    ? null
                    : _captureLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text(
                  'Get',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_latitude != null && _longitude != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSavingLocation ? null : _saveLocation,
              icon: _isSavingLocation
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(
                _isLocationSaved
                    ? Icons.edit_location_alt_outlined
                    : Icons.save_alt_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                _isSavingLocation
                    ? "Saving..."
                    : _isLocationSaved
                    ? "Update Location"
                    : "Save Location",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLocationSaved
                    ? Colors.green.shade600
                    : AppColors.btnColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        if (!_isLocationSaved)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _latitude == null
                  ? "Capture your location to unlock checklist and photos."
                  : "Tap \"Save Location\" to unlock checklist and photos.",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  // ── Checklist ──────────────────────────────────────────────────────────────

  Widget _buildDynamicChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(text: "Checklist", style: 20.txtBoldBlack),
        10.height,
        ...checklistItems.map((item) {
          final penaltyItem = _getPenaltyItemFor(item);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxTile(item),
              if (penaltyItem != null && selectedChecklistItems.contains(item))
                _buildPenaltyRadioButtons(penaltyItem),
            ],
          );
        }).toList(),
      ],
    );
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
                final p = _getPenaltyItemFor(label);
                if (p != null) penaltySelections[p] = null;
              }
            });
          },
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: AppColors.white,
          checkColor: AppColors.btnColor,
          side: MaterialStateBorderSide.resolveWith(
                  (_) => BorderSide(color: AppColors.btnColor, width: 1)),
        ),
        Expanded(child: TextView(text: label, style: 16.txtRegularBlack)),
      ],
    );
  }

  Widget _buildPenaltyRadioButtons(String penaltyType) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(text: penaltyType, style: 14.txtBoldBlack),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(children: [
                  Radio<bool>(
                    value: true,
                    groupValue: penaltySelections[penaltyType],
                    onChanged: (v) =>
                        setState(() => penaltySelections[penaltyType] = v),
                    activeColor: AppColors.btnColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  TextView(text: "Yes", style: 14.txtRegularBlack),
                ]),
              ),
              Expanded(
                child: Row(children: [
                  Radio<bool>(
                    value: false,
                    groupValue: penaltySelections[penaltyType],
                    onChanged: (v) =>
                        setState(() => penaltySelections[penaltyType] = v),
                    activeColor: AppColors.btnColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  TextView(text: "No", style: 14.txtRegularBlack),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Local image grid ───────────────────────────────────────────────────────

  Widget _buildLocalImageGrid({
    required List<LocalImage> list,
    required String docType,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
  }) {
    final showAddTile = _totalNewImages < _maxImagesTotal;
    final itemCount = showAddTile ? list.length + 1 : list.length;

    if (itemCount == 0) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (showAddTile && index == list.length) {
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
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(list[index].file),
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
      },
    );
  }

  // ── Bottom buttons ─────────────────────────────────────────────────────────

  Widget _buildBottomButtons(String buttonText) {
    if (buttonText.isEmpty) return const SizedBox.shrink();
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
            onTap: () => context.pop(),
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
            onTap: () async => await _handleSubmit(buttonText),
          ),
        ),
      ],
    );
  }
}

// ─── ExpandableSection ────────────────────────────────────────────────────────

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
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: _buildTile(),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: widget.child,
          crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(widget.icon, width: 20, color: widget.color),
      ),
      title: TextView(text: widget.title, style: 16.txtRegularBlack),
      trailing: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: AppColors.grey,
      ),
    );
  }
}

// ─── LocalImage ───────────────────────────────────────────────────────────────

class LocalImage {
  final File file;
  LocalImage({required this.file});
}