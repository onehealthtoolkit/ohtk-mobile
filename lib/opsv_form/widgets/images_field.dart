part of 'widgets.dart';

var _uuid = const Uuid();

const double _thumbSize = 76;
const double _thumbRadius = 10;

class FormImagesField extends StatefulWidget {
  final opsv.ImagesField field;

  const FormImagesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormImagesField> createState() => _FormImagesFieldState();
}

class _FormImagesFieldState extends State<FormImagesField> {
  final IImageService _imageService = locator<IImageService>();
  final _logger = locator<Logger>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      final ids = widget.field.value.toList(growable: false);
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _AddImageTile(onTap: _showAddImageModal),
          for (final id in ids)
            _ImageThumb(
              key: ValueKey(id),
              imageId: id,
              loader: _getImage,
              onRemove: _removeImage,
            ),
        ],
      );
    });
  }

  Future<Image> _getImage(String imageId) async {
    var reportImage = await _imageService.getImage(imageId);
    return Image.memory(
      reportImage.image,
      width: _thumbSize,
      height: _thumbSize,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }

  void _addImage(String id) {
    widget.field.add(id);
  }

  void _removeImage(String id) {
    widget.field.remove(id);
    _imageService.removeImage(id);
  }

  void _showAddImageModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final localize = AppLocalizations.of(context)!;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: incidentsHair,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              _PickerRow(
                icon: Icons.photo_library_outlined,
                label: localize.pickFromGallery,
                onTap: () async {
                  Navigator.pop(context);
                  final reportImage = await _pickImage(ImageSource.gallery);
                  if (reportImage != null) _addImage(reportImage.id);
                },
              ),
              _PickerRow(
                icon: Icons.photo_camera_outlined,
                label: localize.takeAPhoto,
                onTap: () async {
                  Navigator.pop(context);
                  final reportImage = await _pickImage(ImageSource.camera);
                  if (reportImage != null) _addImage(reportImage.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<ReportImage?> _pickImage(ImageSource source) async {
    var picker = ImagePicker();
    try {
      XFile? imageFile = await picker.pickImage(
          source: source, maxWidth: 2048, maxHeight: 2048, imageQuality: 85);
      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        var reportImage = ReportImage(_uuid.v4(), widget.field.form.id, bytes);
        await _imageService.saveImage(reportImage);
        return reportImage;
      }
    } on PlatformException catch (e) {
      _logger.e(e.message);
    }
    return null;
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DottedBorder(
        color: _ohtkFormBrand,
        strokeWidth: 1.5,
        dashPattern: const [5, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(_thumbRadius),
        padding: EdgeInsets.zero,
        child: Container(
          width: _thumbSize,
          height: _thumbSize,
          decoration: BoxDecoration(
            color: _ohtkFormBrandTint(0.08),
            borderRadius: BorderRadius.circular(_thumbRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 22,
                color: _ohtkFormBrand,
              ),
              const SizedBox(height: 2),
              Text(
                'ADD',
                style: TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 10,
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

class _ImageThumb extends StatelessWidget {
  final String imageId;
  final Future<Image> Function(String) loader;
  final void Function(String) onRemove;

  const _ImageThumb({
    Key? key,
    required this.imageId,
    required this.loader,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _thumbSize,
      height: _thumbSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: incidentsSand,
                borderRadius: BorderRadius.circular(_thumbRadius),
                border: Border.all(color: incidentsHair, width: 1),
              ),
              child: FutureBuilder<Image>(
                future: loader(imageId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) return snapshot.data!;
                  return Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _ohtkFormBrand,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: _RemoveBadge(onTap: () => onRemove(imageId)),
          ),
        ],
      ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: incidentsHair, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          size: 13,
          color: incidentsInk,
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: _ohtkFormBrand),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: incidentsInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
