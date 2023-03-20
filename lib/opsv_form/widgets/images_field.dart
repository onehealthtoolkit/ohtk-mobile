part of 'widgets.dart';

var _uuid = const Uuid();

class FormImagesField extends StatefulWidget {
  final opsv.ImagesField field;

  const FormImagesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormImagesField> createState() => _FormImagesFieldState();
}

class _FormImagesFieldState extends State<FormImagesField> {
  final IImageService _imageService = locator<IImageService>();
  final _logger = locator<Logger>();
  final AppTheme apptheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var numberOfCurrentImages = widget.field.length;

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
                itemCount: numberOfCurrentImages + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddImageBox();
                  }

                  var imageId = widget.field.value[index -
                      1]; // minus 1 because of dummy image is the first.

                  return FutureBuilder<Image>(
                      future: _getImage(imageId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return RemoveableImage(
                            image: snapshot.data!,
                            imageId: widget.field.value[index -
                                1], // because index 0 alway be dummy image
                            onRemove: _removeImage,
                          );
                        }
                        return const CircularProgressIndicator();
                      });
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<Image> _getImage(String imageId) async {
    var reportImage = await _imageService.getImage(imageId);
    return Image.memory(
      width: 200.w,
      height: 200.w,
      reportImage.image,
      fit: BoxFit.cover,
    );
  }

  _buildAddImageBox() {
    return CircleAvatar(
      backgroundColor: apptheme.sub4,
      child: IconButton(
        icon: Icon(Icons.add_a_photo, color: apptheme.primary),
        onPressed: _showAddImageModal,
      ),
    );
  }

  _addImage(String id) {
    widget.field.add(id);
  }

  _removeImage(String id) {
    widget.field.remove(id);
    _imageService.removeImage(id);
  }

  _showAddImageModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                var reportImage = await _pickImage(ImageSource.gallery);
                if (reportImage != null) {
                  _addImage(reportImage.id);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () async {
                var reportImage = await _pickImage(ImageSource.camera);
                if (reportImage != null) {
                  _addImage(reportImage.id);
                }
                Navigator.pop(context);
              },
            ),
          ],
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

typedef RemoveCallback = void Function(String imageId);

class RemoveableImage extends StatelessWidget {
  final Image image;
  final String imageId;
  final RemoveCallback onRemove;
  final AppTheme apptheme = locator<AppTheme>();

  RemoveableImage(
      {required this.image,
      required this.imageId,
      required this.onRemove,
      Key? key})
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
            child: image,
            padding: const EdgeInsets.all(4),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              onRemove(imageId);
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
