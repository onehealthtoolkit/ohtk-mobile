import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/components/qr_scanner_parts.dart';
import 'package:podd_app/ui/login/qr_login_view_model.dart';
import 'package:scan/scan.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrLoginView extends StatelessWidget {
  const QrLoginView({Key? key}) : super(key: key);

  Future<XFile?> _pickImage(ImageSource source) async {
    var picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source);
      return image;
    } catch (e) {
      debugPrint("$e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrLoginViewModel>.reactive(
      viewModelBuilder: () => QrLoginViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text('QR Code Login')),
        body: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(
                  facing: CameraFacing.back, torchEnabled: false),
              onDetect: (barcodeCapture) async {
                if (viewModel.detected) return;

                viewModel.detected = true;
                // check barcodeCapture.barcodes length
                if (barcodeCapture.barcodes.isEmpty) {
                  Navigator.pop(context, 'Failed to scan QRCode');
                } else {
                  final String? code = barcodeCapture.barcodes.first.rawValue;
                  if (code == null) {
                    GoRouter.of(context).pop('Failed to scan QR Code');
                  } else {
                    final error = await viewModel.authenticate(code);
                    if (context.mounted) {
                      GoRouter.of(context).pop(error);
                    }
                  }
                }
              },
            ),
            const ScannerMaskOverlay(),
            _qrPicker(viewModel, context),
            if (viewModel.isBusy) const ScannerWaitingProgress(),
          ],
        ),
      ),
    );
  }

  _qrPicker(QrLoginViewModel viewModel, BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton.primary(
        onPressed: () async {
          final image = await _pickImage(ImageSource.gallery);
          if (image != null) {
            String? data = await Scan.parse(image.path);
            String? error;
            if (data != null) {
              error = await viewModel.authenticate(data);
            } else {
              error = 'Failed to read QR Code';
            }
            if (context.mounted) {
              GoRouter.of(context).pop(error);
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(AppLocalizations.of(context)!.pickQrcodeImageButton),
          ],
        ),
      ),
    );
  }
}
