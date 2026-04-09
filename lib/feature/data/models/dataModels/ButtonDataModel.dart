class ApiResponse {
  final bool success;
  final String message;
  final ButtonData data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ButtonData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

// ─── Top-level data object ────────────────────────────────────────────────────

class ButtonData {
  final String? ui;
  final int? screenNo;

  /// Sections are present only after the first submission (UPDATE flow).
  /// On the very first load, this list is null / empty.
  final List<ButtonSection>? sections;

  ButtonData({
    this.ui,
    this.screenNo,
    this.sections,
  });

  // ── Convenience getters ───────────────────────────────────────────────────

  /// True when the API has returned at least one section (i.e. UPDATE flow).
  bool get hasSections => sections != null && sections!.isNotEmpty;

  /// Returns the LOCATION section if present.
  ButtonSection? get locationSection => _sectionByType("LOCATION");

  /// Returns the CHECKLIST section if present.
  ButtonSection? get checklistSection => _sectionByType("CHECKLIST");

  ButtonSection? _sectionByType(String type) {
    try {
      return sections?.firstWhere(
            (s) => s.section.toUpperCase() == type,
      );
    } catch (_) {
      return null;
    }
  }

  /// The button label to display.
  /// Uses the CHECKLIST section label when sections exist, otherwise falls
  /// back to the first section's label, and finally to a generic "SUBMIT".
  String get buttonLabel {
    if (!hasSections) return "SUBMIT";
    final cl = checklistSection?.buttonLabel;
    if (cl != null && cl.isNotEmpty) return cl;
    return sections!.first.buttonLabel ?? "SUBMIT";
  }

  factory ButtonData.fromJson(Map<String, dynamic> json) {
    List<ButtonSection>? sections;
    final raw = json['sections'];
    if (raw is List) {
      sections = raw
          .map((e) => ButtonSection.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ButtonData(
      ui: json['ui'] as String?,
      screenNo: json['screenNo'] as int?,
      sections: sections,
    );
  }

  Map<String, dynamic> toJson() => {
    "ui": ui,
    "screenNo": screenNo,
    "sections": sections?.map((s) => s.toJson()).toList(),
  };
}

// ─── Section ──────────────────────────────────────────────────────────────────

class ButtonSection {
  final String section;
  final SectionDetails? details;
  final String? buttonLabel;

  ButtonSection({
    required this.section,
    this.details,
    this.buttonLabel,
  });

  factory ButtonSection.fromJson(Map<String, dynamic> json) {
    return ButtonSection(
      section: json['section'] as String? ?? '',
      details: json['details'] != null
          ? SectionDetails.fromJson(
        json['details'] as Map<String, dynamic>,
        json['section'] as String? ?? '',
      )
          : null,
      buttonLabel: json['buttonLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "section": section,
    "details": details?.toJson(),
    "buttonLabel": buttonLabel,
  };
}

// ─── Section details (polymorphic) ───────────────────────────────────────────

class SectionDetails {
  /// Present when section == "LOCATION"
  final LocationDetails? location;

  /// Present when section == "CHECKLIST"
  final ChecklistSectionDetails? checklistDetails;
  final List<SiteDocument>? documents;

  SectionDetails({
    this.location,
    this.checklistDetails,
    this.documents,
  });

  factory SectionDetails.fromJson(
      Map<String, dynamic> json, String sectionType) {
    LocationDetails? location;
    ChecklistSectionDetails? checklist;
    List<SiteDocument>? documents;

    switch (sectionType.toUpperCase()) {
      case "LOCATION":
        location = LocationDetails.fromJson(json);
        break;
      case "CHECKLIST":
        if (json['checkList'] != null) {
          checklist = ChecklistSectionDetails.fromJson(
            json['checkList'] as Map<String, dynamic>,
          );
        }
        if (json['documents'] is List) {
          documents = (json['documents'] as List)
              .map((e) => SiteDocument.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        break;
    }

    return SectionDetails(
      location: location,
      checklistDetails: checklist,
      documents: documents,
    );
  }

  Map<String, dynamic> toJson() => {
    if (location != null) ...location!.toJson(),
    if (checklistDetails != null) "checkList": checklistDetails!.toJson(),
    if (documents != null)
      "documents": documents!.map((d) => d.toJson()).toList(),
  };
}

// ─── Location details ─────────────────────────────────────────────────────────

class LocationDetails {
  final int? inspectionId;
  final int? applicationId;
  final String? latitude;
  final String? longitude;

  LocationDetails({
    this.inspectionId,
    this.applicationId,
    this.latitude,
    this.longitude,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      inspectionId: int.tryParse(json['inspectionID']?.toString() ?? ''),
      applicationId: int.tryParse(json['applicationID']?.toString() ?? ''),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "inspectionID": inspectionId,
    "applicationID": applicationId,
    "latitude": latitude,
    "longitude": longitude,
  };
}

// ─── Checklist details ────────────────────────────────────────────────────────

class ChecklistSectionDetails {
  final int? checklistId;
  final int? transactionId;
  final int? stage;
  final int? khata;
  final int? leaseCumSaleDeedOrSaleDeed;
  final int? buildingPlan;
  final int? rwh;
  final int? rwhPenaltyApplicable;
  final int? bwssbNoc;
  final int? cfo;
  final int? stpPenaltyApplicable;
  final int? oc;
  final int? ocPenaltyApplicable;
  final int? siteInspectionAndMeasurement;
  final int? crtBy;

  ChecklistSectionDetails({
    this.checklistId,
    this.transactionId,
    this.stage,
    this.khata,
    this.leaseCumSaleDeedOrSaleDeed,
    this.buildingPlan,
    this.rwh,
    this.rwhPenaltyApplicable,
    this.bwssbNoc,
    this.cfo,
    this.stpPenaltyApplicable,
    this.oc,
    this.ocPenaltyApplicable,
    this.siteInspectionAndMeasurement,
    this.crtBy,
  });

  factory ChecklistSectionDetails.fromJson(Map<String, dynamic> json) {
    return ChecklistSectionDetails(
      checklistId: int.tryParse(json['checklistID']?.toString() ?? ''),
      transactionId: int.tryParse(json['transactionID']?.toString() ?? ''),
      stage: int.tryParse(json['stage']?.toString() ?? ''),
      khata: int.tryParse(json['khata']?.toString() ?? ''),
      leaseCumSaleDeedOrSaleDeed:
      int.tryParse(json['leaseCumSaledeedOrSaledeed']?.toString() ?? ''),
      buildingPlan: int.tryParse(json['buildingPlan']?.toString() ?? ''),
      rwh: int.tryParse(json['rwh']?.toString() ?? ''),
      rwhPenaltyApplicable:
      int.tryParse(json['rwhPenaltyApplicable']?.toString() ?? ''),
      bwssbNoc: int.tryParse(json['bwssbNoc']?.toString() ?? ''),
      cfo: int.tryParse(json['cfo']?.toString() ?? ''),
      stpPenaltyApplicable:
      int.tryParse(json['stpPenaltyApplicable']?.toString() ?? ''),
      oc: int.tryParse(json['oc']?.toString() ?? ''),
      ocPenaltyApplicable:
      int.tryParse(json['ocPenaltyApplicable']?.toString() ?? ''),
      siteInspectionAndMeasurement: int.tryParse(
          json['siteInspectionAndMeasurement']?.toString() ?? ''),
      crtBy: int.tryParse(json['crtby']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    "checklistID": checklistId,
    "transactionID": transactionId,
    "stage": stage,
    "khata": khata,
    "leaseCumSaledeedOrSaledeed": leaseCumSaleDeedOrSaleDeed,
    "buildingPlan": buildingPlan,
    "rwh": rwh,
    "rwhPenaltyApplicable": rwhPenaltyApplicable,
    "bwssbNoc": bwssbNoc,
    "cfo": cfo,
    "stpPenaltyApplicable": stpPenaltyApplicable,
    "oc": oc,
    "ocPenaltyApplicable": ocPenaltyApplicable,
    "siteInspectionAndMeasurement": siteInspectionAndMeasurement,
    "crtby": crtBy,
  };
}

// ─── Site document ────────────────────────────────────────────────────────────

class SiteDocument {
  final String? filename;
  final String? originalFileName;
  final String? mimeType;
  final String? fileID;
  final String? userID;
  final String? uploadedBy;
  final String? bucketName;
  final String? documentType;

  /// Base64-encoded image string, may include data URI prefix
  /// e.g. "data:image/png;base64,iVBOR..."
  final String? base64;

  final String? applicationID;
  final String? documentID;
  final String? transactionID;
  final bool? isAdditionalDocument;
  final String? createdAt;

  SiteDocument({
    this.filename,
    this.originalFileName,
    this.mimeType,
    this.fileID,
    this.userID,
    this.uploadedBy,
    this.bucketName,
    this.documentType,
    this.base64,
    this.applicationID,
    this.documentID,
    this.transactionID,
    this.isAdditionalDocument,
    this.createdAt,
  });

  factory SiteDocument.fromJson(Map<String, dynamic> json) {
    return SiteDocument(
      filename: json['filename'] as String?,
      originalFileName: json['originalFileName'] as String?,
      mimeType: json['mimeType'] as String?,
      fileID: json['fileID'] as String?,
      userID: json['userID'] as String?,
      uploadedBy: json['uploadedBy'] as String?,
      bucketName: json['bucketName'] as String?,
      documentType: json['documentType'] as String?,
      base64: json['base64'] as String?,
      applicationID: json['applicationID']?.toString(),
      documentID: json['documentID']?.toString(),
      transactionID: json['transactionID']?.toString(),
      isAdditionalDocument: json['isAdditionalDocument'] as bool?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "originalFileName": originalFileName,
    "mimeType": mimeType,
    "fileID": fileID,
    "userID": userID,
    "uploadedBy": uploadedBy,
    "bucketName": bucketName,
    "documentType": documentType,
    "base64": base64,
    "applicationID": applicationID,
    "documentID": documentID,
    "transactionID": transactionID,
    "isAdditionalDocument": isAdditionalDocument,
    "createdAt": createdAt,
  };

  /// Strips the data URI prefix and returns raw base64 string,
  /// or null if base64 is absent.
  String? get rawBase64 {
    if (base64 == null || base64!.isEmpty) return null;
    return base64!.contains(',') ? base64!.split(',').last : base64;
  }

  /// True if this document has usable image data.
  bool get hasImage => rawBase64 != null && rawBase64!.isNotEmpty;
}