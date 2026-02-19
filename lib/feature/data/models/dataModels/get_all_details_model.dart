class GetAllDetailsModel {
  final int? inspectionID;
  final ConnectionDetails? connectionDetails;
  final SiteDetails? siteDetails;
  final BuildingDetails? buildingDetails;
  final DocumentDetails? documentDetails;
  final Charges? charges;
  final int? totalPayable;

  // 🔹 New fields
  final ChecklistDetails? checklistDetails;
  final SiteInspectionDetails? siteInspectionDetails;
  final WorkCompletionDetails? workCompletionDetails;

  GetAllDetailsModel({
    this.inspectionID,
    this.connectionDetails,
    this.siteDetails,
    this.buildingDetails,
    this.documentDetails,
    this.charges,
    this.totalPayable,
    this.checklistDetails,
    this.siteInspectionDetails,
    this.workCompletionDetails,
  });

  factory GetAllDetailsModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return GetAllDetailsModel(
      inspectionID: parseInt(json['inspectionID']),
      connectionDetails: json['connectionDetails'] != null
          ? ConnectionDetails.fromJson(json['connectionDetails'])
          : null,
      siteDetails: json['siteDetails'] != null
          ? SiteDetails.fromJson(json['siteDetails'])
          : null,
      buildingDetails: json['buildingDetails'] != null
          ? BuildingDetails.fromJson(json['buildingDetails'])
          : null,
      documentDetails: json['documentDetails'] != null
          ? DocumentDetails.fromJson(json['documentDetails'])
          : null,
      charges: json['charges'] != null
          ? Charges.fromJson(json['charges'])
          : null,
      totalPayable: parseInt(json['totalPayable']),

      // 🔹 Hook new models
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
}


class SiteInspectionDetails {
  final int? inspectionID;
  final int? applicationID;
  final String? latitude;
  final String? longitude;
  final List<Document>? documents;

  SiteInspectionDetails({
    this.inspectionID,
    this.applicationID,
    this.latitude,
    this.longitude,
    this.documents,
  });

  factory SiteInspectionDetails.fromJson(Map<String, dynamic> json) {
    return SiteInspectionDetails(
      inspectionID: json['inspectionID'],
      applicationID: json['applicationID'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}

class WorkCompletionDetails {
  // fill as per API if needed
  WorkCompletionDetails();

  factory WorkCompletionDetails.fromJson(Map<String, dynamic> json) {
    return WorkCompletionDetails();
  }
}



// Connection Details
class ConnectionDetails {
  final ConsumerDetails? consumerDetails;
  final CommunicationDetails? communicationDetails;
  final ConnectionInfo? connectionDetails;

  ConnectionDetails({
    this.consumerDetails,
    this.communicationDetails,
    this.connectionDetails,
  });

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) {
    return ConnectionDetails(
      consumerDetails: json['consumerDetails'] != null
          ? ConsumerDetails.fromJson(json['consumerDetails'])
          : null,
      communicationDetails: json['communicationDetails'] != null
          ? CommunicationDetails.fromJson(json['communicationDetails'])
          : null,
      connectionDetails: json['connectionDetails'] != null
          ? ConnectionInfo.fromJson(json['connectionDetails'])
          : null,
    );
  }
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
  final int? applicationID;
  final int? checklistID;
  final int? transactionID;
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
    this.applicationID,
    this.checklistID,
    this.transactionID,
    this.crtBy,
  });

  factory ChecklistDetails.fromJson(Map<String, dynamic> json) {
    return ChecklistDetails(
      stageId: json['stage_id'],
      designationName: json['designation_name'],
      khata: json['khata'],
      leaseCumSaleDeedOrSaleDeed: json['Lease_cum_sale_deed_or_sale_deed'],
      buildingPlan: json['building_plan'],
      rwh: json['rwh'],
      rwhPenaltyApplicable: json['rwh_penalty_applicable'],
      bwssbNoc: json['bwssb_noc'],
      cfo: json['cfo'],
      stpPenaltyApplicable: json['stp_penalty_applicable'],
      oc: json['oc'],
      ocPenaltyApplicable: json['oc_penalty_applicable'],
      siteInspectionAndMeasurement: json['site_inspection_and_measurement'],
      crtDate: json['crtdate'],
      applicationID: json['applicationID'],
      checklistID: json['checklistID'],
      transactionID: json['transactionID'],
      crtBy: json['crtby'],
    );
  }
}

class ConsumerDetails {
  final String? name, email, mobile;
  final dynamic bescomDetails;

  ConsumerDetails({this.name, this.email, this.mobile, this.bescomDetails});

  factory ConsumerDetails.fromJson(Map<String, dynamic> json) {
    return ConsumerDetails(
      name: json['name'] ?? '',
      email: json['email'],
      mobile: json['mobile'],
      bescomDetails: json['bescomDetails'],
    );
  }
}

class CommunicationDetails {
  final String? state, districtName, talukName, address, landmark, pincode;
  final int? district, taluk;
  final dynamic pincodeId;

  CommunicationDetails({
    this.state,
    this.district,
    this.districtName,
    this.taluk,
    this.talukName,
    this.address,
    this.landmark,
    this.pincode,
    this.pincodeId,
  });

  factory CommunicationDetails.fromJson(Map<String, dynamic> json) {
    return CommunicationDetails(
      state: json['state'],
      district: json['district'],
      districtName: json['district_name'],
      taluk: json['taluk'],
      talukName: json['taluk_name'],
      address: json['address'],
      landmark: json['landmark'],
      pincode: json['pincode'],
      pincodeId: json['pincode_id'],
    );
  }
}

class ConnectionInfo {
  final int? serviceAreaId, serviceStationId, subdivisionId, divisionId, wardId, wardNo, isBwssbConnection;
  final String? street1, serviceareaName, serviceStationName, subdivisionName, divisionName, pincode, wardName;
  final dynamic street2, connectionLandmark, rrNumber, pincodeId;
  final RRDetails? rrDetails; // 🔴 Add this line

  ConnectionInfo({
    this.serviceAreaId,
    this.street1,
    this.street2,
    this.connectionLandmark,
    this.serviceareaName,
    this.serviceStationId,
    this.serviceStationName,
    this.subdivisionId,
    this.subdivisionName,
    this.divisionId,
    this.divisionName,
    this.pincodeId,
    this.pincode,
    this.wardId,
    this.wardName,
    this.wardNo,
    this.rrNumber,
    this.isBwssbConnection,
    this.rrDetails, // 🔴 Add this
  });

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      serviceAreaId: json['service_area_id'],
      street1: json['street1'],
      street2: json['street2'],
      connectionLandmark: json['connection_landmark'],
      serviceareaName: json['servicearea_name'],
      serviceStationId: json['service_station_id'],
      serviceStationName: json['service_station_name'],
      subdivisionId: json['subdivision_id'],
      subdivisionName: json['subdivision_name'],
      divisionId: json['division_id'],
      divisionName: json['division_name'],
      pincodeId: json['pincode_id'],
      pincode: json['pincode'],
      wardId: json['ward_id'],
      wardName: json['ward_name'],
      wardNo: json['ward_no'],
      rrNumber: json['rr_number'],
      isBwssbConnection: json['is_bwssb_connection'],
      rrDetails: json['rrDetails'] != null ? RRDetails.fromJson(json['rrDetails']) : null, // ✅
    );
  }
}


