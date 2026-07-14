part of 'widgets.dart';

class FormFilesField extends StatefulWidget {
  final opsv.FilesField field;

  const FormFilesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormFilesField> createState() => _FormFilesFieldState();
}

class _FormFilesFieldState extends State<FormFilesField> {
  final IFileService _fileService = locator<IFileService>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      final entries = widget.field.value.toList(growable: false);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++)
            _FileRow(
              key: ValueKey(entries[i]),
              fileIdExt: entries[i],
              showTopDivider: i == 0,
              loader: _getFile,
              onRemove: _removeFile,
            ),
          if (entries.isNotEmpty) const SizedBox(height: 10),
          _AttachFileButton(onTap: _onAddFile),
        ],
      );
    });
  }

  Future<ReportFile> _getFile(String fileIdExt) async {
    final id = fileIdExt.split('.')[0];
    return _fileService.getReportFile(id);
  }

  Future<void> _onAddFile() async {
    final reportFile = await _pickFile();
    if (reportFile != null) {
      widget.field.add(reportFile.idExt, reportFile.name);
    }
  }

  void _removeFile(String id, String idExt) {
    widget.field.remove(idExt);
    _fileService.removeLocalFileFromAppDirectory(id);
    _fileService.removeReportFile(id);
  }

  Future<ReportFile?> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null) return null;
    final path = result.files.first.path;
    if (path == null) return null;

    final name = result.files.first.name;
    final extension = result.files.first.extension ?? '';
    final mimeType = lookupMimeType(path) ?? '';
    final cacheFile = File(path);
    final fileBytes = await cacheFile.readAsBytes();
    final uuid = const Uuid().v4();

    final file = await _fileService.createLocalFileInAppDirectory(
        uuid, widget.field.form.id, extension);
    await file.writeAsBytes(fileBytes);

    final reportFile = ReportFile(
        uuid, widget.field.form.id, name, file.path, extension, mimeType);
    await _fileService.saveReportFile(reportFile);
    await cacheFile.delete();
    return reportFile;
  }
}

typedef FileRemoveCallback = void Function(String fileId, String fileIdExt);

class _FileRow extends StatelessWidget {
  final String fileIdExt;
  final bool showTopDivider;
  final Future<ReportFile> Function(String) loader;
  final FileRemoveCallback onRemove;

  const _FileRow({
    Key? key,
    required this.fileIdExt,
    required this.showTopDivider,
    required this.loader,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReportFile>(
      future: loader(fileIdExt),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: showTopDivider
                    ? const BorderSide(color: incidentsHair, width: 1)
                    : BorderSide.none,
                bottom: const BorderSide(color: incidentsHair, width: 1),
              ),
            ),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _ohtkFormBrand,
              ),
            ),
          );
        }
        final file = snapshot.data!;
        return Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            border: Border(
              top: showTopDivider
                  ? const BorderSide(color: incidentsHair, width: 1)
                  : BorderSide.none,
              bottom: const BorderSide(color: incidentsHair, width: 1),
            ),
          ),
          child: GestureDetector(
            onTap: () => _showFileInfo(context, file.name),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _FileGlyph(mimeType: file.fileType),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: incidentsInk,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: incidentsMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => onRemove(file.id, file.idExt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFileInfo(BuildContext context, String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: incidentsInk,
        behavior: SnackBarBehavior.floating,
        content: Text(name),
      ),
    );
  }
}

class _FileGlyph extends StatelessWidget {
  final String mimeType;
  const _FileGlyph({required this.mimeType});

  IconData _iconFor(String mt) {
    if (mt.contains('audio')) return Icons.audiotrack_outlined;
    if (mt.contains('video')) return Icons.video_camera_back_outlined;
    if (mt.contains('image')) return Icons.image_outlined;
    if (mt.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mt.contains('application')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _ohtkFormBrandTint(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_iconFor(mimeType), size: 18, color: _ohtkFormBrand),
    );
  }
}

class _AttachFileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AttachFileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DottedBorder(
        color: _ohtkFormBrand,
        strokeWidth: 1.5,
        dashPattern: const [5, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        padding: EdgeInsets.zero,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _ohtkFormBrandTint(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: _ohtkFormBrand),
              const SizedBox(width: 6),
              Text(
                localize.attachFileButton.toUpperCase(),
                style: TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _ohtkFormBrand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
