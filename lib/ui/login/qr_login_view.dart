import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/ui/login/qr_login_view_model.dart';
import 'package:scan/scan.dart';
import 'package:stacked/stacked.dart';

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
            _framer(context),
            Align(
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 24,
                    ),
                    SizedBox(width: 4),
                    Text('Choose QRCode image'),
                  ],
                ),
              ),
            ),
            if (viewModel.isBusy) _waitingProgress(context),
          ],
        ),
      ),
    );
  }

  Center _waitingProgress(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black45,
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 5),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OhtkProgressIndicator(size: 80),
            SizedBox(height: 16),
            Text(
              "Please wait...",
              textScaleFactor: 1.3,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Center _framer(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 250,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