class RRDetails {
  final String? rrNumber, consumerName, address, city, sdid, serviceStation, wardName;
  final String? pincode;
  final int? arrears;
  final String? monthYear;

  RRDetails({
    this.rrNumber,
    this.consumerName,
    this.address,
    this.city,
    this.sdid,
    this.serviceStation,
    this.wardName,
    this.pincode,
    this.arrears,
    this.monthYear,
  });

  factory RRDetails.fromJson(Map<String, dynamic> json) {
    return RRDetails(
      rrNumber: json['rrnumber'],
      consumerName: json['ConsumerName'],
      address: json['Address'],
      city: json['City'],
      sdid: json['SDID'],
      serviceStation: json['Servicestation'],
      wardName: json['Wardname'],
      pincode: json['pincode'],
      arrears: json['Arrears'],
      monthYear: json['MonthYear'],
    );
  }
}


class SiteDetails {
  final PIDDetails? pIDDetails;
  final dynamic panDetails;
  final RWHDetails? rwhDetails;
  final NOCDetails? nocDetails;
  final int? purpose, numberOfFlats, numberOfToilets;
  final String? purposeName, yearOfConstruction;
  final Area? sitalArea, builtUpArea;
  final OCDetails? ocDetails;


  SiteDetails({
    this.pIDDetails,
    this.panDetails,
    this.purpose,
    this.purposeName,
    this.numberOfFlats,
    this.numberOfToilets,
    this.yearOfConstruction,
    this.sitalArea,
    this.builtUpArea,
    this.ocDetails,
    this.rwhDetails,
    this.nocDetails,
  });

