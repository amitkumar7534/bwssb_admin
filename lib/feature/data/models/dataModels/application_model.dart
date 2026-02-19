class ApplicationModel {
  final int applicationId;
  final int transactionId;
  final String applicationCode;
  final String applicantName;
  final String applicantMobile;
  final String name;
  final int processId;
  final String processDescription;
  final int stageNo;
  final String submissionDate;
  final String appliedBy;
  final int dueDayCount;
  final String dueDate;
  final int isActive;

  ApplicationModel({
    required this.applicationId,
    required this.transactionId,
    required this.applicationCode,
    required this.applicantName,
    required this.applicantMobile,
    required this.name,
    required this.processId,
    required this.processDescription,
    required this.stageNo,
    required this.submissionDate,
    required this.appliedBy,
    required this.dueDayCount,
    required this.dueDate,
    required this.isActive,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationID'],
      transactionId: json['transactionID'],
      applicationCode: json['application_code'],
      applicantName: json['applicantName'],
      applicantMobile: json['applicantMobile'],
      name: json['name'],
      processId: json['processID'],
      processDescription: json['processDescription'],
      stageNo: json['stageNo'],
      submissionDate: json['submissionDate'],
      appliedBy: json['appliedBy'],
      dueDayCount: json['dueDayCount'],
      dueDate: json['dueDate'],
      isActive: json['isactive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationID': applicationId,
      'transactionID': transactionId,
      'application_code': applicationCode,
      'applicantName': applicantName,
      'applicantMobile': applicantMobile,
      'name': name,
      'processID': processId,
      'processDescription': processDescription,
      'stageNo': stageNo,
      'submissionDate': submissionDate,
      'appliedBy': appliedBy,
      'dueDayCount': dueDayCount,
      'dueDate': dueDate,
      'isactive': isActive,
    };
  }
}
