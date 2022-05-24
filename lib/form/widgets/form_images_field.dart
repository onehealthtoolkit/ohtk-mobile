import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_values/images_form_value.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/ui_definition/fields/images_field_ui_definition.dart';
import 'package:podd_app/form/widgets/validation_wrapper.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

class FormImagesField extends StatefulWidget {
  final ImagesFieldUIDefinition fieldDefinition;

  const FormImagesField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormImagesField> createState() => _FormImagesFieldState();
}

class _FormImagesFieldState extends State<FormImagesField> {
  final IImageService _imageService = locator<IImageService>();
  final _logger = locator<Logger>();

  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as ImagesFormValue;

    return Observer(builder: (BuildContext context) {
      var numberOfCurrentImages = formValue.length;

      return ValidationWrapper(
        formValue,
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

            var imageId = formValue.value[
                index - 1]; // minus 1 because of dummy image is the first.

            // @TODO get image from image service
            return FutureBuilder<Image>(
                future: _getImage(imageId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RemoveableImage(
                      image: snapshot.data!,
                      imageId: formValue.value[
                          index - 1], // because index 0 alway be dummy image
                      onRemove: _removeImage,
                    );
                  }
                  return const CircularProgressIndicator();
                });
          },
        ),
      );
    });
  }

  Future<Image> _getImage(String imageId) async {
    var reportImage = await _imageService.getImage(imageId);
    return Image.memory(reportImage.image);
  }

  _buildAddImageBox() {
    return InkWell(
      onTap: _showAddImageModal,
      child: Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  _addImage(String id) {
    var formData = Provider.of<FormData>(context, listen: false);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as ImagesFormValue;
    formValue.add(id);
  }

  _removeImage(String id) {
    var formData = Provider.of<FormData>(context, listen: false);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as ImagesFormValue;
    formValue.remove(id);
    // @TODO call reportService.remove()
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
                var reportType = await _pickImage(ImageSource.gallery);
                if (reportType != null) {
                  _addImage(reportType.id);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () async {
                var reportType = await _pickImage(ImageSource.camera);
                if (reportType != null) {
                  _addImage(reportType.id);
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
    var formStore = Provider.of<FormStore>(context, listen: false);
    var picker = ImagePicker();
    try {
      XFile? imageFile = await picker.pickImage(source: source);
      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        var reportImage = ReportImage(_uuid.v4(), formStore.uuid, bytes);
        await _imageService.saveImage(reportImage);
        return reportImage;
      }
    } on PlatformException catch (e) {
      _logger.e(e);
    }
    return null;
  }
}

typedef RemoveCallback = void Function(String imageId);

class RemoveableImage extends StatelessWidget {
  final Image image;
  final String imageId;
  final RemoveCallback onRemove;
  const RemoveableImage(
      {required this.image,
      required this.imageId,
      required this.onRemove,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        image,
        Positioned(
          right: -14,
          top: -14,
          child: IconButton(
            icon: Icon(
              Icons.cancel,
              color: Colors.red.shade500,
              size: 18,
            ),
            onPressed: () {
              onRemove(imageId);
            },
          ),
        ),
      ],
    );
  }
}
