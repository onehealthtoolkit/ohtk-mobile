import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart' hide Form, TextField;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:uuid/uuid.dart';

class SimulateSubmitReportButton extends StatefulWidget {
  const SimulateSubmitReportButton({Key? key}) : super(key: key);

  @override
  State<SimulateSubmitReportButton> createState() =>
      _SimulateSubmitReportButtonState();
}

class _SimulateSubmitReportButtonState
    extends State<SimulateSubmitReportButton> {
  final IFileService _fileService = locator<IFileService>();
  final IReportTypeService _reportTypeService = locator<IReportTypeService>();
  final IReportService _reportService = locator<IReportService>();
  final IImageService _imageService = locator<IImageService>();

  Random rand = Random();
  Uuid uuid = const Uuid();
  int submitIntervalInSecond = 5;
  bool testFlag = false;
  bool submitOn = false;
  int successCount = 0;
  int failCount = 0;
  String reportTypeId =
      "7730eb3f-7529-4cb4-8584-e602a9bb0777"; // Test new feature

  Timer? timer;
  ReportType? reportType;

  @override
  void initState() {
    _initReportType();
    super.initState();
  }

  _initReportType() async {
    reportType = await _reportTypeService.getReportType(reportTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Switch(
          activeColor: Theme.of(context).primaryColor,
          inactiveTrackColor: Theme.of(context).highlightColor,
          value: submitOn,
          onChanged: (val) async {
            if (reportType != null) {
              setState(() {
                submitOn = !submitOn;
                startStopTimer();
              });
            } else {
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(
                      "No reportType id: $reportTypeId. \nPlease sync report type first"),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: <Widget>[
                    FlatButton.primary(
                      child: Text(AppLocalizations.of(context)!.ok),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        Positioned(
            top: 35,
            left: 10,
            child: Row(
              children: [
                _statBox(Theme.of(context).primaryColor, successCount),
                _statBox(Theme.of(context).colorScheme.error, failCount),
              ],
            ))
      ],
    );
  }

  Container _statBox(Color background, int value) {
    return Container(
      width: 20,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
      child: Center(
        child: Text(
          value.toString(),
          textScaleFactor: .8,
        ),
      ),
    );
  }

  Future<void> createFile(Form form, File f) async {
    String reportId = form.id;
    var mimeType = lookupMimeType(f.path) ?? '';
    var fileBytes = await f.readAsBytes();
    var id = uuid.v4();
    var chunks = f.path.split('/');
    var filename = chunks[chunks.length - 1];
    var extension = filename.split('.')[1];

    final file = await _fileService.createLocalFileInAppDirectory(
        id, reportId, extension);
    await file.writeAsBytes(fileBytes);

    var reportFile =
        ReportFile(id, reportId, filename, file.path, extension, mimeType);

    await _fileService.saveReportFile(reportFile);

    var fileField = form.getField('files') as FilesField?;
    if (fileField != null) {
      fileField.add(id, filename);
    }
  }

  Future<void> createImage(Form form, File f) async {
    var bytes = await f.readAsBytes();
    var id = uuid.v4();
    var reportImage = ReportImage(id, form.id, bytes);
    await _imageService.saveImage(reportImage);

    var fileField = form.getField('photos') as ImagesField?;
    if (fileField != null) {
      fileField.add(id);
    }
  }

  Future<Form> createReport() async {
    final String timezone = await FlutterTimezone.getLocalTimezone();
    var reportId = uuid.v4();
    var form = Form.fromJson(
      json.decode(reportType!.definition),
      reportId,
      testFlag,
    );
    form.setTimezone(timezone);

    var nameField = form.getField('name') as TextField?;
    if (nameField != null) {
      nameField.value = 'test';
    }
    return form;
  }

  startStopTimer() {
    if (submitOn) {
      timer = Timer.periodic(
        Duration(seconds: submitIntervalInSecond),
        (timer) {
          doSubmitting();
        },
      );
    } else {
      if (timer != null) {
        timer!.cancel();
      }
      setState(() {
        successCount = 0;
        failCount = 0;
      });
    }
  }

  doSubmitting() async {
    File audio = await getRandomAudioFileFromAssets();
    File image = await getRandomImageFileFromAssets();

    Form form = await createReport();
    await createImage(form, image);
    await createFile(form, audio);

    if (audio.existsSync()) {
      await audio.delete();
    }
    if (image.existsSync()) {
      await image.delete();
    }

    var report = Report(
      id: form.id,
      data: form.toJsonValue(),
      reportTypeId: reportType!.id,
      reportTypeName: reportType!.name,
      incidentDate: DateTime.now(),
      incidentInAuthority: true,
      testFlag: form.testFlag,
    );

    var result = await _reportService.submit(report);
    setState(() {
      if (result is ReportSubmitSuccess) {
        successCount++;
      } else {
        failCount++;
      }
    });
  }

  Future<File> getRandomImageFileFromAssets() async {
    final paths = [
      "android.png",
      "background.png",
      "foreground.png",
      "ios.png"
    ];

    int num = rand.nextInt(100);
    int idx = num % 4;
    var name = paths[idx];
    return _getAssetFile('assets/images/launcher', name);
  }

  Future<File> getRandomAudioFileFromAssets() async {
    final paths = [
      "test_MP3_700KB.mp3",
      "test_MP3_1MB.mp3",
      "test_MP3_2MB.mp3",
    ];

    int num = rand.nextInt(100);
    int idx = num % 3;
    var name = paths[idx];
    return _getAssetFile('assets/audios', name);
  }

  Future<File> _getAssetFile(String path, String name) async {
    final byteData = await rootBundle.load('$path/$name');

    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