  factory SiteDetails.fromJson(Map<String, dynamic> json) {
    return SiteDetails(
      pIDDetails: json['pIDDetails'] != null ? PIDDetails.fromJson(json['pIDDetails']) : null,
      panDetails: json['panDetails'],
      purpose: json['purpose'],
      purposeName: json['purpose_name'],
      numberOfFlats: json['noOfFlats'],
      numberOfToilets: json['noOfToilets'],
      yearOfConstruction: json['year_of_construction'],
      sitalArea: json['sitalArea'] != null ? Area.fromJson(json['sitalArea']) : null,
      builtUpArea: json['builtUpArea'] != null ? Area.fromJson(json['builtUpArea']) : null,
      ocDetails: json['ocDetails'] != null ? OCDetails.fromJson(json['ocDetails']) : null,
      rwhDetails: json['rwhDetails'] != null ? RWHDetails.fromJson(json['rwhDetails']) : null,
      nocDetails: json['nocDetails'] != null ? NOCDetails.fromJson(json['nocDetails']) : null,
    );
  }
}




class RWHDetails {
  final int? isRwhAvailable;
  final List<Document>? rwhDocuments;

  RWHDetails({this.isRwhAvailable, this.rwhDocuments});

  factory RWHDetails.fromJson(Map<String, dynamic> json) {
    return RWHDetails(
      isRwhAvailable: json['is_rwh_available'],
      rwhDocuments: (json['rwh_document_id'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}

class NOCDetails {
  final int? isNocAvailable;
  final String? nocNumber;
  final List<Document>? nocDocuments;

  NOCDetails({this.isNocAvailable, this.nocNumber, this.nocDocuments});

  factory NOCDetails.fromJson(Map<String, dynamic> json) {
    return NOCDetails(
      isNocAvailable: json['is_noc_available'],
      nocNumber: json['noc_number'],
      nocDocuments: (json['noc_document_id'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}




class PIDDetails {
  final int? isPidVerified;
  final String? pidNumber, kathaNumber;
  final dynamic typeofno, wardcodeOld, wardcodeNew, wardnameOld, wardnameNew, streetcode, streetcode1, propertyno, propertyaddr, pincode, ownername;

  PIDDetails({
    this.isPidVerified,
    this.pidNumber,
    this.kathaNumber,
    this.typeofno,
    this.wardcodeOld,
    this.wardcodeNew,
    this.wardnameOld,
    this.wardnameNew,
    this.streetcode,
    this.streetcode1,
    this.propertyno,
    this.propertyaddr,
    this.pincode,
    this.ownername,
  });

  factory PIDDetails.fromJson(Map<String, dynamic> json) {
    return PIDDetails(
      isPidVerified: json['is_pid_verified'],
      pidNumber: json['pID'],
      kathaNumber: json['kathaNumber'],
      typeofno: json['typeofno'],
      wardcodeOld: json['wardcode_old'],
      wardcodeNew: json['wardcode_new'],
      wardnameOld: json['wardname_old'],
      wardnameNew: json['wardname_new'],
      streetcode: json['streetcode'],
      streetcode1: json['streetcode1'],
      propertyno: json['propertyno'],
      propertyaddr: json['propertyaddr'],
      pincode: json['pincode'],
      ownername: json['ownername'],
    );
  }
}

/*
class Area {
  final double? sqFeet;
  final double? sqMeter;

  Area({this.sqFeet, this.sqMeter});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      sqFeet: (json['sqFeet'] as num?)?.toDouble(),
      sqMeter: (json['sqMeter'] as num?)?.toDouble(),
    );
  }
}
*/


class Area {
  final double? sqFeet;
  final double? sqMeter;

  Area({this.sqFeet, this.sqMeter});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      sqFeet: _parseDouble(json['sqFeet']),
      sqMeter: _parseDouble(json['sqMeter']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class OCDetails {
  final int? isOcAvailable;
  final String? ocNumber, ocDate;
  final List<Document>? ocDocuments;

  OCDetails({this.isOcAvailable, this.ocNumber, this.ocDate, this.ocDocuments});

  factory OCDetails.fromJson(Map<String, dynamic> json) {
    return OCDetails(
      isOcAvailable: json['is_oc_available'],
      ocNumber: json['oc_number'],
      ocDate: json['oc_date'],
      ocDocuments: (json['oc_document_id'] as List?)?.map((e) => Document.fromJson(e)).toList() ?? [],

    );
  }
}

// Building Details
class BuildingDetails {
  final int? plumberID, purpose;
  final String? plumberName, purposeTypeName,purposeName;
  final dynamic mutualAgreement;
  final List<BuildingInfo>? floorDetails;

  BuildingDetails({
    this.plumberID,
    this.plumberName,
    this.purposeName,
    this.mutualAgreement,
    this.purpose,
    this.purposeTypeName,
    this.floorDetails,
  });

  factory BuildingDetails.fromJson(Map<String, dynamic> json) {
    return BuildingDetails(
      plumberID: json['plumberID'],
      plumberName: json['plumberName'],
      purposeName: json['purposeName'],
      mutualAgreement: json['mutualAgreement'],
      purpose: json['purpose'],
      purposeTypeName: json['purpose_type_name'],
      floorDetails: (json['floorDetails'] as List<dynamic>?)
          ?.map((e) => BuildingInfo.fromJson(e))
          .toList(),
    );
  }
}


class BuildingInfo {
  final String? id;
  final int? applicationId, purpose, floor, amenity, isActive;
  final String? purposeTypeName, floorName, amenityTypeName;
  final Area? area;
  final double?  chargeAmount, totalChargeAmount;

  BuildingInfo({
    this.id,
    this.applicationId,
    this.purpose,
    this.purposeTypeName,
    this.floor,
    this.floorName,
    this.amenity,
    this.amenityTypeName,
    this.area,
    this.chargeAmount,
    this.totalChargeAmount,
    this.isActive,
  });

  factory BuildingInfo.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble(); // convert int → double
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt(); // convert double → int
      if (value is String) return int.tryParse(value);
      return null;
    }

    return BuildingInfo(
      id: json['id'],
      applicationId: parseInt(json['application_id']),
      purpose: parseInt(json['purpose']),
      purposeTypeName: json['purpose_type_name'],
      floor: parseInt(json['floor']),
      floorName: json['floor_name'],
      amenity: parseInt(json['amenity']),
      amenityTypeName: json['amenity_type_name'],
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      chargeAmount: parseDouble(json['charge_amount']),
      totalChargeAmount: parseDouble(json['total_charge_amount']),
      isActive: parseInt(json['isActive']),
    );
  }

}

// Document Details
class DocumentDetails {
  final Map<String, DocumentType>? documents;

  DocumentDetails({this.documents});

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    final docs = <String, DocumentType>{};
    json.forEach((key, value) {
      if (value != null) {
        docs[key] = DocumentType.fromJson(value);
      }
    });
    return DocumentDetails(documents: docs);
  }
}

class DocumentType {
  final int? id, applicationId;
  final List<Document>? documents;

  DocumentType({this.id, this.applicationId, this.documents});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'],
      applicationId: json['application_id'],
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}

class Document {
  final String? filename;
  final String? originalFileName;
  final String? mimeType;
  final String? fileID;
  final String? applicationID;
  final String? documentType;
  final String? base64;
  final String? userID;
  final String? uploadedBy;
  final String? bucketName;
  final String? documentID;
  final String? transactionID;
  final bool? isAdditionalDocument;
  final String? createdAt;

  Document({
    this.filename,
    this.originalFileName,
    this.mimeType,
    this.fileID,
    this.applicationID,
    this.documentType,
    this.base64,
    this.userID,
    this.uploadedBy,
    this.bucketName,
    this.documentID,
    this.transactionID,
    this.isAdditionalDocument,
    this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      filename: json['filename'],
      originalFileName: json['originalFileName'],
      mimeType: json['mimeType'],
      fileID: json['fileID'],
      applicationID: json['applicationID']?.toString(),
      documentType: json['documentType'],
      base64: json['base64'],
      userID: json['userID']?.toString(),
      uploadedBy: json['uploadedBy']?.toString(),
      bucketName: json['bucketName'],
      documentID: json['documentID'],
      transactionID: json['transactionID']?.toString(),
      isAdditionalDocument: json['isAdditionalDocument'],
      createdAt: json['createdAt'],
    );
  }
}


// Charges
class Charges {
  final List<StandardCharge>? standard;
  final List<ProrataCharge>? prorata;
  final dynamic gbwasp;

  Charges({this.standard, this.prorata, this.gbwasp});

  factory Charges.fromJson(Map<String, dynamic> json) {
    List<StandardCharge>? standardCharges;
    if (json['standard'] is List) {
      standardCharges = (json['standard'] as List<dynamic>)
          .map((e) => StandardCharge.fromJson(e))
          .toList();
    }

    List<ProrataCharge>? prorataCharges;
    if (json['prorata'] is List) {
      prorataCharges = (json['prorata'] as List<dynamic>)
          .map((e) => ProrataCharge.fromJson(e))
          .toList();
    }

    return Charges(
      standard: standardCharges,
      prorata: prorataCharges,
      gbwasp: json['gbwasp'],
    );
  }

}

class StandardCharge {
  final int? id, quantity, rate, amount, isactive;
  final String? name;

  StandardCharge({this.id, this.name, this.quantity, this.rate, this.amount, this.isactive});

  factory StandardCharge.fromJson(Map<String, dynamic> json) {
    return StandardCharge(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      rate: json['rate'],
      amount: json['amount'],
      isactive: json['isactive'],
    );
  }
}

class ProrataCharge {
  final int? id,
       rate, amount;
  final double? sizeInSqmt;
  final String? floorName, amenity;

  ProrataCharge({
    this.id,
    this.floorName,
    this.amenity,
    this.sizeInSqmt,
    this.rate,
    this.amount,
  });

  factory ProrataCharge.fromJson(Map<String, dynamic> json) {
    return ProrataCharge(
      id: json['id'],
      floorName: json['floor_name'],
      amenity: json['amenity'],
      sizeInSqmt: (json['size_in_sqmt'] as num?)?.toDouble(),
      rate: json['rate'],
      amount: json['amount'],
    );
  }
}
