part of 'widgets.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
                facing: CameraFacing.back, torchEnabled: false),
            onDetect: (barcodeCapture) {
              String? result;
              if (barcodeCapture.barcodes.isNotEmpty) {
                result = barcodeCapture.barcodes.first.rawValue;
              }
              Navigator.pop(context, result);
            },
          ),
          const ScannerMaskOverlay(),
        ],
      ),
    );
  }
}
