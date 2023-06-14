part of 'widgets.dart';

class FormFilesField extends StatefulWidget {
  final opsv.FilesField field;

  const FormFilesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormFilesField> createState() => _FormFilesFieldState();
}

class _FormFilesFieldState extends State<FormFilesField> {
  final IFileService _fileService = locator<IFileService>();
  final _logger = locator<Logger>();
  final AppTheme apptheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var numberOfCurrentFiles = widget.field.length;

      return ValidationWrapper(
        widget.field,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.label != null && widget.field.label != "")
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.field.label!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            DottedBorder(
              color: apptheme.sub3,
              dashPattern: const [6, 6],
              borderType: BorderType.RRect,
              radius: Radius.circular(apptheme.borderRadius),
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  // width / height: fixed for *all* items
                  childAspectRatio: 1,
                ),
                itemCount: numberOfCurrentFiles + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddFileBox();
                  }
                  // minus 1 because of dummy file is the first.
                  var fileIdExt = widget.field.value[index - 1];

                  return FutureBuilder<ReportFile>(
                    future: _getFile(fileIdExt),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return RemoveableFile(
                          file: snapshot.data!,
                          onRemove: _removeFile,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<ReportFile> _getFile(String fileIdExt) async {
    final id = fileIdExt.split('.')[0];
    var reportFile = await _fileService.getReportFile(id);
    return reportFile;
  }

  _buildAddFileBox() {
    return CircleAvatar(
      backgroundColor: apptheme.sub4,
      child: IconButton(
        icon: Icon(Icons.add_card, color: apptheme.primary),
        onPressed: () async {
          var reportFile = await _pickFile();
          if (reportFile != null) {
            _addFile(reportFile.idExt, reportFile.name);
          }
        },
      ),
    );
  }

  _addFile(String idExt, String nameExt) {
    widget.field.add(idExt, nameExt);
  }

  _removeFile(String id, String idExt) {
    widget.field.remove(idExt);
    _fileService.removeLocalFileFromAppDirectory(id);
    _fileService.removeReportFile(id);
  }

  Future<ReportFile?> _pickFile() async {
    ReportFile? reportFile;
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      var path = result.files.first.path;
      var name = result.files.first.name;
      var extension = result.files.first.extension ?? '';

      var mimeType = lookupMimeType(path!) ?? '';
      var cacheFile = File(path);
      var fileBytes = await cacheFile.readAsBytes();
      var uuid = const Uuid().v4();

      final file = await _fileService.createLocalFileInAppDirectory(
          uuid, widget.field.form.id, extension);
      await file.writeAsBytes(fileBytes);

      reportFile = ReportFile(
          uuid, widget.field.form.id, name, file.path, extension, mimeType);

      await _fileService.saveReportFile(reportFile);
      // Remove picker's cache file after report file was saved to appData
      await cacheFile.delete();
    } else {
      // User canceled the picker
    }
    return reportFile;
  }
}

class FileDisplay extends StatelessWidget {
  final AppTheme apptheme = locator<AppTheme>();
  final String name;
  final String mimeType;

  FileDisplay({Key? key, required this.mimeType, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: apptheme.bg1,
          content: Text(name),
        ));
      },
      child: SizedBox(
        width: 200.w,
        height: 200.w,
        child: Center(child: _display(mimeType)),
      ),
    );
  }

  Widget? _display(String mimeType) {
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

typedef FileRemoveCallback = void Function(String fileId, String fileIdExt);

class RemoveableFile extends StatelessWidget {
  final ReportFile file;
  final FileRemoveCallback onRemove;
  final AppTheme apptheme = locator<AppTheme>();

  RemoveableFile({required this.file, required this.onRemove, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: DottedBorder(
            color: apptheme.sub3,
            radius: const Radius.circular(12),
            dashPattern: const [4, 4],
            child: FileDisplay(name: file.name, mimeType: file.fileType),
            padding: const EdgeInsets.all(4),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              onRemove(file.id, file.idExt);
            },
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 9,
                child: Icon(Icons.cancel, color: apptheme.primary, size: 18)),
          ),
        ),
      ],
    );
  }
}
