import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/components/progress_indicator.dart';
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
            _framer(context),
            _qrPicker(viewModel, context),
            if (viewModel.isBusy) _waitingProgress(context),
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
            CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 40,
              child: OhtkProgressIndicator(size: 80),
            ),
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

  Stack _framer(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 330.0;

    return Stack(children: [
      ColorFiltered(
        colorFilter: const ColorFilter.mode(
            Colors.black38, BlendMode.srcOut), // This one will create the magic
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode
                      .dstOut), // This one will handle background + difference out
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: scanArea,
                width: scanArea,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(),
          child: SizedBox(
            width: scanArea + 25,
            height: scanArea + 25,
          ),
        ),
      ),
    ]);
  }
}

// Creates the white borders
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
