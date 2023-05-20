import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/playable_file_view.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/base_report_file.dart';

class ReportFileGridView<T extends BaseReportFile> extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final List<T>? files;

  ReportFileGridView(this.files, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (files == null || files!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: appTheme.sub4,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No Files",
                  style: TextStyle(
                    color: appTheme.sub2,
                    fontSize: 16.sp,
                  ),
                ),
                Image.asset(
                  "assets/images/OHTK.png",
                )
              ],
            ),
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
              child: Center(child: _display(file.fileType)),
              padding: const EdgeInsets.all(4),
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
