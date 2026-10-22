import 'package:intl/intl.dart';
import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:podd_app/models/entities/base_report_image.dart';

class IncidentReportImage extends BaseReportImage {
  IncidentReportImage(Map<String, dynamic> json) : super(json);

  factory IncidentReportImage.fromJson(Map<String, dynamic> json) =>
      IncidentReportImage(json);
}

class IncidentReportFile extends BaseReportFile {
  IncidentReportFile(Map<String, dynamic> json) : super(json);

  factory IncidentReportFile.fromJson(Map<String, dynamic> json) =>
      IncidentReportFile(json);
}

class IncidentReport {
  String id;
  Map<String, dynamic>? data;
  String description;
  String reportTypeId;
  String reportTypeName;
  bool reportTypeFollowable;
  DateTime incidentDate;
  DateTime createdAt;
  DateTime updatedAt;
  String? gpsLocation;
  List<IncidentReportImage>? images;
  List<IncidentReportFile>? files;
  String? caseId;
  ReportCaseStatus? caseStatus;
  int? threadId;
  String? authorityName;
  bool testFlag;

  /// Derived report + follow-up totals from ReportType.metric_accumulation.
  List<AccumulatedMetric>? accumulatedMetrics;

  IncidentReport({
    required this.id,
    this.data,
    required this.description,
    required this.reportTypeId,
    required this.reportTypeName,
    required this.incidentDate,
    required this.createdAt,
    required this.updatedAt,
    this.gpsLocation,
    this.images,
    this.files,
    this.caseId,
    this.caseStatus,
    this.threadId,
    this.authorityName,
    this.testFlag = false,
    this.reportTypeFollowable = false,
    this.accumulatedMetrics,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    var reportTypeFollowable = false;
    if (json["reportType"] != null) {
      var reportTypeMap = json["reportType"] as Map;
      if (reportTypeMap["isFollowable"] != null) {
        reportTypeFollowable = reportTypeMap["isFollowable"] as bool;
      }
    }
    List<AccumulatedMetric>? metrics;
    final acc = json["accumulatedMetrics"];
    if (acc is Map && acc["metrics"] is List) {
      metrics = (acc["metrics"] as List)
          .whereType<Map>()
          .map((m) => AccumulatedMetric.fromJson(
                Map<String, dynamic>.from(m),
              ))
          .toList();
    }
    return IncidentReport(
      id: json["id"],
      description: json["rendererData"],
      reportTypeId: (json["reportType"] as Map)["id"],
      reportTypeName: (json["reportType"] as Map)["name"],
      incidentDate: DateFormat("yyyy-MM-dd").parse(json["incidentDate"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      gpsLocation: json["gpsLocation"],
      data: json["data"],
      caseId: json["caseId"],
      caseStatus: json["caseStatus"] is Map
          ? ReportCaseStatus.fromJson(json["caseStatus"])
          : null,
      threadId: json["threadId"],
      testFlag: json["testFlag"] != null ? (json["testFlag"] as bool) : false,
      images: json["images"] != null
          ? (json["images"] as List)
              .map((image) => IncidentReportImage.fromJson(image))
              .toList()
          : [],
      files: json["uploadFiles"] != null
          ? (json["uploadFiles"] as List)
              .map((file) => IncidentReportFile.fromJson(file))
              .toList()
          : [],
      authorityName: json["authorities"] != null
          ? (json["authorities"] as List)
              .map((authority) => authority["name"])
              .join(",")
          : "",
      reportTypeFollowable: reportTypeFollowable,
      accumulatedMetrics: metrics,
    );
  }

  String get trimWhitespaceDescription {
    // replace multiple consecutive whitespace or newline with single whitespace
    return description.replaceAll(RegExp(r"\s+"), " ");
  }

  bool get hasAccumulatedMetrics =>
      accumulatedMetrics != null && accumulatedMetrics!.isNotEmpty;
}

class AccumulatedMetric {
  final String id;
  final String label;
  final String op;
  final int value;
  final int reportValue;
  final List<int> followupValues;

  AccumulatedMetric({
    required this.id,
    required this.label,
    required this.op,
    required this.value,
    required this.reportValue,
    required this.followupValues,
  });

  factory AccumulatedMetric.fromJson(Map<String, dynamic> json) {
    final followups = json["followupValues"];
    return AccumulatedMetric(
      id: json["id"]?.toString() ?? "",
      label: json["label"]?.toString() ?? json["id"]?.toString() ?? "",
      op: json["op"]?.toString() ?? "sum",
      value: _asInt(json["value"]),
      reportValue: _asInt(json["reportValue"]),
      followupValues: followups is List
          ? followups.map((e) => _asInt(e)).toList()
          : const [],
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? "") ?? 0;
  }
}

/// Unknown/legacy finish combinations deliberately retain the generic case badge.
enum ReportCaseOutcome { unknown, open, closed, automaticClose, falsePositive }

class ReportCaseStatus {
  final bool? isFinished;
  final String? closeSource;
  final String? closeOutcome;

  const ReportCaseStatus(
      {this.isFinished, this.closeSource, this.closeOutcome});

  factory ReportCaseStatus.fromJson(Map json) => ReportCaseStatus(
        isFinished: json['isFinished'] is bool ? json['isFinished'] : null,
        closeSource: json['closeSource'] is String ? json['closeSource'] : null,
        closeOutcome:
            json['closeOutcome'] is String ? json['closeOutcome'] : null,
      );

  ReportCaseOutcome get outcome {
    if (isFinished == false) return ReportCaseOutcome.open;
    if (isFinished != true) return ReportCaseOutcome.unknown;
    if (closeSource == 'system') return ReportCaseOutcome.automaticClose;
    if (closeSource == 'officer') {
      if (closeOutcome == 'close_case') return ReportCaseOutcome.closed;
      if (closeOutcome == 'false_positive') {
        return ReportCaseOutcome.falsePositive;
      }
    }
    return ReportCaseOutcome.unknown;
  }
}
