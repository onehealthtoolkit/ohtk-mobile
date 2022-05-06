import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/ui_definition/fields/images_field_ui_definition.dart';
import 'package:podd_app/form/widgets/validation.dart';
import 'package:provider/provider.dart';

class FormImagesField extends StatefulWidget {
  final ImagesFieldUIDefinition fieldDefinition;

  const FormImagesField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormImagesField> createState() => _FormImagesFieldState();
}

class _FormImagesFieldState extends State<FormImagesField> {
  UnRegisterValidationCallback? unRegisterValidationCallback;
  bool valid = true;
  String errorMessage = '';

  ValidationState validate() {
    var isValid = true;
    var msg = '';

    var formData = Provider.of<FormData>(context, listen: false);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as ImagesFormValue;
    if (formValue.length == 0) {
      isValid = false;
      msg = '${widget.fieldDefinition.name} is required';
    }
    if (mounted) {
      setState(() {
        valid = isValid;
        errorMessage = msg;
      });
    }
    return ValidationState(isValid, msg);
  }

  @override
  void dispose() {
    if (unRegisterValidationCallback != null) {
      unRegisterValidationCallback!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formStore = Provider.of<FormStore>(context);
    if (widget.fieldDefinition.required == true) {
      unRegisterValidationCallback = formStore.registerValidation(validate);
    }

    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as ImagesFormValue;

    return Observer(builder: (BuildContext context) {
      var numberOfCurrentImages = formValue.length;

      return GridView.builder(
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

          // @TODO get image from image service
          return RemoveableImage(
            image: Image.network("https://picsum.photos/200"),
            imageId: formValue
                .value[index - 1], // because index 0 alway be dummy image
            onRemove: _removeImage,
          );
        },
      );
    });
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
              onTap: () {
                // @TODO call reportService.add
                _addImage("hi");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () {
                // @TODO call reportService.add
                _addImage("x");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
