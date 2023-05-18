part of 'widgets.dart';

class FormField extends StatelessWidget {
  final opsv.Field field;

  const FormField({Key? key, required this.field}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  _buildWidget() {
    if (field is opsv.TextField) {
      return FormTextField(field as opsv.TextField);
    } else if (field is opsv.IntegerField) {
      return FormIntegerField(field as opsv.IntegerField);
    } else if (field is opsv.DecimalField) {
      return FormDecimalField(field as opsv.DecimalField);
    } else if (field is opsv.DateField) {
      return FormDateField(field as opsv.DateField);
    } else if (field is opsv.ImagesField) {
      return FormImagesField(field as opsv.ImagesField);
    } else if (field is opsv.FilesField) {
      return FormFilesField(field as opsv.FilesField);
    } else if (field is opsv.LocationField) {
      return FormLocationField(field as opsv.LocationField);
    } else if (field is opsv.SingleChoicesField) {
      return FormSingleChoicesField(field as opsv.SingleChoicesField);
    } else if (field is opsv.MultipleChoicesField) {
      return FormMultipleChoicesField(field as opsv.MultipleChoicesField);
    }

    return const Text("unknown field");
  }
}
