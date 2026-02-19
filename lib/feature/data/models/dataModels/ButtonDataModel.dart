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

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data.toJson(),
    };
  }
}

class ButtonData {
  final String? ui;
  final int? screenNo;
  final ButtonDetails? details;
  final String? button;

  ButtonData({
    this.ui,
    this.screenNo,
    this.details,
    this.button,
  });

  factory ButtonData.fromJson(Map<String, dynamic> json) {
    return ButtonData(
      ui: json['ui'] as String?,
      screenNo: json['screenNo'] as int?,
      details: json['details'] != null
          ? ButtonDetails.fromJson(json['details'])
          : null,
      button: json['button'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ui": ui,
      "screenNo": screenNo,
      "details": details?.toJson(),
      "button": button,
    };
  }
}

class ButtonDetails {
  final ChecklistDetails? checklistDetails;
  final SiteInspectionDetails? siteInspectionDetails;
  final WorkCompletionDetails? workCompletionDetails;

  ButtonDetails({
    this.checklistDetails,
    this.siteInspectionDetails,
    this.workCompletionDetails,
  });

  factory ButtonDetails.fromJson(Map<String, dynamic> json) {
    return ButtonDetails(
      checklistDetails: json['checklistDetails'] != null
          ? ChecklistDetails.fromJson(json['checklistDetails'])
          : null,
      siteInspectionDetails: json['siteInspectionDetails'] != null
          ? SiteInspectionDetails.fromJson(json['siteInspectionDetails'])
          : null,
      workCompletionDetails: json['workCompletionDetails'] != null
          ? WorkCompletionDetails.fromJson(json['workCompletionDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "checklistDetails": checklistDetails?.toJson(),
    "siteInspectionDetails": siteInspectionDetails?.toJson(),
    "workCompletionDetails": workCompletionDetails?.toJson(),
  };
}




class ChecklistDetails {
  final int? stageId;
  final String? designationName;
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
  final String? crtDate;
  final int? applicationId;
  final int? checklistId;
  final int? transactionId;
  final int? crtBy;

  ChecklistDetails({
    this.stageId,
    this.designationName,
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
    this.crtDate,
    this.applicationId,
    this.checklistId,
    this.transactionId,
    this.crtBy,
  });

  factory ChecklistDetails.fromJson(Map<String, dynamic> json) {
    return ChecklistDetails(
      stageId: int.tryParse(json['stage_id']?.toString() ?? ''),
      designationName: json['designation_name'] as String?,
      khata: int.tryParse(json['khata']?.toString() ?? ''),
      leaseCumSaleDeedOrSaleDeed: int.tryParse(json['Lease_cum_sale_deed_or_sale_deed']?.toString() ?? ''),
      buildingPlan: int.tryParse(json['building_plan']?.toString() ?? ''),
      rwh: int.tryParse(json['rwh']?.toString() ?? ''),
      rwhPenaltyApplicable: int.tryParse(json['rwh_penalty_applicable']?.toString() ?? ''),
      bwssbNoc: int.tryParse(json['bwssb_noc']?.toString() ?? ''),
      cfo: int.tryParse(json['cfo']?.toString() ?? ''),
      stpPenaltyApplicable: int.tryParse(json['stp_penalty_applicable']?.toString() ?? ''),
      oc: int.tryParse(json['oc']?.toString() ?? ''),
      ocPenaltyApplicable: int.tryParse(json['oc_penalty_applicable']?.toString() ?? ''),
      siteInspectionAndMeasurement: int.tryParse(json['site_inspection_and_measurement']?.toString() ?? ''),
      crtDate: json['crtdate'] as String?,
      applicationId: int.tryParse(json['applicationID']?.toString() ?? ''),
      checklistId: int.tryParse(json['checklistID']?.toString() ?? ''),
      transactionId: int.tryParse(json['transactionID']?.toString() ?? ''),
      crtBy: int.tryParse(json['crtby']?.toString() ?? ''),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "stage_id": stageId,
      "designation_name": designationName,
      "khata": khata,
      "Lease_cum_sale_deed_or_sale_deed": leaseCumSaleDeedOrSaleDeed,
      "building_plan": buildingPlan,
      "rwh": rwh,
      "rwh_penalty_applicable": rwhPenaltyApplicable,
      "bwssb_noc": bwssbNoc,
      "cfo": cfo,
      "stp_penalty_applicable": stpPenaltyApplicable,
      "oc": oc,
      "oc_penalty_applicable": ocPenaltyApplicable,
      "site_inspection_and_measurement": siteInspectionAndMeasurement,
      "crtdate": crtDate,
      "applicationID": applicationId,
      "checklistID": checklistId,
      "transactionID": transactionId,
      "crtby": crtBy,
    };
  }
}

class SiteInspectionDetails {
  final int? inspectionId;
  final int? applicationId;
  final String? latitude;
  final String? longitude;
  final List<SiteDocument>? documents;

  SiteInspectionDetails({
    this.inspectionId,
    this.applicationId,
    this.latitude,
    this.longitude,
    this.documents,
  });

  factory SiteInspectionDetails.fromJson(Map<String, dynamic> json) {
    return SiteInspectionDetails(
      inspectionId: int.tryParse(json['inspectionID']?.toString() ?? ''),
      applicationId: int.tryParse(json['applicationID']?.toString() ?? ''),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => SiteDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "inspectionID": inspectionId,
      "applicationID": applicationId,
      "latitude": latitude,
      "longitude": longitude,
      "documents": documents?.map((e) => e.toJson()).toList(),
    };
  }
}

class SiteDocument {
  final String? filename;
  final String? originalFileName;
  final String? mimeType;
  final String? fileID;
  final String? userID;
  final String? uploadedBy;
  final String? bucketName;
  final String? documentType;
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

  Map<String, dynamic> toJson() {
    return {
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
  }
}

class WorkCompletionDetails {

  WorkCompletionDetails();

  factory WorkCompletionDetails.fromJson(Map<String, dynamic> json) {
    return WorkCompletionDetails();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
