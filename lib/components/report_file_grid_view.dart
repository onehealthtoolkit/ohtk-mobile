import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/playable_file_view.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:open_file/open_file.dart';

class ReportFileGridView<T extends BaseReportFile> extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final List<T>? files;

  ReportFileGridView(this.files, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (files == null || files!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: files!.length,
        itemBuilder: (context, index) {
          final file = files![index];
          return OpenableReportFile(file: file);
        },
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class OpenableReportFile<T extends BaseReportFile> extends StatelessWidget {
  final T file;
  final AppTheme apptheme = locator<AppTheme>();

  OpenableReportFile({required this.file, Key? key}) : super(key: key);

  Future<void> _playAudio(BuildContext context) async {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.white.withOpacity(0),
        pageBuilder: (BuildContext context, _, __) {
          return PlayableReportFileView(
            type: file.fileType,
            url: file.fileUrl,
          );
        },
      ),
    );
  }

  Future<String?> downloadFile(String url, String fileName) async {
    final Directory tempDir = await getTemporaryDirectory();
    final cacheFilePath = '${tempDir.path}/$fileName';

    HttpClient httpClient = HttpClient();
    File file;
    String? filePath;

    if (File(cacheFilePath).existsSync()) {
      filePath = cacheFilePath;
      Logger().d('Found cache file = $filePath');
    } else {
      try {
        Logger().d('No cache file in $cacheFilePath');
        var request = await httpClient.getUrl(Uri.parse(url));
        var response = await request.close();
        if (response.statusCode == 200) {
          var bytes = await consolidateHttpClientResponseBytes(response);
          file = await File(cacheFilePath).create(recursive: true);
          await file.writeAsBytes(bytes);
          filePath = cacheFilePath;
          Logger().d('Download file ok : save new file in $filePath');
        }
      } catch (ex) {
        Logger().e('Error download file');
      }
    }
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (file.fileType.contains('audio')) {
          _playAudio(context);
        } else {
          final filePath = await downloadFile(file.fileUrl, file.filePath);

          if (filePath != null) {
            final result = await OpenFile.open(filePath, type: file.fileType);

            if (context.mounted) {
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                      "Cannot open file. \nEither no app supports or file is corrupted"),
                  duration: Duration(milliseconds: 3000),
                ));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.red,
                content: Text("File not found"),
                duration: Duration(milliseconds: 3000),
              ));
            }
          }
        }
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            color: apptheme.sub4,
            child: DottedBorder(
              color: apptheme.primary,
              radius: const Radius.circular(12),
              dashPattern: const [4, 4],
              padding: const EdgeInsets.all(4),
              child: Center(child: _display(file.fileType)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 9,
                child:
                    Icon(Icons.play_arrow, color: apptheme.primary, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _display(String mimeType) {
    Widget? content;
    double size = 36.0;
    if (mimeType.contains('audio')) {
      content = Icon(
        Icons.audiotrack_outlined,
        size: size,
        color: apptheme.bg1,
      );
    } else if (mimeType.contains('video')) {
      content = Icon(
        Icons.video_camera_back_outlined,
        size: size,
        color: apptheme.bg1,
      );
    } else if (mimeType.contains('application')) {
      content = Icon(
        Icons.edit_document,
        size: size,
        color: apptheme.bg1,
      );
    } else {
      content = Icon(
        Icons.question_mark,
        size: size,
        color: apptheme.bg1,
      );
    }
    return content;
  }
}
